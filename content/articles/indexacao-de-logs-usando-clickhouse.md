# Avaliação de Arquitetura: Indexação de Logs com ClickHouse

## Resumo executivo

Esta avaliação analisa o ClickHouse como plataforma de armazenamento, filtragem e indexação de logs em alto volume para uma solução de observabilidade. O sistema de destino deve ingerir um volume grande e contínuo de logs estruturados, retê-los conforme políticas operacionais e de conformidade, oferecer filtros e agregações rápidos e disponibilizar os dados em uma ferramenta de monitoramento como o Grafana.

O ClickHouse é uma boa opção quando a carga de trabalho é dominada por eventos somente de acréscimo, buscas por intervalo de tempo, agregações, análise de erros, exploração de serviços e dashboards operacionais. Deve ser tratado como um banco de dados analítico orientado a colunas, e não como um banco de dados transacional convencional ou um mecanismo genérico de busca textual completa.

Arquitetura recomendada:

1. Produzir logs estruturados com atributos estáveis de serviço, ambiente, severidade, horário, trace e requisição.
2. Coletar e armazenar temporariamente os logs em buffer usando OpenTelemetry Collector, Vector, Fluent Bit ou uma plataforma durável de eventos.
3. Normalizar e enriquecer os registros antes de inseri-los no ClickHouse.
4. Armazenar logs recentes e consultados com frequência em tabelas MergeTree ordenadas de acordo com os principais caminhos de investigação.
5. Usar views materializadas ou tabelas derivadas para agregações frequentes, sem substituir a tabela de eventos brutos.
6. Aplicar políticas de TTL, armazenamento em camadas e arquivamento para controlar custos.
7. Conectar o Grafana ou outra ferramenta de monitoramento usando a fonte de dados do ClickHouse, com limites de consulta e controles de acesso.
8. Manter um arquivo em armazenamento de objetos quando a retenção, reprodução, preservação legal ou recuperação de desastre exigir dados além do período operacional do ClickHouse.

O ClickHouse é recomendado como índice analítico primário de logs quando padrões previsíveis de consulta, alto volume de ingestão e agregações econômicas são mais importantes do que a classificação por relevância de texto arbitrário. Um mecanismo de busca ainda pode ser apropriado para busca linguística avançada, correspondência aproximada ou fluxos de trabalho centrados em documentos.

---

## 1. Objetivo e escopo

### 1.1 Objetivos

| ID | Objetivo |
|---|---|
| CHL01 | Avaliar o ClickHouse para ingestão de logs em grande escala e busca analítica |
| CHL02 | Definir um caminho durável de ingestão e armazenamento temporário para picos de tráfego |
| CHL03 | Propor um esquema e uma chave de ordenação que apoiem investigações operacionais |
| CHL04 | Definir estratégias de retenção, camadas, exclusão e arquivamento |
| CHL05 | Integrar o ClickHouse a uma ferramenta de monitoramento e dashboards |
| CHL06 | Identificar riscos de desempenho, disponibilidade, segurança e custo |
| CHL07 | Estabelecer um plano de validação com critérios de aceitação mensuráveis |

### 1.2 Incluído no escopo

- Logs de aplicações, infraestrutura, plataforma, segurança e integrações
- Registros de eventos JSON estruturados ou normalizados de forma equivalente
- Ingestão de alto volume com operações somente de acréscimo
- Filtros por intervalo de tempo, serviço e severidade; correlação por trace; agregações
- Grafana ou interface de monitoramento comparável
- Replicação, fragmentação, backups, integração com armazenamento de objetos e governança operacional
- Tratamento de dados pessoais identificáveis (PII), retenção, controle de acesso, proteção de consultas e gestão de custos

### 1.3 Fora do escopo

- Fluxos de trabalho transacionais que exigem atualizações frequentes de linhas
- ClickHouse como sistema oficial de registro de auditoria ou financeiro
- Classificação irrestrita de relevância para buscas textuais arbitrárias
- Substituição de métricas e traces por logs
- Exclusão automática de dados sem uma política de retenção documentada

---

## 2. Contexto da decisão

Uma plataforma de logs tem duas responsabilidades distintas:

```text
Produtores de logs
    |
    v
Coleta, validação, enriquecimento e armazenamento temporário
    |
    v
Armazenamento e indexação analíticos duráveis
    |
    +--> Consultas de investigação e dashboards
    +--> Alertas e análises agendadas
    +--> Arquivamento, reprodução e governança
```

