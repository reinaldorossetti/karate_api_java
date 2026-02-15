# 🥋 Karate API Testing - ServeRest

[![Karate](https://img.shields.io/badge/Karate-1.5.0-blue.svg)](https://github.com/karatelabs/karate)
[![JUnit5](https://img.shields.io/badge/JUnit-5.10.1-green.svg)](https://junit.org/junit5/)
[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)

Projeto de automação de testes de API utilizando **Karate Framework** para testar a API REST **ServeRest** - uma API gratuita que simula uma loja virtual.

---

## 📚 Índice

- [Sobre o Karate Framework](#-sobre-o-karate-framework)
- [Sobre a API ServeRest](#-sobre-a-api-serverest)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Executando os Testes](#-executando-os-testes)
- [Exemplos de Testes](#-exemplos-de-testes)
- [Funcionalidades do Karate](#-funcionalidades-do-karate)
- [Relatórios](#-relatórios)
- [Boas Práticas](#-boas-práticas)
- [Recursos Adicionais](#-recursos-adicionais)

---

## 🥋 Sobre o Karate Framework

**Karate** é um framework open-source que unifica testes de API, mocks, testes de performance e até mesmo automação de UI em uma única estrutura poderosa e fácil de usar.

### ✨ Principais Características

- **🔥 Sem necessidade de código Java**: Escreva testes usando uma sintaxe simples baseada em Gherkin
- **🚀 Testes de API REST e SOAP**: Suporte completo para HTTP, JSON, XML, GraphQL
- **🎯 Built-in para Assertions**: Validações poderosas e expressivas sem bibliotecas adicionais
- **🔄 Reutilização de código**: Chamadas entre features, funções JavaScript customizadas
- **📊 Relatórios HTML**: Relatórios detalhados e visuais automaticamente gerados
- **🧪 Data-Driven Testing**: Suporte nativo para testes orientados a dados
- **🎭 Mock Server**: Crie mocks de APIs facilmente
- **⚡ Execução Paralela**: Execute testes em paralelo para maior velocidade
- **🔐 Autenticação**: Suporte para OAuth, JWT, cookies e headers customizados

### 💡 Por que usar Karate?

1. **Produtividade**: Escreva testes complexos de forma simples e legível
2. **Manutenibilidade**: Testes fáceis de entender e manter
3. **Completude**: Tudo que você precisa em um único framework
4. **Comunidade ativa**: Bem documentado e com suporte ativo
5. **Integração CI/CD**: Fácil integração com Jenkins, GitLab CI, GitHub Actions, etc.

---

## 🌐 Sobre a API ServeRest

[ServeRest](https://serverest.dev/) é uma API REST gratuita que simula uma loja virtual, criada por [Paulo Gonçalves](https://github.com/PauloGoncalvesBH) para fins educacionais e prática de testes de API.

### 🛍️ Endpoints Disponíveis

| Recurso | Endpoints | Descrição |
|---------|-----------|-----------|
| **Login** | `POST /login` | Autenticação de usuários |
| **Usuários** | `GET, POST, PUT, DELETE /usuarios` | Gerenciamento de usuários |
| **Produtos** | `GET, POST, PUT, DELETE /produtos` | Gerenciamento de produtos (requer admin) |
| **Carrinhos** | `GET, POST, DELETE /carrinhos` | Gerenciamento de carrinhos de compras |

### 🔗 Base URL

```
https://serverest.dev
```

### 📖 Documentação Completa

- **Swagger UI**: https://serverest.dev/
- **Repositório**: https://github.com/ServeRest/ServeRest
- **Front-end (Beta)**: https://front.serverest.dev/

---

## 📁 Estrutura do Projeto

```
karate_api_java/
│
├── src/
│   ├── main/
│   │   └── java/
│   │       └── com/intuit/karate/junit5/
│   │           ├── FeatureNode.java
│   │           └── Karate.java
│   │
│   └── test/
│       └── java/
│           ├── karate-config.js          # Configuração global do Karate
│           ├── logback-test.xml          # Configuração de logs
│           │
│           ├── karate/                   # Exemplos básicos do Karate
│           │   ├── sample.feature
│           │   ├── SampleTest.java
│           │   ├── customTags.feature
│           │   └── ...
│           │
│           └── serverest/                # Testes da API ServeRest
│               ├── usuarios/
│               │   ├── usuarios.feature
│               │   └── UsuariosTest.java
│               ├── produtos/
│               │   ├── produtos.feature
│               │   └── ProdutosTest.java
│               ├── login/
│               │   ├── login.feature
│               │   └── LoginTest.java
│               └── carrinhos/
│                   ├── carrinhos.feature
│                   └── CarrinhosTest.java
│
├── pom.xml                               # Maven dependencies
└── README.md                             # Este arquivo
```

---

## 🔧 Pré-requisitos

- **Java JDK 17** ou superior
- **Maven 3.6+**
- **IDE** (IntelliJ IDEA, Eclipse, VS Code)
- Conexão com internet (para acessar a API ServeRest)

### Verificar instalação

```bash
java -version
mvn -version
```

---

## 🚀 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/karate_api_java.git
cd karate_api_java
```

### 2. Instale as dependências

```bash
mvn clean install
```

### 3. Verifique a instalação

```bash
mvn test
```

---

## ▶️ Executando os Testes

### Executar todos os testes

```bash
mvn test
```

### Executar um teste específico

```bash
mvn test -Dtest=UsuariosTest
```

### Executar por tags

```bash
mvn test -Dkarate.options="--tags @smoke"
```

### Executar com diferentes ambientes

```bash
mvn test -Dkarate.env=dev
mvn test -Dkarate.env=prod
```

### Executar em paralelo

```bash
mvn test -Dkarate.options="--threads 5"
```

---

## 📝 Exemplos de Testes

### Exemplo 1: Listar Usuários (GET)

**Feature**: `src/test/java/serverest/usuarios/usuarios.feature`

```gherkin
@usuarios
Feature: Gerenciamento de Usuários

  Background:
    * url baseUrl + '/usuarios'

  @listar @smoke
  Scenario: Listar todos os usuários
    Given path ''
    When method GET
    Then status 200
    And match response.quantidade == '#number'
    And match response.usuarios == '#array'
```

### Exemplo 2: Cadastrar Usuário (POST)

```gherkin
  @cadastrar
  Scenario: Cadastrar novo usuário com sucesso
    * def randomEmail = 'teste' + karate.randomString(5) + '@email.com'
    Given path ''
    And request
      """
      {
        "nome": "Fulano da Silva",
        "email": "#(randomEmail)",
        "password": "senha123",
        "administrador": "true"
      }
      """
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'
    * def userId = response._id
```

### Exemplo 3: Login e Autenticação

```gherkin
@login
Feature: Autenticação de Usuários

  Background:
    * url baseUrl + '/login'

  @login-sucesso
  Scenario: Realizar login com credenciais válidas
    Given path ''
    And request
      """
      {
        "email": "fulano@qa.com",
        "password": "teste"
      }
      """
    When method POST
    Then status 200
    And match response.message == 'Login realizado com sucesso'
    And match response.authorization == '#string'
    * def token = response.authorization
```

### Exemplo 4: Testes com Autenticação (Produtos)

```gherkin
@produtos
Feature: Gerenciamento de Produtos (Requer Autenticação)

  Background:
    * url baseUrl
    # Realizar login primeiro
    * def loginResponse = call read('classpath:serverest/login/login.feature@login-sucesso')
    * def token = loginResponse.token
    * path '/produtos'

  @cadastrar-produto
  Scenario: Cadastrar produto como administrador
    * def randomName = 'Produto ' + karate.randomString(5)
    Given path ''
    And header Authorization = token
    And request
      """
      {
        "nome": "#(randomName)",
        "preco": 470,
        "descricao": "Produto de teste",
        "quantidade": 381
      }
      """
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
```

### Exemplo 5: Data-Driven Testing

```gherkin
  @validacao-email
  Scenario Outline: Validar cadastro com emails inválidos
    Given path ''
    And request
      """
      {
        "nome": "Teste",
        "email": "<email>",
        "password": "senha123",
        "administrador": "true"
      }
      """
    When method POST
    Then status 400

    Examples:
      | email           |
      | email.invalido  |
      | @email.com      |
      | email@          |
      | email           |
```

### Exemplo 6: Schema Validation

```gherkin
  @validacao-schema
  Scenario: Validar estrutura da resposta ao listar usuários
    Given path ''
    When method GET
    Then status 200
    And match response ==
      """
      {
        quantidade: '#number',
        usuarios: '#[] #object'
      }
      """
    And match each response.usuarios ==
      """
      {
        nome: '#string',
        email: '#string',
        password: '#string',
        administrador: '#string',
        _id: '#string'
      }
      """
```

---

## 🎯 Funcionalidades do Karate

### 1. Configuração Global (karate-config.js)

```javascript
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
```

### 2. Assertions Poderosas

```gherkin
# Validar tipo
And match response.quantidade == '#number'

# Validar array
And match response.usuarios == '#array'

# Validar cada item do array
And match each response.usuarios contains { nome: '#string' }

# Validar com regex
And match response.email == '#regex .+@.+\\..+'

# Validar presença de campos
And match response contains { message: '#string', _id: '#string' }

# Validar ausência de campo
And match response !contains { error: '#string' }
```

### 3. Variáveis e Reutilização

```gherkin
# Definir variável
* def userId = response._id

# String concatenation
* def fullUrl = baseUrl + '/usuarios/' + userId

# Random data
* def randomEmail = 'teste' + karate.randomString(5) + '@email.com'

# Chamar outra feature
* def loginResult = call read('login.feature')
* def token = loginResult.token
```

### 4. Hooks e Setup

```gherkin
Background:
  * url baseUrl
  * configure headers = { 'Content-Type': 'application/json' }
  * configure connectTimeout = 5000
  * configure readTimeout = 5000
```

---

## 📊 Relatórios

Após executar os testes, relatórios HTML são gerados automaticamente:

```
target/karate-reports/karate-summary.html
```

Abra o arquivo no navegador para visualizar:
- ✅ Testes executados, passados e falhos
- ⏱️ Tempo de execução
- 📸 Screenshots (se configurado)
- 📋 Logs detalhados de cada cenário

---

## 🎓 Boas Práticas

### 1. Organização de Features

- ✅ Uma feature por recurso (usuarios.feature, produtos.feature)
- ✅ Use Background para configurações comuns
- ✅ Nomeie scenarios de forma descritiva

### 2. Tags para Organização

```gherkin
@smoke     # Testes críticos de smoke
@regression # Suite de regressão completa
@usuarios   # Testes de usuários
@ignore    # Temporariamente desabilitado
```

### 3. Reutilização de Código

- ✅ Crie features reutilizáveis (ex: login.feature)
- ✅ Use funções JavaScript no karate-config.js
- ✅ Extraia dados comuns para variáveis

### 4. Dados de Teste

```gherkin
# Gerar dados dinâmicos
* def timestamp = new Date().getTime()
* def randomEmail = 'user' + timestamp + '@test.com'

# Evitar dados estáticos que podem causar conflitos
```

### 5. Validações Completas

```gherkin
# Sempre valide:
- Status code
- Schema da resposta
- Mensagens de erro
- Headers importantes
```

---

## 📚 Recursos Adicionais

### Documentação Oficial

- 🥋 **Karate**: https://github.com/karatelabs/karate
- 🌐 **ServeRest**: https://serverest.dev/
- ☕ **JUnit 5**: https://junit.org/junit5/

### Tutoriais e Cursos

- [Karate DSL Official Documentation](https://karatelabs.github.io/karate/)
- [Karate Examples on GitHub](https://github.com/karatelabs/karate/tree/master/karate-demo)
- [ServeRest GitHub](https://github.com/ServeRest/ServeRest)

### Comunidade

- [Karate Slack Community](https://karate-dsl.slack.com)
- [Stack Overflow - Karate Tag](https://stackoverflow.com/questions/tagged/karate)

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Para contribuir:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

Desenvolvido para fins de estudo e prática de automação de testes de API.

---

## ⭐ Agradecimentos

- **Paulo Gonçalves** - Criador da API ServeRest
- **Peter Thomas** - Criador do Karate Framework
- Comunidade open-source

---

**🚀 Happy Testing!** 🥋
