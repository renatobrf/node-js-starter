# ⚡ Início Rápido - ObsConsulta

**Coloque seu website no ar em 5 minutos!**

---

## 🎯 Objetivo

Este guia te ajuda a rodar o website localmente e fazer seu primeiro deploy.

---

## ✅ Pré-requisitos

- [ ] Computador com Windows, Mac ou Linux
- [ ] 5 minutos de tempo
- [ ] Conexão com internet

**Não tem Node.js instalado?** → [Clique aqui para instalar](https://nodejs.org/)

---

## 🚀 5 Minutos para o Ar

### Passo 1: Abrir Terminal (30 segundos)

**Windows:**
- Pressione `Windows + R`
- Digite `cmd` e Enter

**Mac:**
- Pressione `Command + Space`
- Digite `terminal` e Enter

**Linux:**
- Pressione `Ctrl + Alt + T`

### Passo 2: Navegar até a Pasta (30 segundos)

```bash
cd /home/renato/Source/node-js-starter
```

### Passo 3: Instalar Dependências (2 minutos)

```bash
npm install
```

Aguarde até ver "added X packages"

### Passo 4: Rodar o Servidor (30 segundos)

```bash
npm start
```

Você verá:
```
🚀 Servidor rodando em http://localhost:3000
```

### Passo 5: Abrir no Navegador (30 segundos)

- Abra seu navegador
- Visite: `http://localhost:3000`
- **Pronto! Seu site está online! 🎉**

---

## 📝 Testar o Formulário

1. Preencha com dados fictícios:
   - Nome: "João Silva"
   - Email: "joao@test.com"
   - Empresa: "Test Corp"
   - Serviço: "Monitoramento"

2. Clique em "Enviar Cadastro"

3. Verifique em: `http://localhost:3000/api/leads`

Você verá seus dados salvos! ✓

---

## 🎨 Personalizar (5 minutos)

Abra o arquivo: `views/index.ejs`

**Mude estas linhas:**

1. **Email** (procure por):
   ```
   contato@obsconsulta.com.br
   ```
   Mude para seu email

2. **Telefone** (procure por):
   ```
   +55 (11) 9 9999-9999
   ```
   Mude para seu telefone

3. **Logo/Nome** (procure por):
   ```
   Obs<span>Consulta</span>
   ```
   Mude para seu nome

Salve o arquivo (`Ctrl+S`) e veja as mudanças no navegador (recarregue a página).

---

## 🌐 Deploy (Colocar Online)

Escolha uma opção:

### Opção 1: Heroku (Recomendado para Iniciantes)

```bash
# 1. Instale Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# 2. Faça login
heroku login

# 3. Crie seu app
heroku create seu-app-name

# 4. Deploy
git push heroku main

# 5. Abra
heroku open
```

✅ Seu site estará em: `seu-app-name.herokuapp.com`

### Opção 2: Vercel (Mais Moderno)

```bash
# 1. Instale Vercel CLI
npm i -g vercel

# 2. Deploy
vercel

# Responda as perguntas e pronto!
```

✅ Seu site estará em: `seu-app-name.vercel.app`

### Opção 3: DigitalOcean (Controle Total)

1. Crie conta em [DigitalOcean](https://www.digitalocean.com/)
2. Crie um Droplet (Ubuntu 20.04)
3. SSH para seu servidor
4. Siga instruções em [INSTALLATION.md](INSTALLATION.md#digitalocean--linode)

✅ Seu site estará em: `seu-dominio.com`

---

## 📊 Próximos Passos

### Hoje
- ✅ Rodar localmente
- ✅ Personalizar dados

### Esta Semana
- ⏳ Deploy em produção
- ⏳ Configurar domínio customizado
- ⏳ Testar no celular

### Próximas Semanas
- ⏳ Integrar email (SendGrid)
- ⏳ Criar dashboard admin
- ⏳ Adicionar analytics
- ⏳ Melhorar SEO

---

## 🆘 Problemas Comuns

### "npm: command not found"
→ Node.js não está instalado. [Instale aqui](https://nodejs.org/)

### "Port 3000 already in use"
→ Use outra porta:
```bash
PORT=3001 npm start
```

### "Cannot find module"
→ Reinstale dependências:
```bash
rm -rf node_modules
npm install
```

### Página não carrega
→ Certifique-se que `npm start` está rodando
→ Verifique `http://localhost:3000` (não `localhost:300`)

### Formulário não funciona
→ Abra "Console" (F12) e veja erros
→ Verifique email no arquivo views/index.ejs

---

## 📁 Estrutura do Projeto

```
seu-projeto/
├── app.js              ← Servidor (não mexa!)
├── views/
│   └── index.ejs       ← Homepage (você pode personalizar)
├── leads.json          ← Seus dados (será criado auto)
├── package.json        ← Dependências (não mexa!)
└── ...mais arquivos
```

---

## 🎓 Recursos Úteis

- **Mais detalhes?** → Veja [INSTALLATION.md](INSTALLATION.md)
- **Código?** → Veja [DEVELOPMENT.md](DEVELOPMENT.md)
- **Roadmap?** → Veja [ROADMAP.md](ROADMAP.md)
- **Índice completo?** → Veja [DOCS_INDEX.md](DOCS_INDEX.md)

---

## 💬 Dúvidas?

- Leia [DOCS_INDEX.md](DOCS_INDEX.md) para encontrar a resposta
- Consulte [INSTALLATION.md](INSTALLATION.md) para troubleshooting
- Abra uma issue no repositório

---

## ✨ Parabéns! 🎉

Você agora tem um website profissional de consultoria em observabilidade!

**Próximo passo: Colocar no ar e começar a gerar leads!**

---

**Desenvolvido para consultores que querem simplificar o marketing** 🚀