O banco de dados não deve ser o único buffer entre os produtores de logs e os operadores. Uma indisponibilidade do banco, partição de rede, mudança de esquema ou pico de ingestão não deve causar perda silenciosa imediata de logs. A camada de ingestão precisa expor suas próprias métricas de saúde e tornar visíveis a perda, o atraso, as tentativas e o controle de fluxo.

### 2.1 Premissas da carga de trabalho a confirmar

Os valores a seguir devem ser medidos antes do dimensionamento final:

| Dimensão | Medição necessária |
|---|---|
| Taxa de ingestão | Média e pico de eventos por segundo |
| Volume de dados | Média e pico de bytes por segundo, comprimidos e não comprimidos |
| Tamanho dos eventos | Tamanhos p50, p95, p99 e máximo dos registros |
| Cardinalidade | Quantidade de serviços, hosts, traces, usuários, clientes e campos dinâmicos distintos |
| Perfil de consultas | Buscas recentes e históricas, agregações, dashboards e alertas |
| Concorrência | Usuários simultâneos, consultas agendadas e clientes de API |
| Retenção | Períodos em armazenamento quente, morno, arquivo e exclusão |
| Disponibilidade | Objetivos de ponto e tempo de recuperação |
| Conformidade | Requisitos de residência, exclusão, mascaramento e retenção legal |

Dimensionar apenas com base no volume médio diário é inseguro. O projeto deve levar em conta picos de ingestão, replicação, amplificação temporária de merges, índices, backups e crescimento.

---

## 3. Por que o ClickHouse atende a essa carga

### 3.1 Pontos fortes

- A compressão colunar é eficiente para campos de log repetidos, como serviço, severidade, ambiente e status.
- Tabelas MergeTree são otimizadas para cargas predominantemente de acréscimo e análises orientadas a tempo.
- A execução paralela dá suporte à filtragem e agregação de alto volume.
- Replicação e tabelas distribuídas permitem escala horizontal e disponibilidade.
- Políticas de TTL podem mover ou excluir dados automaticamente.
- Views materializadas podem manter agregações resumidas para dashboards e alertas frequentes.
- SQL oferece uma interface familiar para analistas, operadores, Grafana e automações.
- Discos em armazenamento de objetos e backups permitem camadas de retenção de menor custo.

### 3.2 Restrições

- O ClickHouse não é um banco de dados transacional orientado a linhas.
- Atualizações e exclusões custam mais do que inserções e devem ser operações excepcionais.
- A velocidade das consultas depende bastante do `ORDER BY` da tabela, dos predicados de tempo e do descarte de dados.
- Buscas por substring arbitrária podem percorrer grandes volumes de dados, mesmo quando a consulta parece simples.
- Campos ilimitados e de alta cardinalidade podem reduzir a compressão e aumentar o uso de memória.
- Consultas distribuídas podem multiplicar o trabalho quando o mesmo dashboard executa varreduras amplas.
- Merges em segundo plano consomem CPU, disco e I/O e devem entrar no planejamento de capacidade.
- A replicação melhora a disponibilidade, mas não substitui backups nem retenção em arquivo.

### 3.3 Adequação aos tipos de busca

| Necessidade de busca | Adequação do ClickHouse | Orientação |
|---|---|---|
| Intervalo de tempo, serviço e severidade | Excelente | Use colunas tipadas e uma chave de ordenação sensível ao tempo |
| Contagem de erros por serviço e versão | Excelente | Use agregações e, se necessário, tabelas resumidas |
| Busca por ID de trace ou requisição | Excelente | Armazene os identificadores em colunas próprias |
| Correspondência exata de campo | Excelente | Use colunas tipadas ou campos normalizados materializados |
| Busca por prefixo em campo limitado | Boa | Considere um índice de descarte de dados adequado e teste-o |
| Busca por substring arbitrária no texto da mensagem | Variável | Teste com dados realistas; sem projeto adicional, espere varreduras |
| Classificação por relevância aproximada | Limitada | Considere um mecanismo de busca ou fluxo especializado |
| Alterações frequentes nos registros | Pouco adequado | Mantenha o estado mutável em outro banco |

---

## 4. Arquitetura de destino

