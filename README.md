# ObsConsulta - Website de Consultoria em Observabilidade

Website profissional para consultoria em monitoramento, observabilidade e performance de aplicações.

## 🎯 Funcionalidades

- **Landing Page Moderna**: Design responsivo e profissional
- **Seções Completas**: 
  - Hero com call-to-action
  - Serviços oferecidos
  - Benefícios
  - Depoimentos de clientes
  - Formulário de cadastro/contato
  
- **Sistema de Leads**: Coleta profissional de dados de prospects
- **Validação de Dados**: Validação no backend e feedback ao usuário
- **API REST**: Endpoints para gerenciar leads
- **Armazenamento**: Leads salvos em JSON estruturado

## 📋 Pré-requisitos

- Node.js >= 14.x
- npm ou yarn

## 🚀 Instalação

```bash
# 1. Clonar ou navegar até o projeto
cd node-js-starter

# 2. Instalar dependências
npm install

# 3. Iniciar servidor
npm start
```

O servidor será iniciado em `http://localhost:3000`

## 📦 Dependências

- **express**: Framework web
- **ejs**: Template engine
- **body-parser**: Parse de dados de formulários
- **moment**: Manipulação de datas

## 📁 Estrutura do Projeto

```
├── app.js                 # Servidor principal
├── views/
│   └── index.ejs         # Página principal (HTML/EJS)
├── public/               # Arquivos estáticos (opcional)
├── leads.json            # Base de dados de leads
├── package.json          # Dependências do projeto
├── Dockerfile            # Configuração Docker
├── deployment.yaml       # Configuração Kubernetes
└── README.md             # Este arquivo
```

## 🔌 API Endpoints

### GET `/api/leads`
Retorna todos os leads cadastrados.

```bash
curl http://localhost:3000/api/leads
```

### POST `/api/leads`
Cadastra um novo lead.

```bash
curl -X POST http://localhost:3000/api/leads \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "João Silva",
    "email": "joao@example.com",
    "empresa": "Tech Corp",
    "telefone": "11999999999",
    "servico": "monitoramento",
    "descricao": "Interessado em Prometheus e Grafana"
  }'
```

### GET `/health`
Status de saúde da aplicação.

```bash
curl http://localhost:3000/health
```

## 📊 Formato dos Leads

Cada lead é armazenado em `leads.json` com este formato:

```json
{
  "id": 1234567890,
  "nome": "João Silva",
  "email": "joao@example.com",
  "empresa": "Tech Corp",
  "telefone": "11999999999",
  "servico": "monitoramento",
  "descricao": "Descrição da necessidade",
  "dataCadastro": "2026-05-10 14:30:25",
  "status": "novo"
}
```

## 🐳 Docker

### Build da Imagem

```bash
docker build -t obsconsulta .
```

### Executar Contêiner

```bash
docker run -p 3000:3000 obsconsulta
```

## ☸️ Kubernetes

Deploy no Kubernetes:

```bash
kubectl apply -f deployment.yaml
```

## 🔧 Customizações

### Mudar Porta
```bash
PORT=8080 npm start
```

### Mudar Dados de Contato
Edite as informações no arquivo `views/index.ejs`:
- Email
- Telefone
- Horário de atendimento

### Adicionar Novos Serviços
Adicione cards em `views/index.ejs` seguindo a estrutura de `.service-card`

### Mudar Cores
Edite as variáveis CSS em `views/index.ejs`:
```css
:root {
  --primary: #1a365d;      /* Azul principal */
  --accent: #00d4ff;       /* Azul ciano */
  /* ... mais cores ... */
}
```

## 📊 Monitoramento

A aplicação inclui:
- Logs de novos leads no console
- Health check em `/health`
- Armazenamento estruturado em JSON

Para monitoramento em produção, considere adicionar:
- Integração com Prometheus
- Logs centralizados (ELK, Loki)
- APM (Application Performance Monitoring)

## 🛡️ Segurança

Para produção, recomendado:
- [ ] Adicionar HTTPS
- [ ] Implementar rate limiting
- [ ] Adicionar CORS configurado
- [ ] Validação de CAPTCHA no formulário
- [ ] Autenticação para `/api/leads`
- [ ] CSRF protection
- [ ] Input sanitization
- [ ] Variáveis de ambiente (.env)

## 📧 Integração de Email

Para enviar confirmações por email, integre:
- SendGrid
- Nodemailer
- AWS SES

## 📱 Responsividade

O site é totalmente responsivo e funciona em:
- Desktop (1920px+)
- Tablet (768px - 1024px)
- Mobile (< 768px)

## 🚦 Status Codes da API

- `200`: Sucesso
- `400`: Erro de validação
- `500`: Erro do servidor

## 📝 Exemplo de Uso

1. Acesse `http://localhost:3000`
2. Preencha o formulário de contato
3. Clique em "Enviar Cadastro"
4. Verifique os leads em `http://localhost:3000/api/leads`

## 🤝 Contribuições

Contribuições são bem-vindas! Faça um fork e envie um PR.

## 📄 Licença

MIT

## 👨‍💻 Suporte

Para dúvidas ou issues:
- Email: contato@obsconsulta.com.br
- Crie uma issue no repositório

---

**Desenvolvido com ❤️ para profissionais de DevOps e SRE**
