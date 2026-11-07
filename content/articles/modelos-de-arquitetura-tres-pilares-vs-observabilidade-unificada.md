# Modelos de Arquitetura: 3 Pilares vs Observabilidade Unificada

## Resumo executivo

A observabilidade costuma ser explicada por meio de três pilares: **métricas, logs e traces**. Esse modelo continua sendo útil porque cada sinal tem características, custos, necessidades de retenção e usos operacionais diferentes.

O modelo dos três pilares se torna insuficiente quando as equipes precisam investigar um problema distribuído que atravessa serviços, infraestrutura, jornadas de usuário e resultados de negócio. Um **modelo unificado de dados de observabilidade** trata a telemetria como evidências relacionadas sobre entidades e eventos. Ele conecta os sinais por meio de identidades comuns, marcações de tempo, propagação de contexto, atributos de recursos, convenções semânticas e relacionamentos.

Essas arquiteturas não são mutuamente exclusivas:

```text
Três pilares = produção de sinais, armazenamento e especialização operacional
Modelo unificado = correlação, descoberta, análise e tomada de decisão
```

A arquitetura recomendada é **híbrida**:

1. Produzir métricas, logs, traces, perfis, eventos e verificações com instrumentação adequada a cada finalidade.
2. Padronizar identidade e contexto em toda a telemetria.
3. Coletar e governar os dados por meio de um pipeline comum, como o OpenTelemetry Collector.
4. Armazenar os dados em backends especializados, escolhidos pelas suas características de consulta e retenção.
5. Oferecer uma experiência unificada de investigação que conecte observações relacionadas.

O modelo unificado não deve exigir que todos os sinais sejam armazenados em um único banco de dados. A unificação é, sobretudo, um **contrato de dados e um modelo de relacionamentos**, não necessariamente um repositório físico único.

---

## 1. Objetivo e escopo

Esta análise compara duas formas de estruturar uma arquitetura de observabilidade e descreve maneiras práticas de aplicar observabilidade a plataformas de software.

### 1.1 Objetivos

| ID | Objetivo |
|---|---|
| OBSM01 | Explicar os pontos fortes e as limitações do modelo dos três pilares |
| OBSM02 | Definir um modelo unificado de dados de observabilidade |
| OBSM03 | Comparar as consequências para armazenamento, operação e investigação |
| OBSM04 | Descrever padrões práticos de aplicação da observabilidade |
| OBSM05 | Recomendar um caminho de adoção compatível com OpenTelemetry |

### 1.2 Incluído no escopo

- Métricas, logs, traces, perfis, eventos e verificações sintéticas
- Contexto de serviços, infraestrutura, aplicações, dependências, usuários e negócios
- Coleta, correlação, armazenamento, consulta, alertas e resposta a incidentes
- Fluxos de trabalho de observabilidade orientados por SLOs e exploração
- Governança da plataforma, custos, privacidade e qualidade dos dados

### 1.3 Fora do escopo

- Escolher um fornecedor comercial de observabilidade
- Definir um único design de dashboard para todas as equipes
- Tratar a telemetria como registro de auditoria com validade legal
- Substituir plataformas de dados de domínio, SIEMs ou sistemas financeiros oficiais

---

## 2. O que significa observabilidade

O monitoramento verifica se uma condição conhecida está saudável. A observabilidade avalia se as evidências disponíveis são suficientes para explicar o estado interno de um sistema a partir dos seus resultados externos.

Essa distinção é prática, não semântica:

| Atividade | Pergunta principal | Resultado típico |
|---|---|---|
| Monitoramento | Uma condição conhecida está fora do intervalo esperado? | Alerta, dashboard, limite, taxa de consumo do orçamento de erro do SLO |
| Solução de problemas | Qual componente está falhando agora? | Linha do tempo, visão de dependências, agrupamento de erros |
| Observabilidade | O que está acontecendo, por que está acontecendo e o que mais foi afetado? | Investigação correlacionada entre sinais e entidades |

