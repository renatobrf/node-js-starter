# 🛠️ Guia de Desenvolvimento - ObsConsulta

## Estrutura do Projeto

```
app.js                  # Servidor Express principal
views/
├── index.ejs          # Página principal (HTML + CSS + JavaScript)
leads.json             # Database JSON com leads
package.json           # Dependências do projeto
.env.example           # Variáveis de ambiente (exemplo)
Dockerfile             # Configuração Docker
deployment.yaml        # Configuração Kubernetes
```

## 🚀 Setup Local

```bash
# 1. Instalar dependências
npm install

# 2. Criar arquivo .env (copiar de .env.example)
cp .env.example .env

# 3. Iniciar servidor
npm start
```

O servidor inicia em `http://localhost:3000`

## 📝 Padrões de Código

### Backend (Node.js/Express)

- Use `const` para declarações de variáveis
- Valide sempre inputs de formulários
- Retorne JSON em endpoints de API
- Implemente error handling adequado
- Logue eventos importantes

### Frontend (HTML/CSS/JS)

- HTML semântico
- CSS com variáveis (custom properties)
- JavaScript vanilla (sem frameworks desnecessários)
- Mobile-first responsive design
- Acessibilidade em mente

## 🔄 Fluxo de Desenvolvimento

### Adicionar Nova Feature

1. Crie uma branch: `git checkout -b feature/nome-feature`
2. Implemente a feature
3. Teste localmente
4. Commit: `git commit -m "feat: descrição"`
5. Push: `git push origin feature/nome-feature`
6. Abra um Pull Request

### Estrutura de Commits

```
feat:  nova funcionalidade
fix:   correção de bug
docs:  documentação
style: formatação
refactor: refatoração de código
test:  testes
chore: tarefas gerais
```

## 🧪 Testes Manuais

### Testar Formulário

```bash
# 1. Acesse http://localhost:3000
# 2. Preencha o formulário
# 3. Verifique a resposta
# 4. Confira em http://localhost:3000/api/leads
```

### Testar API

```bash
# Enviar lead via API
curl -X POST http://localhost:3000/api/leads \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Teste",
    "email": "teste@example.com",
    "empresa": "Test Corp",
    "servico": "monitoramento"
  }'

# Listar leads
curl http://localhost:3000/api/leads

# Health check
curl http://localhost:3000/health
```

## 🐳 Desenvolvimento com Docker

```bash
# Build
docker build -t obsconsulta .

# Run
docker run -p 3000:3000 -v $(pwd):/app obsconsulta

# Run com nodemon (recarrega ao alterar código)
docker run -p 3000:3000 -v $(pwd):/app obsconsulta npm run dev
```

## 🔍 Debugging

### Console Logs

Já implementado no backend:
```bash
✓ Novo lead recebido: João Silva (joao@email.com) - 14:30:25
```

### Browser DevTools

- F12 para abrir DevTools
- Console tab para ver erros JavaScript
- Network tab para ver requisições HTTP

## 📊 Melhorias Futuras

### Curto Prazo
- [ ] Implementar CAPTCHA no formulário
- [ ] Enviar email de confirmação ao lead
- [ ] Dashboard de leads (admin)
- [ ] Integração com CRM

### Médio Prazo
- [ ] Migrar para banco de dados real (PostgreSQL)
- [ ] Implementar autenticação
- [ ] Adicionar HTTPS/TLS
- [ ] CI/CD pipeline

### Longo Prazo
- [ ] Integração com Prometheus/Grafana
- [ ] Analytics integrado
- [ ] Multi-idioma (i18n)
- [ ] Blog/Resources section

## 🛡️ Security Checklist

- [ ] Input validation (frontend + backend)
- [ ] CSRF protection
- [ ] XSS prevention
- [ ] Rate limiting
- [ ] HTTPS em produção
- [ ] Environment variables para secrets
- [ ] API key para endpoints sensíveis
- [ ] CORS configurado
- [ ] Sanitize outputs

## 📱 Checklist de Responsividade

Testar em breakpoints:
- [ ] Desktop (1920px)
- [ ] Laptop (1366px)
- [ ] Tablet (768px)
- [ ] Mobile (375px)

## 🔧 Troubleshooting

### "Cannot find module 'express'"
```bash
rm -rf node_modules package-lock.json
npm install
```

### Porta 3000 já em uso
```bash
# Encontrar processo usando porta 3000
lsof -i :3000

# Usar outra porta
PORT=3001 npm start
```

### Leads não estão sendo salvos
```bash
# Verificar permissões de escrita
ls -la leads.json
chmod 644 leads.json
```

## 📚 Recursos Úteis

- [Express.js Docs](https://expressjs.com/)
- [EJS Docs](https://ejs.co/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [MDN Web Docs](https://developer.mozilla.org/)

## 🤝 Contribuindo

1. Siga os padrões de código
2. Escreva commits descritivos
3. Teste suas mudanças
4. Documente novas features
5. Mantenha a compatibilidade backward

## 📞 Suporte

Dúvidas? Abra uma issue no repositório ou entre em contato com a equipe.

---

**Happy Coding! 🚀**
