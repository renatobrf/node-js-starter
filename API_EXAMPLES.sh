#!/bin/bash
# Exemplos de uso da API ObsConsulta
# Use estes comandos para testar a aplicação

echo "🚀 Exemplos de API - ObsConsulta"
echo "=================================="
echo ""

# Variáveis
API_URL="http://localhost:3000"

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}1. Health Check${NC}"
echo "Verificar se servidor está rodando:"
echo "---"
echo "curl $API_URL/health"
echo ""
echo -e "${YELLOW}Esperado:${NC}"
echo '{"status":"ok","timestamp":"2026-05-10T14:30:25.123Z"}'
echo ""
echo ""

echo -e "${BLUE}2. Enviar Novo Lead (JSON)${NC}"
echo "Registrar novo cliente:"
echo "---"
echo "curl -X POST $API_URL/api/leads \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{
    \"nome\": \"João Silva\",
    \"email\": \"joao@techcorp.com.br\",
    \"empresa\": \"Tech Corp\",
    \"telefone\": \"11999999999\",
    \"servico\": \"monitoramento\",
    \"descricao\": \"Buscamos implementar Prometheus em produção\"
  }'"
echo ""
echo -e "${YELLOW}Esperado:${NC}"
echo '{"success":true,"message":"Obrigado! Entraremos em contato em breve."}'
echo ""
echo ""

echo -e "${BLUE}3. Listar Todos os Leads${NC}"
echo "Obter todos os leads cadastrados:"
echo "---"
echo "curl $API_URL/api/leads | json_pp"
echo ""
echo -e "${YELLOW}Esperado:${NC}"
echo '[
  {
    "id": 1234567890,
    "nome": "João Silva",
    "email": "joao@techcorp.com.br",
    "empresa": "Tech Corp",
    "telefone": "11999999999",
    "servico": "monitoramento",
    "descricao": "...",
    "dataCadastro": "2026-05-10 14:30:25",
    "status": "novo"
  }
]'
echo ""
echo ""

echo -e "${BLUE}4. Enviar Lead via Form (HTML)${NC}"
echo "Teste pelo formulário web:"
echo "---"
echo "1. Abra http://localhost:3000"
echo "2. Preencha o formulário"
echo "3. Clique em 'Enviar Cadastro'"
echo "4. Veja a resposta aparecer abaixo do botão"
echo ""
echo ""

echo -e "${GREEN}5. Verificar Arquivo de Dados${NC}"
echo "Os leads são salvos em leads.json:"
echo "---"
echo "cat leads.json | json_pp"
echo ""
echo ""

echo -e "${BLUE}6. Script Automático - Enviar 5 Leads${NC}"
cat << 'EOF'
#!/bin/bash
# Script para enviar múltiplos leads

API_URL="http://localhost:3000"

# Array de líderes para teste
leads=(
  '{"nome":"Alice Costa","email":"alice@company.com","empresa":"DataCorp","servico":"observabilidade"}'
  '{"nome":"Bruno Santos","email":"bruno@startup.io","empresa":"StartupXYZ","servico":"performance"}'
  '{"nome":"Camila Lima","email":"camila@enterprise.com","empresa":"Enterprise Ltd","servico":"seguranca"}'
  '{"nome":"Diego Martins","email":"diego@tech.dev","empresa":"TechDev Inc","servico":"treinamento"}'
  '{"nome":"Fernanda Rosa","email":"fernanda@global.net","empresa":"Global Corp","servico":"suporte"}'
)

echo "Enviando 5 leads de teste..."
for lead in "${leads[@]}"; do
  curl -s -X POST $API_URL/api/leads \
    -H "Content-Type: application/json" \
    -d "$lead" | jq '.'
  echo "✓ Lead enviado"
  sleep 1
done

echo ""
echo "✅ Todos os leads foram enviados!"
echo "Acesse http://localhost:3000/api/leads para ver a lista completa"
EOF
echo ""
echo ""

echo -e "${BLUE}7. PowerShell - Para Windows${NC}"
cat << 'EOF'
# Windows PowerShell script para enviar lead

$ApiUrl = "http://localhost:3000/api/leads"
$Headers = @{"Content-Type" = "application/json"}

$Lead = @{
    nome = "Maria Silva"
    email = "maria@empresa.com"
    empresa = "Empresa XYZ"
    telefone = "1133334444"
    servico = "monitoramento"
    descricao = "Interessada em implementar stack completa"
} | ConvertTo-Json

Invoke-RestMethod -Uri $ApiUrl -Method POST -Headers $Headers -Body $Lead
EOF
echo ""
echo ""

echo -e "${BLUE}8. Node.js - Enviar Lead via Script${NC}"
cat << 'EOF'
// save as: send-lead.js
const fetch = require('node-fetch');

const lead = {
  nome: "Pedro Costa",
  email: "pedro@example.com",
  empresa: "ExampleCorp",
  telefone: "11988888888",
  servico: "observabilidade",
  descricao: "Queremos melhorar visibilidade"
};

fetch('http://localhost:3000/api/leads', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(lead)
})
.then(r => r.json())
.then(d => console.log('✓ Lead enviado:', d))
.catch(e => console.error('✗ Erro:', e));

// Executar: node send-lead.js
EOF
echo ""
echo ""

echo -e "${BLUE}9. Python - Enviar Lead via Script${NC}"
cat << 'EOF'
# save as: send_lead.py
import requests
import json

api_url = "http://localhost:3000/api/leads"

lead = {
    "nome": "Roberto Silva",
    "email": "roberto@example.com",
    "empresa": "Example Corp",
    "telefone": "11987654321",
    "servico": "performance",
    "descricao": "Otimizar latência da aplicação"
}

response = requests.post(
    api_url,
    headers={"Content-Type": "application/json"},
    json=lead
)

print("Status:", response.status_code)
print("Resposta:", response.json())

# Executar: python send_lead.py
EOF
echo ""
echo ""

echo -e "${GREEN}=================================="
echo "Testes Prontos para Usar! 🎉"
echo "=================================="
echo ""
echo -e "${YELLOW}Dica:${NC} Certifique-se que o servidor está rodando antes:"
echo "npm start"
echo ""