A observabilidade é valiosa quando o sistema tem modos de falha desconhecidos, comunicação assíncrona, infraestrutura dinâmica, dependências de terceiros ou vários times compartilhando o mesmo fluxo de transação.

### 2.1 As quatro perguntas

Uma capacidade útil de observabilidade deve ajudar a responder:

1. **O que mudou?** Implantação, configuração, tráfego, dependência, esquema ou mudança de infraestrutura.
2. **O que foi afetado?** Serviços, endpoints, clientes, regiões, usuários, pedidos ou capacidades de negócio.
3. **Por que foi afetado?** Erro, saturação, latência, falha de dependência, capacidade, caminho de código ou problema de qualidade dos dados.
4. **O que deve acontecer em seguida?** Mitigar, reverter, escalar, corrigir, comunicar ou aprimorar o sistema.

---

## 3. Modelo A: os três pilares

### 3.1 Sinais

| Sinal | Unidade básica | Melhor uso | Principal limitação |
|---|---|---|---|
| Métricas | Medida numérica ao longo do tempo | Tendências, alertas, SLOs, capacidade e agregação | Pouco detalhe sobre uma requisição ou evento específico |
| Logs | Registro estruturado ou não estruturado | Fatos detalhados, mensagens de erro e eventos discretos | Busca cara e facilidade para gerar ruído |
| Traces | Spans temporizados que formam o caminho de uma requisição | Causalidade distribuída, detalhamento de latência e análise de dependências | Amostragem e lacunas de instrumentação podem ocultar evidências |

O modelo é fácil de explicar e se mapeia naturalmente para plataformas especializadas:

```text
                         Observabilidade
                              |
          +-------------------+-------------------+
          |                   |                   |
       Métricas              Logs                Traces
 séries temporais    registros de eventos   relações entre spans
          |                   |                   |
    backend de métricas  backend de logs   backend de traces
```

### 3.2 Pontos fortes

- Responsabilidades claras e ferramentas conhecidas.
- Cada sinal pode usar um mecanismo de armazenamento e um período de retenção adequados.
- As métricas oferecem uma camada de alertas relativamente estável e econômica.
- Os logs preservam detalhes da aplicação e do contexto operacional.
- Os traces representam a causalidade em fluxos síncronos e assíncronos.
- As equipes podem adotar um sinal de cada vez.

### 3.3 Limitações

- As equipes podem operar três ferramentas desconectadas e copiar identificadores manualmente entre elas.
- Uma linha de log pode usar um nome de serviço diferente do trace, tornando a correlação pouco confiável.
- O modelo não representa naturalmente perfis, mudanças de implantação, topologia ou eventos de negócio.
- Diferentes equipes podem definir o mesmo conceito com nomes e dimensões incompatíveis.
- Os limites entre armazenamentos podem se tornar limites para a investigação.
- Os alertas frequentemente detectam sintomas sem indicar qual cliente ou capacidade de negócio foi afetado.

Assim, os três pilares são um **modelo útil para emissão e backends**, mas um **modelo incompleto para investigação**.

---

## 4. Modelo B: um modelo unificado de dados de observabilidade

Um modelo unificado organiza evidências em torno de entidades e relacionamentos comuns. Os sinais continuam distintos, mas o usuário pode navegar entre eles usando dimensões compartilhadas.

### 4.1 Entidades principais

```text
Cliente / usuário / operação de negócio
              |
       contexto do trace
              |
Serviço -> endpoint -> dependência -> recurso de infraestrutura
   |          |             |                    |
métricas    spans          logs                perfis
   |          |             |                    |
        implantação / versão / mudança de configuração
```

Os conceitos compartilhados mínimos são:

| Conceito | Exemplos | Por que é importante |
|---|---|---|
| Entidade | Serviço, host, pod, banco de dados, fila, endpoint | Define quem produziu ou recebeu a evidência |
| Identidade do recurso | `service.name`, ambiente, cluster, região, versão | Torna os dados localizáveis e agrupáveis |
| Operação | Rota HTTP, tarefa, consumidor, classe de consulta ao banco | Define o trabalho que está sendo executado |
| Contexto | ID do trace, ID do span, span pai, contexto do cliente ou da requisição | Conecta evidências entre diferentes limites |
| Tempo | Horário do evento, início/fim, horário de ingestão | Permite ordenar eventos e analisar latência |
| Medida | Contagem, duração, tamanho, utilização, taxa de erro | Permite agregação e alertas |
| Evento | Exceção, implantação, mudança de feature flag, evento de negócio | Explica transições de estado e mudanças |
| Relacionamento | Chama, publica, consome, depende de, afeta | Dá suporte à análise de topologia e causalidade |
| Classificação | Severidade, status, resultado, ambiente, domínio | Permite filtragem e aplicação de políticas |

### 4.2 Formato canônico de registro

O exemplo a seguir é conceitual; ele não exige serializar todos os sinais da mesma forma:

```json
{
  "observed_at": "2026-09-11T12:30:45.123Z",
  "event_type": "span",
  "entity": {
    "service.name": "checkout-api",
    "deployment.environment": "production",
    "service.version": "2026.09.1",
    "cloud.region": "us-east-1"
  },
  "operation": {
    "name": "POST /orders",
    "type": "http.server"
  },
  "context": {
    "trace_id": "...",
    "span_id": "...",
    "parent_span_id": "..."
  },
  "outcome": {
    "status": "error",
    "error.type": "PaymentTimeout"
  },
  "attributes": {
    "http.request.method": "POST",
    "server.address": "orders.example.com"
  },
  "relationships": [
    {"type": "calls", "target": "payment-service"}
  ]
}
```

Métricas, logs e traces têm formatos nativos diferentes. Um ponto de dado de métrica não precisa de ID de span, e um log não precisa se transformar em span. O requisito importante é que atributos e relacionamentos comuns estejam disponíveis quando fizerem sentido.

### 4.3 Unificado não significa um único backend

Há três significados diferentes para “unificado”:

| Significado | Descrição | Avaliação |
|---|---|---|
| Coleta unificada | Um agente ou pipeline recebe vários sinais | Geralmente desejável |
| Contrato de dados unificado | Identidade, contexto, semântica e relacionamentos compartilhados | Fortemente recomendado |
| Armazenamento unificado | Todos os dados são copiados para uma única plataforma física | Depende do contexto e pode ter custo alto |

As duas primeiras formas costumam oferecer a maior parte do benefício arquitetural. Um único backend pode simplificar a descoberta, mas também pode aumentar custos, limitar consultas, criar riscos de migração ou não se adequar a tipos de dados especializados.

---

## 5. Comparação direta

| Dimensão | Três pilares | Modelo de dados unificado |
|---|---|---|
| Abstração principal | Tipo de sinal | Evidências sobre entidades e relacionamentos |
| Fluxo de trabalho principal | Abrir a ferramenta de métricas, logs ou traces | Partir de uma entidade ou sintoma e navegar pelas evidências relacionadas |
| Estratégia de armazenamento | Backend especializado para cada sinal | Backends especializados por trás de uma camada compartilhada de consulta ou correlação |
| Alertas | Principalmente regras de métricas e logs | Métricas com contexto adicional de traces, eventos, topologia e mudanças |
| Análise de causa raiz | Correlação manual por IDs e horários | Navegação baseada em relacionamentos e dimensões comuns |
| Integração de equipes | Instrumentar um sinal | Instrumentar e atender a requisitos de identidade e semântica |
| Controle de custos | Cotas e retenção por sinal | Controles por sinal, além de governança de entidades, cardinalidade e relacionamentos |
| Modo de falha | Os dados existem, mas estão desconectados | Uma identidade compartilhada incorreta pode conectar dados de forma errada ou não conectá-los |
| Melhor aplicação | Sistemas menores e limites operacionais claros | Plataformas distribuídas e investigações entre equipes |
| Principal risco | Fragmentação de ferramentas | Complexidade e normalização excessiva |