```text
 Aplicações, hosts, Kubernetes, gateways e ferramentas de segurança
                         |
                         v
        OpenTelemetry Collector / Vector / Fluent Bit
       analisar, agrupar, enriquecer, redigir, amostrar, rotear, repetir
                         |
             +-----------+------------+
             |                        |
       Buffer durável de eventos  Caminho de mensagens inválidas
       Kafka / Redpanda /         ou rejeitadas
       fila em armazenamento
       de objetos
             |
             v
       Consumidores de ingestão do ClickHouse
      inserções assíncronas, idempotência,
      compressão e validação de esquema
             |
   +---------+------------------+
   |                            |
Eventos brutos de logs      Dados derivados
Tabelas MergeTree           views materializadas,
                            agregações e alertas
   |                            |
   +-------------+--------------+
                 |
          Grafana / API / clientes SQL
                 |
      dashboards, investigação e alertas

Armazenamento ClickHouse:
  disco local rápido para dados quentes
  armazenamento de objetos para dados mornos/frios e backups
  nós replicados coordenados pelo ClickHouse Keeper
```

### 4.1 Responsabilidades de ingestão

O Collector ou serviço de ingestão deve:

- Adicionar um horário de ingestão confiável, além do horário informado pelo produtor.
- Normalizar severidade, identidade do serviço, ambiente, região e tipo de origem.
- Preservar a mensagem ou o conteúdo original quando a política permitir.
- Extrair IDs de trace, span, requisição e correlação para campos próprios.
- Redigir ou tokenizar valores sensíveis antes que cheguem ao armazenamento compartilhado.
- Agrupar registros e comprimir inserções para reduzir custos de rede e de partes.
- Limitar novas tentativas e expor o controle de fluxo, em vez de repetir indefinidamente.
- Encaminhar registros malformados a um caminho de mensagens inválidas com uma justificativa útil.
- Rejeitar ou colocar em quarentena registros que violem limites de tamanho, esquema ou segurança.

O Collector não é a fonte oficial de garantia de entrega. Se a perda de logs for inaceitável, use um buffer durável ou uma fila no produtor com período de retenção definido.

### 4.2 Topologias de implantação do ClickHouse

| Topologia | Descrição | Adequada quando |
|---|---|---|
| Servidor único | Um nó ClickHouse com armazenamento local | Desenvolvimento, prova de conceito ou dados não críticos |
| Par replicado | Duas ou mais réplicas por shard, coordenadas pelo Keeper | Disponibilidade de produção com escala moderada |
| Cluster fragmentado | Vários shards, cada um com réplicas | Ingestão ou armazenamento excede a capacidade prática de um nó |
| ClickHouse gerenciado | O provedor opera a infraestrutura e parte das preocupações de confiabilidade | A equipe quer capacidade analítica sem operar o cluster |

O primeiro projeto de produção deve preferir a menor topologia que atenda aos requisitos de disponibilidade e vazão. A fragmentação aumenta a complexidade operacional e do roteamento de consultas; deve ser justificada por medições de capacidade, e não presumida apenas porque o volume parece “enorme”.

---

## 5. Modelo de dados

### 5.1 Tabela recomendada para logs brutos

O esquema exato deve ser adaptado ao contrato de logs, mas dimensões estáveis de investigação devem ser colunas de primeira classe. Atributos dinâmicos ou raramente consultados podem permanecer em um mapa limitado ou em uma representação JSON.

```sql
CREATE TABLE observability.logs_local
(
    event_time       DateTime64(3, 'UTC'),
    ingest_time      DateTime64(3, 'UTC') DEFAULT now64(3),
    event_date       Date MATERIALIZED toDate(event_time),

    service_name     LowCardinality(String),
    environment      LowCardinality(String),
    region           LowCardinality(String),
    source_type      LowCardinality(String),
    host_name        String,
    container_name   String,
    severity         LowCardinality(String),
    log_level        LowCardinality(String),

    trace_id         String,
    span_id          String,
    request_id       String,
    correlation_id   String,

    logger           LowCardinality(String),
    message          String,
    error_type       LowCardinality(String),
    error_message    String,
    http_method      LowCardinality(String),
    http_route       String,
    status_code      Nullable(UInt16),
    duration_ms      Nullable(UInt32),

    attributes       Map(LowCardinality(String), String),
    raw_payload      String
)
ENGINE = ReplicatedMergeTree(
    '/clickhouse/tables/{shard}/observability/logs_local',
    '{replica}'
)
PARTITION BY toYYYYMM(event_date)
ORDER BY
(
    event_date,
    service_name,
    environment,
    severity,
    event_time,
    trace_id
)
TTL event_time + INTERVAL 30 DAY TO VOLUME 'warm',
    event_time + INTERVAL 180 DAY DELETE;
```

