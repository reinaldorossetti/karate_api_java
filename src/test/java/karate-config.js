function fn() {
  var config = {
    baseUrl: 'https://serverest.dev',
    timeout: 10000
  };
  
  // Configuração por ambiente
  var env = karate.env;
  if (env === 'dev') {
    config.baseUrl = 'http://localhost:3000';
  } else if (env === 'prod') {
    config.baseUrl = 'https://serverest.dev';
  }
  
  return config;
}