### 5.1 Matriz de decisão

| Situação | Ênfase recomendada |
|---|---|
| Aplicação única com uma equipe pequena | Três pilares com correlação básica |
| Vários microsserviços e mensageria assíncrona | Identidade unificada e contexto de trace |
| Prática madura de SLO e plantão de operação | Métricas em primeiro lugar, com detalhamento unificado |
| Alto volume de logs e regras estritas de retenção | Armazenamento especializado de logs com metadados compartilhados |
| Incidentes frequentes relacionados a implantações | Eventos unificados de implantação, versão e mudança |
| Análise de impacto para clientes | Contexto de negócio unificado com controles de privacidade |
| Plataforma multi-inquilino de grande porte | Contrato unificado com isolamento rigoroso entre clientes |
| Requisitos de auditoria altamente regulados | Observabilidade mais um modelo de auditoria oficial separado |

---

## 6. Arquitetura de referência

```text
 Aplicações, plataformas e clientes
   |         |          |           |          |
   |     métricas      logs      traces    perfis/eventos
   +---------+----------+-----------+----------+
                     |
          APIs e SDKs do OpenTelemetry,
          convenções semânticas, contexto
                     |
        Collector local / agente / sidecar
     agrupar, redigir, enriquecer, limitar, repetir
                     |
             OTLP autenticado
                     |
              Camada de Collectors
       rotear, amostrar, transformar, distribuir
          |             |              |
          v             v              v
 Backend de métricas Backend de traces Backend de logs
          |             |              |
          +-------------+--------------+
                        |
         Correlação, topologia, consulta e
         experiência de fluxo de incidentes
                        |
       SLOs, alertas, investigação e ação
```

### 6.1 Responsabilidades por camada

| Camada | Responsabilidade |
|---|---|
| Aplicação | Emitir telemetria útil, preservar o contexto e evitar dados sensíveis |
| SDK ou agente | Agrupar dados, amostrar quando apropriado e exportar de forma assíncrona |
| Collector | Autenticar, enriquecer, filtrar, rotear, repetir envios e medir a saúde do pipeline |
| Backends | Armazenar e consultar dados de cada sinal com a retenção adequada |
| Camada de correlação | Conectar entidades, mudanças, sinais e investigações relacionadas |
| Fluxo de incidentes | Transformar evidências em resposta, atribuição de responsabilidade, comunicação e aprendizado |

O Collector e a camada de correlação devem ser preocupações separadas. Um Collector transporta e processa telemetria; ele não cria automaticamente uma experiência completa e unificada de consulta.

---

## 7. Formas de aplicar observabilidade

A observabilidade deve ser aplicada a um fluxo de trabalho e a uma decisão, não apenas a um componente tecnológico. Os padrões a seguir podem coexistir.

### 7.1 Diagnóstico reativo de incidentes

**Pergunta:** O que está falhando agora?

```text
Alerta ou relato de usuário
    -> SLO ou métrica afetada
    -> serviço e operação
    -> trace ou mapa de dependências
    -> log e exceção correlacionados
    -> implantação ou mudança de configuração recente
    -> mitigação e responsável
```

Use métricas para detectar problemas e traces, logs, perfis e eventos de mudança para diagnosticá-los. O sucesso deve ser medido pela redução do tempo para detectar e restaurar o serviço, não pela quantidade de dashboards.

### 7.2 Gestão de SLOs e orçamento de erro

**Pergunta:** O serviço está cumprindo o nível de confiabilidade prometido aos usuários?

Definições:

- **SLI:** Indicador medido, como requisições bem-sucedidas ou latência abaixo de um limite.
- **SLO:** Meta para o SLI durante um intervalo de tempo.
- **Orçamento de erro:** Quantidade de indisponibilidade ou falhas permitida nesse intervalo.
- **Taxa de consumo:** Velocidade com que o serviço está consumindo esse orçamento.