O exemplo é um ponto de partida, não um esquema universal. Em particular, o `ORDER BY` deve ser escolhido com base em consultas reais. Adicionar todos os campos possíveis à chave de ordenação é prejudicial: aumenta o tamanho do índice e pode reduzir a eficácia do descarte de dados.

### 5.2 Tabela distribuída para consultas

Em um cluster, exponha aos clientes uma tabela distribuída, em vez de exigir que o Grafana conheça os detalhes dos shards:

```sql
CREATE TABLE observability.logs
AS observability.logs_local
ENGINE = Distributed(
    'observability_cluster',
    'observability',
    'logs_local',
    cityHash64(service_name, event_date)
);
```

A expressão de fragmentação deve ser testada com a carga real. Ela deve distribuir as gravações de forma equilibrada e evitar concentrar serviços ou clientes de alto volume em um único shard.

### 5.3 Orientações para a chave de ordenação

A chave de ordenação é o principal projeto de acesso físico aos dados. Ela deve refletir os filtros mais frequentes e preservar a localidade temporal.

Bons candidatos normalmente incluem:

- Data do evento ou intervalo de tempo
- Serviço ou limite entre clientes, quando são filtros comuns
- Ambiente ou região, quando reduzem significativamente as varreduras
- Um pequeno número de dimensões operacionais estáveis
- Horário do evento para investigações ordenadas

Evite incluir diretamente na chave de ordenação, sem evidências:

- Texto de mensagem sem limite
- IDs de requisição quase sempre únicos como primeira dimensão
- Atributos altamente voláteis
- Todas as chaves de um mapa de atributos dinâmicos

Use `EXPLAIN indexes = 1`, logs de consulta e dados representativos para verificar se os predicados reduzem os granules percorridos.

### 5.4 Índices de descarte de dados e projeções

Índices de descarte de dados podem ajudar em campos que não são práticos na chave de ordenação primária, mas não tornam barata toda consulta textual. Índices candidatos devem ser validados com distribuições e planos de consulta semelhantes aos de produção.

Possíveis candidatos:

- Índices no estilo Bloom filter para identificadores exatos ou semelhantes a tokens, como ID de trace
- Índices de conjunto para valores categóricos pequenos e limitados
- Estratégias de tokens ou n-gramas para buscas selecionadas em mensagens
- Projeções para agregações frequentes ou padrões alternativos de acesso

Índices e projeções aumentam o custo de gravação, merges, armazenamento e operação. Antes de adotá-los, um benchmark de consultas deve demonstrar uma redução significativa nos bytes percorridos.

---

## 6. Retenção e camadas de armazenamento

Uma plataforma de logs deve distinguir disponibilidade operacional de preservação por tempo indeterminado.

| Camada | Período de exemplo | Armazenamento | Finalidade |
|---|---:|---|---|
| Quente | 1 a 7 dias | NVMe local rápido ou equivalente | Investigação interativa de incidentes |
| Morna | 7 a 30/90 dias | Disco replicado de menor custo ou armazenamento de objetos | Análise de tendências e investigações recorrentes |
| Arquivo | 90 dias até o limite da política | Armazenamento de objetos em arquivos colunares | Reprodução, suporte a auditoria e retenção legal ou de negócio |
| Excluída | Conforme a política | Sem cópia consultável retida | Controle de privacidade e custos |

Use políticas TTL do ClickHouse para mover dados entre volumes ou excluí-los, mas valide que a movimentação por TTL não sobrecarregue o armazenamento ou os merges. Mantenha um arquivo em armazenamento de objetos quando:

- Os dados precisarem ser reproduzidos após uma falha do cluster.
- A retenção for mais longa do que o período de consulta interativa.
- Uma retenção legal ou de conformidade exigir preservação independente.
- Um esquema ou analisador futuro puder precisar ser aplicado novamente.

A retenção só está completa depois que backups, réplicas, cópias em armazenamento de objetos e comportamento de exclusão tiverem sido testados.

### 6.1 Orientações para particionamento

Particione por uma unidade de tempo ampla, normalmente mês ou dia, dependendo do volume e das operações de retenção. Evite criar uma partição para cada serviço, cliente ou hora, a menos que haja uma razão operacional comprovada. Partições em excesso criam sobrecarga de metadados e dificultam merges e administração.

