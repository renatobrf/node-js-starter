# 🚀 Guia de Instalação - ObsConsulta

## Pré-requisitos

- **Node.js** >= 14.x ([Download](https://nodejs.org/))
- **npm** >= 6.x (vem com Node.js)
- **Git** (para clonar o repositório)

## Verificar Instalação

```bash
node --version      # Deve mostrar v14.x ou superior
npm --version       # Deve mostrar 6.x ou superior
```

---

## 📦 Instalação Local

### 1. Clonar o Repositório

```bash
git clone <seu-repositorio>
cd node-js-starter
```

### 2. Instalar Dependências

```bash
npm install
```

Isso instalará:
- `express` - Framework web
- `ejs` - Template engine
- `body-parser` - Parse de dados
- `moment` - Manipulação de datas

### 3. Configurar Variáveis de Ambiente (Opcional)

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar arquivo .env com seus dados
nano .env
```

Variáveis importantes:
```
PORT=3000
CONTACT_EMAIL=seu-email@company.com
CONTACT_PHONE=+55 (11) 9999-9999
```

### 4. Iniciar o Servidor

```bash
npm start
```

Saída esperada:
```
🚀 Servidor rodando em http://localhost:3000
📊 Dashboard de leads: http://localhost:3000/api/leads
```

### 5. Acessar a Aplicação

- Abra seu navegador
- Visite `http://localhost:3000`
- Pronto! 🎉

---

## 🐳 Instalação com Docker

### 1. Verificar Docker

```bash
docker --version
docker-compose --version
```

### 2. Build da Imagem

```bash
docker build -t obsconsulta:latest .
```

### 3. Executar Contêiner

```bash
# Simples
docker run -p 3000:3000 obsconsulta:latest

# Com volume para preservar dados
docker run -p 3000:3000 -v $(pwd)/leads.json:/app/leads.json obsconsulta:latest

# Com variáveis de ambiente
docker run -p 3000:3000 \
  -e PORT=3000 \
  -e CONTACT_EMAIL=seu-email@company.com \
  obsconsulta:latest
```

### 4. Verificar Contêiner

```bash
docker ps  # Ver contêineres em execução
```

---

## ☸️ Instalação em Kubernetes

### 1. Atualizar Arquivo YAML

Edite `deployment.yaml` com suas informações:
```yaml
env:
- name: PORT
  value: "3000"
- name: CONTACT_EMAIL
  value: seu-email@company.com
```

### 2. Deploy

```bash
# Apply deployment
kubectl apply -f deployment.yaml

# Verificar deploy
kubectl get pods
kubectl get svc

# Ver logs
kubectl logs <pod-name>
```

### 3. Acessar Aplicação

```bash
# Port forward
kubectl port-forward svc/obsconsulta-service 3000:3000

# Acesse http://localhost:3000
```

---

## 🌐 Instalação em Servidores Cloud

### Heroku

```bash
# 1. Instalar Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# 2. Login
heroku login

# 3. Create app
heroku create seu-app-name

# 4. Deploy
git push heroku main

# 5. Ver logs
heroku logs --tail
```

### AWS (EC2)

```bash
# 1. SSH para sua instância
ssh -i seu-key.pem ec2-user@seu-ip

# 2. Instalar Node.js
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

# 3. Clonar repo
git clone <seu-repositorio>
cd node-js-starter

# 4. Instalar dependências
npm install

# 5. Usar PM2 para manter aplicação rodando
sudo npm install -g pm2
pm2 start app.js --name "obsconsulta"
pm2 startup
pm2 save

# 6. Configurar reverse proxy com Nginx (opcional)
```

### DigitalOcean / Linode

```bash
# 1. SSH para seu servidor
ssh root@seu-ip

# 2. Atualizar sistema
apt update && apt upgrade -y

# 3. Instalar Node.js
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# 4. Clonar e instalar
git clone <seu-repositorio>
cd node-js-starter
npm install

# 5. Usar PM2
npm install -g pm2
pm2 start app.js
pm2 startup
pm2 save
```

---

## 🔐 Segurança na Instalação

### Para Produção

1. **HTTPS/SSL**
   ```bash
   # Use Let's Encrypt com Certbot
   sudo certbot certonly --standalone -d seu-dominio.com
   ```

2. **Firewall**
   ```bash
   # UFW (Linux)
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

3. **Variáveis de Ambiente**
   ```bash
   # Use .env file (não commitá-lo!)
   # Proteja permissões
   chmod 600 .env
   ```

4. **PM2 com Clustering**
   ```bash
   pm2 start app.js -i max  # Usa todos os cores
   ```

---

## 🧪 Testar Instalação

### Verificar Servidor

```bash
curl http://localhost:3000/health
```

Resposta esperada:
```json
{"status":"ok","timestamp":"2026-05-10T14:30:25.123Z"}
```

### Testar Formulário

```bash
curl -X POST http://localhost:3000/api/leads \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Teste",
    "email": "teste@example.com",
    "empresa": "Test Corp",
    "servico": "monitoramento"
  }'
```

### Verificar Leads

```bash
curl http://localhost:3000/api/leads
```

---

## 🆘 Troubleshooting

### "Port 3000 already in use"

```bash
# Encontrar processo
lsof -i :3000

# Usar porta diferente
PORT=3001 npm start
```

### "Cannot find module"

```bash
# Reinstalar dependências
rm -rf node_modules package-lock.json
npm install
```

### Erro de permissão em leads.json

```bash
chmod 644 leads.json
```

### Problema com EJS rendering

```bash
# Verifique se arquivo existe
ls -la views/index.ejs

# Limpe cache
rm -rf node_modules/.cache
```

---

## 📊 Próximos Passos

1. ✅ Instalar projeto
2. ✅ Testar funcionalidades
3. 📝 Customizar dados de contato
4. 🎨 Adicionar logo e cores da empresa
5. 📧 Integrar email (SendGrid/Nodemailer)
6. 🔐 Implementar autenticação
7. 🚀 Deploy em produção

---

## 📞 Suporte

Problemas? Consulte:
- [Node.js Docs](https://nodejs.org/docs/)
- [Express Docs](https://expressjs.com/)
- [Docker Docs](https://docs.docker.com/)
- Abra uma issue no repositório

---

**Happy Installing! 🚀**