Use métricas como fonte oficial para os alertas de SLO. Use traces e logs para explicar quais rotas, dependências, regiões ou versões estão consumindo o orçamento.

### 7.3 Análise de transações distribuídas

**Pergunta:** Em que ponto uma operação do usuário acumula latência ou falha?

Instrumente os limites da transação, propague o contexto por HTTP, RPC e mensageria e crie spans para chamadas relevantes a dependências. Adicione atributos de negócio seguros, como tipo de operação ou estado do pedido, em vez de dados pessoais brutos ou identificadores sem restrição.

### 7.4 Capacidade de infraestrutura e plataforma

**Pergunta:** A plataforma está se aproximando da saturação ou desperdiçando capacidade?

Combine métricas de hosts, contêineres, Kubernetes, bancos de dados, filas e aplicações com metadados de implantação. Use perfis para identificar pontos de alta utilização de CPU ou memória e traces para mostrar se a saturação da plataforma afeta a latência percebida pelos usuários.

### 7.5 Observabilidade de versões e mudanças

**Pergunta:** Uma mudança causou uma regressão de comportamento?

Emita eventos de implantação, configuração, feature flags, esquema e mudanças de infraestrutura usando a mesma identidade de serviço e ambiente da telemetria de execução. Compare taxa de erro, latência, volume de requisições e comportamento das dependências antes e depois da mudança.

### 7.6 Observabilidade de negócio e da jornada do usuário

**Pergunta:** Qual cliente ou capacidade de negócio foi afetado?

Conecte evidências técnicas a dimensões de negócio limitadas, como:

- Checkout, cadastro, autorização de pagamento ou operação de envio
- Categoria de produto ou canal
- Cliente ou região, quando as regras de acesso e privacidade permitirem
- Resultado de negócio, como aceito, rejeitado, atrasado ou compensado

Não inclua IDs de clientes, endereços de e-mail, dados de pagamento ou entradas arbitrárias de usuários em métricas com alta cardinalidade. Mantenha registros detalhados de negócio nos sistemas de domínio e use referências estáveis ou dimensões agregadas nos dados de observabilidade.

### 7.7 Correlação entre segurança e confiabilidade

**Pergunta:** Uma anomalia técnica também indica um sinal de segurança ou abuso?

Correlacione falhas de autenticação, padrões incomuns de requisições, erros de serviços e eventos de infraestrutura com os fluxos de trabalho de SIEM. Os dados de observabilidade podem apoiar a detecção e a investigação, mas evidências de segurança, cadeia de custódia e requisitos de retenção podem exigir uma plataforma de segurança dedicada.

### 7.8 Observabilidade sintética e de usuários reais

**Pergunta:** Os usuários conseguem concluir jornadas críticas a partir de locais e dispositivos relevantes?

Use verificações sintéticas para caminhos conhecidos e telemetria de usuários reais para observar o comportamento dos clientes. Correlacione erros de frontend, traces de API, versões de lançamento, localização geográfica e tipo de dispositivo, aplicando consentimento, privacidade, amostragem e minimização de dados.

### 7.9 Criação contínua de perfis

**Pergunta:** Quais caminhos de código consomem CPU, memória ou tempo de execução em excesso?

Perfis complementam traces. Um trace identifica uma operação lenta; um perfil pode identificar o caminho de código responsável. Defina explicitamente políticas de coleta, armazenamento, controle de acesso e privacidade para perfis, pois eles podem revelar detalhes de implementação e valores sensíveis.

---

## 8. Regras de modelagem e governança de dados

### 8.1 Identidade obrigatória dos recursos

No mínimo, os serviços devem fornecer:

- `service.name`
- `service.version`
- `deployment.environment`
- Identidade da implantação ou da carga de trabalho
- Região, cluster, namespace ou metadados equivalentes de localização

Os campos exatos dependem da plataforma, mas a política deve ser consistente o suficiente para responder: “qual serviço, em qual versão e em qual ambiente?”.

### 8.2 Nomenclatura e cardinalidade