O tamanho correto da partição depende da taxa de inserção, das ações de retenção e da topologia do cluster. Meça a quantidade de partes por partição e o comportamento dos merges sob carga realista.

---

## 7. Integração com ferramentas de consulta e monitoramento

O Grafana é uma interface inicial adequada para monitoramento e exploração, pois pode combinar consultas de logs do ClickHouse com métricas, traces, anotações e dashboards. A integração deve ser tratada como um cliente de consulta controlado, não como acesso irrestrito ao banco de dados.

### 7.1 Padrões de consulta

Consultas comuns de dashboards e investigação devem sempre incluir um predicado de tempo limitado:

```sql
SELECT
    event_time,
    service_name,
    severity,
    trace_id,
    message
FROM observability.logs
WHERE event_time >= $__timeFrom()
  AND event_time < $__timeTo()
  AND service_name IN (${service:sqlstring})
  AND environment = ${environment:sqlstring}
  AND severity IN ('ERROR', 'FATAL')
ORDER BY event_time DESC
LIMIT 5000;
```

Painéis agregados devem evitar retornar linhas brutas quando contagens ou taxas forem suficientes:

```sql
SELECT
    toStartOfMinute(event_time) AS minute,
    service_name,
    count() AS error_count
FROM observability.logs
WHERE event_time >= $__timeFrom()
  AND event_time < $__timeTo()
  AND severity IN ('ERROR', 'FATAL')
GROUP BY minute, service_name
ORDER BY minute, service_name;
```

### 7.2 Governança de consultas

- Exija um intervalo de tempo para consultas interativas.
- Defina limites de tempo de execução, memória e linhas de resultado para o perfil do dashboard.
- Prefira perfis somente de leitura para o Grafana.
- Use contas de serviço separadas para ingestão, dashboards, analistas e administração.
- Use políticas de linha quando for necessário isolar clientes ou domínios.
- Monitore consultas lentas, bytes percorridos, memória, cancelamentos e sessões concorrentes.
- Evite painéis que executem muitas varreduras amplas quase idênticas.
- Use tabelas resumidas para painéis gerais de alta frequência.
- Ofereça um caminho de detalhamento das agregações até eventos brutos em intervalos limitados.

### 7.3 Correlação com métricas e traces

Os logs devem carregar os mesmos atributos de recurso e contexto usados pelo restante da plataforma de observabilidade:

```text
service.name
service.version
deployment.environment
cloud.region
host.name
k8s.namespace.name
k8s.pod.name
trace_id
span_id
request_id
```

A ferramenta de monitoramento deve permitir que a pessoa responsável passe de:

```text
Alerta ou anomalia em métrica
        -> serviço e intervalo de tempo
        -> logs filtrados
        -> ID de trace e detalhes do trace
        -> implantação, dependência ou runbook
```

A correlação depende mais da consistência de identidade e da semântica de horários do que de armazenar todos os sinais no ClickHouse.

---

## 8. Desempenho e confiabilidade da ingestão

### 8.1 Estratégia de inserção

Use inserções em lotes e comprimidas. Evite uma inserção para cada registro de log; isso cria partes em excesso e pressiona os merges em segundo plano. O Collector ou buffer deve agrupar registros por esquema compatível e tabela de destino.

Inserções assíncronas podem reduzir a coordenação no lado do cliente, mas precisam de uma política explícita de durabilidade e confirmação. O sistema deve definir se uma confirmação significa que os dados foram:

- aceitos pelo cliente;
- aceitos em um buffer em memória;
- persistidos pelo ClickHouse; ou
- registrados de forma durável em uma fila externa.

Essas garantias são diferentes e não devem ser descritas simplesmente como “entregues”.

### 8.2 Controle de fluxo e política de perda

Quando o ClickHouse estiver indisponível ou lento demais, o sistema precisa de uma política explícita:

| Condição | Comportamento recomendado |
|---|---|
| Falha transitória curta | Repetir com espera exponencial limitada |
| Pressão prolongada no banco | Armazenar temporariamente em fila durável ou armazenamento de objetos |
| Registro inválido | Enviar para armazenamento de mensagens inválidas com a justificativa |
| Mensagem acima do limite | Truncar conforme a política e preservar metadados |
| Capacidade do buffer esgotada | Aplicar amostragem ou prioridade de perda documentada |
| Incompatibilidade de esquema | Encaminhar para quarentena e alertar responsáveis pela ingestão |

