const express = require('express');
const bodyParser = require('body-parser');
const moment = require('moment');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;

// Set view engine to EJS
app.set('view engine', 'ejs');
app.set('views', './views');

// Middleware
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(express.static('public'));

// Database file path
const dbFile = 'leads.json';

// Initialize database if it doesn't exist
if (!fs.existsSync(dbFile)) {
  fs.writeFileSync(dbFile, JSON.stringify([], null, 2));
}

// Utility to read database
const readDatabase = () => {
  const data = fs.readFileSync(dbFile, 'utf-8');
  return JSON.parse(data);
};

// Utility to write database
const writeDatabase = (data) => {
  fs.writeFileSync(dbFile, JSON.stringify(data, null, 2));
};

// Route to display home page
app.get('/', (req, res) => {
  res.render('index');
});

// API to submit lead
app.post('/api/leads', (req, res) => {
  const { nome, email, empresa, telefone, servico, descricao } = req.body;

  // Validation
  if (!nome || !email || !empresa || !servico) {
    return res.status(400).json({ 
      error: 'Por favor, preencha todos os campos obrigatórios.' 
    });
  }

  // Email validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ 
      error: 'Email inválido.' 
    });
  }

  const newLead = {
    id: Date.now(),
    nome,
    email,
    empresa,
    telefone: telefone || 'Não informado',
    servico,
    descricao: descricao || '',
    dataCadastro: moment().format('YYYY-MM-DD HH:mm:ss'),
    status: 'novo'
  };

  const leads = readDatabase();
  leads.push(newLead);
  writeDatabase(leads);

  // Log to console for monitoring
  console.log(`✓ Novo lead recebido: ${nome} (${email}) - ${moment().format('HH:mm:ss')}`);

  res.json({ 
    success: true, 
    message: 'Obrigado! Entraremos em contato em breve.' 
  });
});

// API to get leads (admin endpoint - add authentication in production)
app.get('/api/leads', (req, res) => {
  const leads = readDatabase();
  res.json(leads);
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
  console.log(`\n🚀 Servidor rodando em http://localhost:${port}`);
  console.log(`📊 Dashboard de leads: http://localhost:${port}/api/leads\n`);
});