- Use nomes estáveis para operações e modelos de rota.
- Prefira dimensões limitadas para métricas.
- Mantenha IDs brutos de requisição em traces ou logs somente quando houver justificativa operacional.
- Não use URLs arbitrárias, entradas de usuários, endereços de e-mail ou segredos como rótulos de métricas.
- Versione as convenções semânticas e valide-as na integração contínua ou nas verificações de implantação.

### 8.3 Privacidade e segurança

A telemetria deve ser tratada como dado operacional sensível. Aplique defesa em profundidade:

1. Evite que segredos e dados pessoais sejam emitidos na origem da instrumentação.
2. Redija e filtre os dados no Collector local ou de gateway.
3. Restrinja o acesso aos backends por equipe, cliente, ambiente e finalidade.
4. Defina retenção e residência dos dados por sinal e classificação.
5. Audite o acesso a traces, logs e perfis detalhados.

Observabilidade não é um log de auditoria imutável. Eventos de auditoria oficiais precisam de um modelo próprio de integridade e retenção.

### 8.4 Indicadores de qualidade dos dados

Meça o próprio sistema de observabilidade:

- Percentual de serviços com identidade de recurso válida
- Percentual de requisições com contexto de trace propagado
- Taxas de descarte de spans, logs e métricas
- Taxa de sucesso da correlação entre sinais
- Percentual de erros com informações úteis sobre exceções
- Atraso entre a criação do evento e sua disponibilidade para consulta
- Violações de atributos com alta cardinalidade
- Saturação das filas do Collector e falhas de exportação

---

## 9. Compensações operacionais

### 9.1 Custo

O modelo unificado pode aumentar o volume de metadados e relacionamentos retidos. Controle os custos com:

- Métricas para detecção abrangente e de baixo custo
- Amostragem de cauda para priorizar traces com erros e lentidão
- Políticas de nível de log e volume de eventos
- Retenção menor para dados brutos de alto volume
- Agregações e exemplars para navegação de métricas para traces
- Camadas separadas de armazenamento quente, morno e de arquivo, quando apropriado
- Orçamentos por equipe e serviço

### 9.2 Complexidade

A unificação introduz convenções semânticas, gestão de identidade, regras de correlação e governança. Evite exigir que todas as equipes aprendam a operar todos os backends. Ofereça um caminho padrão com configurações recomendadas de SDK, modelos de Collector, validação de metadados dos serviços e poucos fluxos de trabalho bem definidos.

### 9.3 Confiabilidade

A exportação de telemetria não deve bloquear transações de negócio. Use exportação assíncrona, filas limitadas, novas tentativas, timeouts e comportamento explícito de continuidade em caso de falha. Monitore descartes de telemetria e indisponibilidade dos backends para tornar as perdas visíveis.

### 9.4 Independência de ferramentas e fornecedores

O OpenTelemetry fornece uma base sólida para instrumentação e transporte. Isso não garante que todos os backends exponham o mesmo modelo semântico ou a mesma experiência de consulta. Isole campos específicos de fornecedores na camada de exportação ou apresentação e mantenha, sempre que possível, um contrato de aplicação baseado em convenções portáveis.

---

## 10. Roteiro de adoção recomendado

### Fase 1: Estabelecer os três sinais

- Defina a identidade dos serviços e os metadados de ambiente.
- Instrumente uma API representativa e suas dependências.
- Colete métricas, logs e traces por meio do OpenTelemetry.
- Estabeleça dashboards, alertas, retenção e redação de dados básicos.

### Fase 2: Tornar a correlação confiável

- Propague o contexto de trace do W3C por HTTP, RPC e mensageria.
- Correlacione logs com IDs de trace e span.
- Padronize nomes de operações e atributos de recursos.
- Adicione exemplars ou links equivalentes entre métricas e traces.
- Meça a perda de telemetria e a qualidade da correlação.

### Fase 3: Adicionar contexto unificado