Nunca permita que novas tentativas sem limite consumam toda a memória ou o disco do Collector. A política de perda deve diferenciar logs de depuração de eventos de segurança, auditoria ou erro cujo impacto de negócio seja diferente.

### 8.3 Deduplicação

A entrega pelo menos uma vez costuma ser o padrão prático. Se eventos duplicados forem inaceitáveis, gere um identificador estável no produtor ou Collector e projete uma estratégia de deduplicação. A deduplicação exata pode ser cara em volumes muito altos; muitos sistemas operacionais aceitam duplicatas ocasionais e tornam os dashboards resistentes por meio da semântica de agregação.

Não use `ReplacingMergeTree` como solução genérica para duplicatas de ingestão sem compreender o comportamento eventual dos merges, a semântica das consultas e o custo de substituir linhas.

---

## 9. Segurança, privacidade e governança

Logs frequentemente contêm credenciais, tokens, dados pessoais, URLs internas, corpos de requisição e erros de banco de dados. A capacidade do ClickHouse não elimina a necessidade de minimização de dados.

### 9.1 Controles

- Defina um contrato de logging aprovado para cada serviço.
- Redija segredos e cabeçalhos de autorização no produtor ou no limite do Collector.
- Não registre corpos completos de requisições ou respostas por padrão.
- Tokenize ou aplique hash a identificadores quando a investigação não exigir o valor original.
- Criptografe o tráfego entre produtores, Collectors, nós ClickHouse e clientes.
- Criptografe discos, backups e arquivos em armazenamento de objetos.
- Use perfis de menor privilégio e separe acessos operacionais e analíticos.
- Registre o acesso a conjuntos de logs sensíveis.
- Aplique políticas de linha ou bancos separados para isolamento entre clientes.
- Defina procedimentos de exclusão e retenção legal antes da entrada em produção.
- Classifique campos para que retenção e visibilidade sejam governadas de forma consistente.

### 9.2 Governança de esquema

Mudanças de esquema devem ser compatíveis e observáveis. Adicionar um campo costuma ser mais fácil do que mudar o tipo ou o significado de um campo existente. Defina responsáveis por:

- nomes e tipos canônicos dos campos;
- valores de severidade e status;
- semântica dos horários;
- identidade de serviço e ambiente;
- classificação de campos sensíveis;
- exceções de retenção;
- versões de analisadores e Collectors.

Um registro de esquemas ou contrato de logs versionado é útil quando muitos produtores são implantados de forma independente.

---

## 10. Disponibilidade, backup e recuperação de desastre

### 10.1 Domínios de falha

Réplicas de produção devem ser distribuídas entre domínios de falha, como hosts, racks, zonas de disponibilidade ou infraestrutura equivalente. Uma réplica no mesmo domínio de falha físico não oferece alta disponibilidade significativa.

O projeto deve testar:

- uma réplica indisponível;
- um shard indisponível;
- perda de quórum do Keeper;
- reinicialização do Collector durante um pico;
- partição de rede entre Collectors e ClickHouse;
- esgotamento de disco;
- indisponibilidade do armazenamento de objetos;
- implantação de esquema malformado;
- reprodução em grande escala após a recuperação.

### 10.2 Objetivos de recuperação

Documente objetivos separados para:

| Classe de dados | Exemplo de RPO | Exemplo de RTO |
|---|---:|---:|
| Logs de depuração | Minutos ou melhor esforço | Horas |
| Logs de erro e operacionais | Segundos a minutos | Menos de uma hora |
| Logs relevantes para segurança ou auditoria | Definido pela política | Definido pela política |

A replicação protege contra algumas falhas de nós, mas não contra exclusões indevidas, dados corrompidos, erros operacionais ou falhas lógicas. Use backups e cópias independentes em armazenamento de objetos e faça testes de restauração regularmente.

---

## 11. Modelo de capacidade e custos

Um modelo realista de capacidade deve incluir:

```text
Bytes brutos ingeridos por dia
x fator de compressão e codificação
x fator de replicação
x período de retenção quente e morna
+ espaço temporário para merges e operações
+ índices e projeções
+ metadados e backups
+ margem para crescimento e falhas
```

Acompanhe estas medidas operacionais:

