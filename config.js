/**
 * Configurações da aplicação ObsConsulta
 * Customize aqui os dados específicos do seu negócio
 */

module.exports = {
  // Dados da empresa
  company: {
    name: 'ObsConsulta',
    tagline: 'Consultoria em Monitoramento e Observabilidade',
    description: 'Transformando visibilidade em negócio',
    url: process.env.SITE_URL || 'http://localhost:3000'
  },

  // Contato
  contact: {
    email: process.env.CONTACT_EMAIL || 'contato@obsconsulta.com.br',
    phone: process.env.CONTACT_PHONE || '+55 (11) 9 9999-9999',
    hours: process.env.CONTACT_HOURS || 'Seg-Sex, 9h às 18h (Brasília)',
    timezone: 'America/Sao_Paulo'
  },

  // Servidor
  server: {
    port: process.env.PORT || 3000,
    env: process.env.NODE_ENV || 'development',
    host: process.env.HOST || 'localhost'
  },

  // Database
  database: {
    path: process.env.DB_PATH || './leads.json'
  },

  // Segurança
  security: {
    corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    rateLimitRequests: parseInt(process.env.RATE_LIMIT_REQUESTS || '100'),
    rateLimitWindowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
    apiKey: process.env.API_KEY || null // Deixe null para desabilitar autenticação
  },

  // Email (opcional)
  email: {
    enabled: process.env.EMAIL_ENABLED === 'true' || false,
    provider: process.env.EMAIL_PROVIDER || 'sendgrid', // 'sendgrid', 'smtp', 'nodemailer'
    sendgridApiKey: process.env.SENDGRID_API_KEY || null,
    from: process.env.EMAIL_FROM || 'noreply@obsconsulta.com.br'
  },

  // Logs
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    format: 'simple' // 'simple' ou 'json'
  },

  // Serviços oferecidos (customize aqui)
  services: [
    {
      id: 'monitoramento',
      title: 'Implementação de Monitoramento',
      icon: '📊',
      description: 'Configuração completa de ferramentas de monitoramento.'
    },
    {
      id: 'observabilidade',
      title: 'Observabilidade em Produção',
      icon: '🔍',
      description: 'Estratégia completa de observabilidade.'
    },
    {
      id: 'treinamento',
      title: 'Treinamento e Consultoria',
      icon: '🎓',
      description: 'Capacitação de equipes em boas práticas.'
    },
    {
      id: 'performance',
      title: 'Otimização de Performance',
      icon: '⚡',
      description: 'Identificação e correção de gargalos.'
    },
    {
      id: 'seguranca',
      title: 'Segurança e Compliance',
      icon: '🛡️',
      description: 'Monitoramento de segurança e auditoria.'
    },
    {
      id: 'suporte',
      title: 'Suporte Contínuo',
      icon: '🔧',
      description: 'Manutenção e evolução contínua.'
    }
  ]
};