- Emita eventos de implantação, configuração, feature flags e mudanças de esquema.
- Adicione topologia e relacionamentos entre dependências.
- Conecte versões e metadados de responsabilidade dos serviços às evidências de execução.
- Ofereça fluxos de investigação que comecem por um serviço, operação, alerta ou mudança.

### Fase 4: Expandir para o negócio e sinais avançados

- Adicione resultados de negócio limitados e contexto da jornada do usuário.
- Inclua perfis, verificações sintéticas e telemetria de frontend quando forem úteis.
- Integre fluxos de segurança com responsabilidades e controles de acesso claros.
- Ajuste amostragem, retenção e camadas de armazenamento com base no valor medido e no custo.

### Fase 5: Gerenciar a observabilidade como produto

- Publique bibliotecas de instrumentação e configurações de Collector homologadas.
- Defina o processo de integração de serviços e critérios de qualidade.
- Revise convenções semânticas e mudanças incompatíveis.
- Apresente indicadores de confiabilidade, adoção, custo e resultados das investigações.

---

## 11. Prova de conceito

Use dois ou três serviços que incluam uma requisição HTTP, uma dependência de banco de dados e um fluxo assíncrono de mensagens.

### 11.1 Critérios de aceitação

| Teste | Resultado esperado |
|---|---|
| Requisição que atravessa dois serviços | Um trace com identidade de serviço consistente |
| Dependência de banco de dados | O tempo da dependência está vinculado à requisição |
| Publicação e consumo de mensagem | O contexto é propagado ou há um relacionamento explícito visível |
| Falha na aplicação | É possível navegar entre métrica, trace e log estruturado relacionados |
| Evento de implantação | É possível comparar a versão com mudanças na taxa de erro e na latência |
| Alerta de SLO | O alerta identifica a operação afetada e permite detalhamento |
| Teste de dados sensíveis | Segredos inseridos intencionalmente não chegam ao armazenamento |
| Indisponibilidade de backend | A aplicação continua disponível e a perda limitada de telemetria fica visível |
| Teste de alta cardinalidade | A política de atributos impede dimensões de métricas sem limite |
| Teste de custo | Volume, retenção e custo de armazenamento podem ser medidos por sinal |

### 11.2 Indicadores de sucesso

- Tempo entre o alerta e a identificação do serviço e da operação afetados
- Tempo entre a identificação e a descoberta de uma mudança ou dependência contribuinte provável
- Percentual de incidentes com correlação completa entre sinais
- Percentual de serviços que atendem aos requisitos de identidade e propagação
- Custo de telemetria por requisição ou operação de negócio
- Sobrecarga de CPU, memória e latência na aplicação
- Perda de sinais e atraso da telemetria de ponta a ponta

---

## 12. Recomendação

Adote os três pilares como vocabulário operacional para produzir e armazenar telemetria, mas implemente um contrato unificado de dados para identidade, contexto, relacionamentos e histórico de mudanças.

O estado desejado não é “um enorme banco de dados de observabilidade”. É um sistema no qual uma pessoa da engenharia possa começar por um alerta de SLO, métrica, log, trace, implantação, dependência ou sintoma de negócio e chegar às evidências relacionadas sem ter de reconstruir manualmente as conexões.

O OpenTelemetry é uma base adequada porque oferece APIs, SDKs, convenções semânticas, propagação de contexto e pipelines de Collector. A arquitetura deve complementar essa base com:

1. Identidade obrigatória de recursos e metadados de responsabilidade.
2. Propagação consistente de contexto entre serviços e sistemas de mensageria.
3. Backends específicos para cada sinal com campos de correlação compartilhados.
4. Modelagem de eventos de mudança, topologia e negócio com dados seguros.
5. Controles explícitos de privacidade, retenção, cardinalidade e custos.
6. Fluxos de trabalho de SLO e incidentes que meçam os resultados das investigações.

Em resumo, o modelo dos três pilares responde **que tipo de telemetria está sendo produzido**. O modelo unificado responde **como todas as evidências ajudam a entender o estado e o impacto do sistema**. Uma arquitetura madura precisa dos dois.