- eventos e bytes ingeridos por segundo;
- tamanho dos lotes de inserção e latência de inserção;
- registros rejeitados e enviados para mensagens inválidas;
- atraso entre o horário do evento e a disponibilidade para consulta;
- partes ativas e partes por partição;
- fila de merges e duração dos merges;
- utilização do disco e previsão de esgotamento;
- bytes comprimidos e não comprimidos;
- latência de consultas por percentil;
- bytes percorridos por consulta;
- picos de memória e cancelamentos de consultas;
- atraso de réplica e falhas em consultas distribuídas.

A otimização de custos deve começar pela qualidade dos logs e pela retenção. Armazenar campos que ninguém consulta, duplicar conteúdo bruto sem necessidade e reter logs de depuração de baixo valor por anos costuma custar mais do que ajustes de consulta conseguem recuperar.

---

## 12. Alternativas e limites de aplicação

| Opção | Ponto forte | Quando pode ser preferível |
|---|---|---|
| ClickHouse | SQL analítico de alta vazão e agregação eficiente | Logs estruturados, grande volume e exploração por tempo |
| Loki | Busca operacional de logs integrada ao Grafana e indexação baseada em rótulos | Cargas sensíveis a custo, com rótulos limitados e necessidades de busca mais simples |
| OpenSearch ou Elasticsearch | Busca em documentos, análise textual e ecossistema para consultas por relevância | Busca aproximada, linguística ou centrada em documentos é essencial |
| Armazenamento de objetos com mecanismo de consulta | Retenção longa e reprodução a baixo custo | Cargas voltadas a arquivo e consultas pouco frequentes |
| PostgreSQL | Semântica transacional forte e operação simples em pequena escala | Baixo volume ou metadados de fluxo de trabalho, não grandes volumes de logs brutos |
| Serviço de logs nativo da nuvem | Ingestão, retenção e integrações gerenciadas | A organização prioriza reduzir o esforço operacional da plataforma |

Uma arquitetura híbrida costuma ser razoável: ClickHouse para análise operacional de alto volume, armazenamento de objetos para arquivo e um mecanismo de busca separado somente para casos que realmente exigem busca textual avançada.

---

## 13. Riscos e mitigações

| Risco | Impacto | Mitigação |
|---|---|---|
| Projeto inadequado de `ORDER BY` | Consultas lentas e alto custo de varredura | Registre padrões de consulta e compare chaves candidatas por benchmark |
| Campos dinâmicos sem limite | Alto uso de memória e baixa compressão | Promova campos estáveis; limite ou filtre atributos dinâmicos |
| Inserções pequenas em excesso | Muitas partes e pressão nos merges | Agrupe e comprima no Collector ou consumidor da fila |
| Buscas sem limite no texto das mensagens | Varreduras caras e dashboards lentos | Prefira campos estruturados; teste índices textuais ou use um mecanismo de busca |
| Retenção sem camadas | Crescimento rápido do armazenamento | Use TTL, armazenamento de objetos e políticas documentadas de exclusão |
| Banco usado como único buffer | Perda de logs durante indisponibilidades | Use buffer durável e caminho para mensagens inválidas |
| Fragmentação prematura | Mais complexidade operacional e de consultas | Escale verticalmente e replique antes de adicionar shards, quando possível |
| Dados sensíveis nos logs | Exposição de privacidade e segurança | Redija os dados na origem e imponha controles de acesso |
| Explosão de consultas dos dashboards | Saturação do cluster | Agregue, use cache, limite e revise os painéis |
| Pressão de réplicas ou merges | Atraso na ingestão e instabilidade | Reserve capacidade e alerte sobre filas e margem de disco |
| Tratar réplicas como backups | Perda lógica irrecuperável | Mantenha backups independentes e teste restaurações |

---

## 14. Prova de conceito e critérios de aceitação

A prova de conceito deve usar distribuições de eventos semelhantes às de produção, incluindo tamanhos realistas de mensagens, cardinalidade, picos, taxas de erro e concorrência de consultas.

### 14.1 Cenários de teste

1. Ingestão média contínua por pelo menos 24 horas.
2. Ingestão de pico na taxa de burst prevista, com margem de capacidade.
3. Reinicialização do Collector e de um nó ClickHouse durante a ingestão.
4. Interrupção de rede e reprodução posterior a partir do buffer durável.
5. Investigação de erros recentes por serviço, ambiente, severidade e intervalo de tempo.
6. Buscas por ID de trace, ID de requisição e campos exatos.
7. Painéis de agregação executados simultaneamente a buscas de logs brutos.
8. Consulta histórica a dados em armazenamento morno ou arquivo.
9. Falha e recuperação de réplica.
10. Pressão de capacidade em disco ou armazenamento de objetos.
11. Tratamento de esquema inválido e mensagem acima do limite.
12. Restauração de backup em um ambiente isolado.

### 14.2 Exemplos de critérios de aceitação

| Área | Meta de exemplo |
|---|---|
| Durabilidade | Nenhuma perda sem explicação durante uma indisponibilidade testada de Collector ou nó |
| Atualidade | Atraso p95 entre ingestão e consulta dentro da meta operacional acordada |
| Investigação | Consultas comuns por serviço e intervalo de tempo atendem à latência p95 acordada |
| Agregação | Painéis padrão permanecem dentro do orçamento de latência sob concorrência |
| Controle de fluxo | Crescimento do buffer, reprodução e alertas são observáveis e limitados |
| Disponibilidade | A falha de uma réplica não torna indisponível o caminho de consulta suportado |
| Recuperação | Procedimentos de restauração e reprodução atendem ao RTO e RPO documentados |
| Governança | Dados sensíveis de teste são redigidos e o acesso pode ser auditado |
| Custo | Armazenamento e computação permanecem dentro do orçamento mensal aprovado |

As metas numéricas devem ser escolhidas com base no fluxo real de monitoramento, e não copiadas de um benchmark genérico.

---

## 15. Caminho de adoção recomendado

### Fase 1: Descoberta do contrato e da carga de trabalho

- Faça o inventário dos produtores de logs e formatos atuais.
- Defina campos obrigatórios e sensíveis, classes de retenção e responsabilidades.
- Registre medições representativas de ingestão e consultas.
- Identifique os primeiros fluxos operacionais que devem ser atendidos.

### Fase 2: Prova de conceito controlada

- Implante uma topologia pequena de ClickHouse.
- Use um Collector e um buffer durável quando os requisitos de perda justificarem.
- Teste duas ou três chaves de ordenação candidatas com dados semelhantes aos de produção.
- Conecte o Grafana com acesso somente de leitura e consultas limitadas.
- Meça atraso de ingestão, redução de varredura, pressão de merges e custos.

### Fase 3: Base de produção

- Adicione replicação, Keeper, backups, integração com armazenamento de objetos e monitoramento.
- Implemente redação, validação de esquema, tratamento de mensagens inválidas e TTLs de retenção.
- Crie dashboards operacionais para o ClickHouse e o pipeline de ingestão.
- Documente procedimentos de indisponibilidade, reprodução, exclusão e restauração.

### Fase 4: Escala e otimização

- Adicione shards somente quando limites medidos de armazenamento ou ingestão exigirem.
- Introduza agregações resumidas e views materializadas para dashboards estáveis de alto volume.
- Ajuste as camadas quente e morna conforme os padrões de acesso.
- Revise regularmente consultas caras e a qualidade dos logs produzidos.

---

## 16. Recomendação

Adote o ClickHouse como índice analítico primário de logs de alto volume se a carga for principalmente estruturada, somente de acréscimo, limitada por tempo e focada em filtragem e agregação operacional. Use um Collector durável ou buffer de eventos; não grave diretamente dos produtores no banco sem proteção. Armazene os campos mais consultados como colunas tipadas, escolha a chave de ordenação com base em padrões de consulta medidos e mantenha limitados os dados dinâmicos arbitrários.

A arquitetura mínima de produção deve incluir:

- logging estruturado e contrato de eventos versionado;
- OpenTelemetry Collector, Vector ou Fluent Bit na borda;
- armazenamento temporário durável compatível com os requisitos acordados de perda e recuperação;
- tabelas MergeTree replicadas no ClickHouse;
- arquivo em armazenamento de objetos e backups testados;
- políticas TTL para camadas quente, morna e exclusão;
- Grafana ou equivalente com acesso somente de leitura e limites de recursos para consultas;
- métricas e alertas para atraso de ingestão, pressão de merges, disco, replicação e custo de consultas;
- redação de dados, privilégio mínimo e acesso auditável a dados sensíveis.

Não aprove o esquema final nem o tamanho do cluster apenas com base na documentação. Aprove-os depois que a prova de conceito demonstrar a taxa de ingestão, latência de consultas, comportamento de recuperação, custo de retenção e controles de privacidade necessários com dados representativos.
