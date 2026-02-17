# 🥋 Karate API Testing - ServeRest

[![Karate](https://img.shields.io/badge/Karate-1.5.2-blue.svg)](https://github.com/karatelabs/karate)
[![JUnit5](https://img.shields.io/badge/JUnit-5.10.1-green.svg)](https://junit.org/junit5/)
[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://www.oracle.com/java/)

Projeto de automação de testes de API utilizando **Karate Framework** para testar a API REST **ServeRest** - uma API gratuita que simula uma loja virtual.

Projeto estruturado com boas práticas, exemplos de testes, validações avançadas e integração com JUnit 5 para execução e relatórios.

URI do repositório: [https://github.com/reinaldorossetti/karate_api_java](https://github.com/reinaldorossetti/karate_api_java)

Reporte na esteira: [https://reinaldorossetti.github.io/karate_api_java/karate-reports/karate-summary.html](https://reinaldorossetti.github.io/karate_api_java/karate-reports/karate-summary.html)

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

[ServeRest](https://serverest.dev/) é uma API REST gratuita que simula uma loja virtual para fins educacionais e prática de testes de API.

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
│   │   └── java/                         # (vazio neste projeto)
│   │
│   └── test/
│       └── java/
│           ├── karate-config.js          # Configuração global do Karate
│           ├── logback-test.xml          # Configuração de logs
│           ├── ParallelRunner.java       # Execução paralela centralizada (JUnit 5)
│           │
│           ├── karate/                   # Exemplos oficiais do Karate
│           │   └── samples/
│           │       ├── sample.feature
│           │       ├── SampleTest.java
│           │       ├── customTags.feature
│           │       ├── SampleCustomTagsTest.java
│           │       ├── embed.feature
│           │       ├── noFeatureNoScenario.feature
│           │       └── ...
│           │
│           └── serverest/                # Testes da API ServeRest
│               ├── usuarios/
│               │   ├── Users.feature
│               │   ├── UsersTest.java
│               │   └── resources/
│               │       └── userPayload.json
│               ├── produtos/
│               │   ├── Products.feature
│               │   ├── ProductsTest.java
│               │   └── resources/
│               │       └── productPayload.json
│               ├── login/
│               │   ├── Login.feature
│               │   ├── LoginTest.java
│               │   └── resources/
│               │       └── loginPayload.json
│               └── utils/
│                   └── FakerUtils.java
│
├── pom.xml                               # Dependências Maven
└── README.md                             # Este arquivo
```

---

## 🔧 Pré-requisitos

- **Java JDK 21** (LTS) ou superior
- **Maven 3.6+**
- **IDE** (IntelliJ IDEA, Eclipse, VS Code)
- Conexão com internet (para acessar a API ServeRest)

### Download do Java 21

- Oracle JDK 21: https://www.oracle.com/java/technologies/downloads/#java21

### Verificar instalação

```bash
java -version
mvn -version
```

---

## 📦 Versões das dependências (pom.xml)

| Componente                         | Artefato                                      | Versão  |
|------------------------------------|-----------------------------------------------|---------|
| Karate Core                        | io.karatelabs:karate-core                     | 1.5.2   |
| Karate JUnit5                      | io.karatelabs:karate-junit5                   | 1.5.2   |
| JUnit 5 (Jupiter API)             | org.junit.jupiter:junit-jupiter-api           | 5.10.1  |
| JUnit 5 (Jupiter Engine)          | org.junit.jupiter:junit-jupiter-engine        | 5.10.1  |
| Maven Surefire Plugin             | org.apache.maven.plugins:maven-surefire-plugin| 3.2.5   |
| Maven Compiler Plugin             | org.apache.maven.plugins:maven-compiler-plugin| 3.11.0  |

---

## 🚀 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/reinaldorossetti/karate_api_java.git
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

### Executar suíte principal (ParallelRunner)

O `ParallelRunner` é uma classe de teste JUnit 5 que executa as features em paralelo, filtrando por tags (ex.: `@regression`) e gerando relatórios em `target/karate-reports`.

```bash
mvn test -Dtest=ParallelRunner
```

```java
class ParallelRunner {

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:serverest")
                .tags("~@ignore", "@regression")
                .outputJunitXml(true)          // Jenkins/CI integration
                .outputCucumberJson(true)      // Dashboard integration
                .reportDir("target/karate-reports")
                .parallel(6);  // 6 threads
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }

}
```

### Executar por uma função específica, usando da função

```bash
# Run specific test method
mvn test -Dtest=UserTest#testSmokeTests
```

---

## ⚙️ Esteira CI/CD - GitHub Actions

Este projeto possui integração contínua configurada no GitHub Actions em:

- Arquivo: `.github/workflows/api-tests.yml`

### 🔁 Quando a esteira é executada

- `push` em qualquer branch
- `pull_request` aberto ou atualizado

### 🧱 Passos principais do job `test`

1. **Checkout do código**
  - `actions/checkout@v4`
2. **Configuração do Java 21**
  - `actions/setup-java@v5` com:
    - `java-version: '21'`
    - `distribution: 'temurin'`
3. **Execução dos testes Karate via Maven**
  - Comando: `mvn test -Dtest=ParallelRunner`
  - Usa a classe `ParallelRunner` para executar as features em paralelo, filtrando cenários (ex.: `@regression`).
4. **Publicação de relatórios do Karate**
  - Publica `target/karate-reports` via `peaceiris/actions-gh-pages@v4` na branch `gh-pages`, pasta `karate-reports`.

### 🌐 Acesso ao relatório no GitHub Pages

Após a execução da esteira (branch padrão configurada no repositório):

- URL do relatório: 
  - `https://reinaldorossetti.github.io/karate_api_java/karate-reports/karate-summary.html`

Certifique-se de que nas **Settings → Pages** do repositório o GitHub Pages esteja apontando para a branch `gh-pages`.

---

## 📝 Exemplos de Testes

### Exemplo 1: Listar Usuários (GET)

**Feature**: `src/test/java/serverest/usuarios/Users.feature`

```gherkin
@users
Feature: User Management - ServeRest API

  Background:
    * url 'https://serverest.dev'
    * def FakerUtils = Java.type('serverest.utils.FakerUtils')
    * def randomEmail = function(){ return FakerUtils.randomEmail() }
    * def randomName = function(){ return FakerUtils.randomName() }
    * def randomPassword = function(){ return FakerUtils.randomPassword() }

  @list @smoke @regression
  Scenario: CT01 - List all users and validate JSON structure
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response.quantidade == '#number? _ > 0'
    And match each response.usuarios ==  
      """
      {
        nome: '#string',
        email: '#regex .+@.+\\..+',
        password: '#string',
        administrador: '#string',
        _id: '#string'
      }
      """
```

### Exemplo 2: Cadastrar Usuário (POST)

```gherkin
  @create @smoke @regression
  Scenario: CT03 - Create a new user with complete validations
    * def newEmail = randomEmail()
    * def name = randomName()
    * def password = randomPassword()
    * def userData =
      """
      {
        "nome": "#(name)",
        "email": "#(newEmail)",
        "password": "#(password)",
        "administrador": "true"
      }
      """
    
    Given path '/usuarios'
    And request userData
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'
```

### Exemplo 3: Login e Autenticação

**Feature**: `src/test/java/serverest/login/Login.feature`

```gherkin
@login
Feature: User Authentication - Login

  Background:
    * url 'https://serverest.dev'
    * def FakerUtils = Java.type('serverest.utils.FakerUtils')
    * def randomProductName = function(){ return FakerUtils.randomProduct() }

  @regression @smoke @login-success
  Scenario: CT01 - Perform login with valid credentials and validate token
    * def loginPayload = read('classpath:serverest/login/resources/loginPayload.json')
    Given path '/login'
    And request loginPayload
    When method POST
    Then status 200
    * def message = response.message
    * def authToken = response.authorization

    And match message == 'Login realizado com sucesso'
    And match authToken == '#notnull'
    And match authToken == '#? _.length > 50'
```

### Exemplo 4: Testes com Autenticação (Produtos)

**Feature**: `src/test/java/serverest/produtos/Products.feature`

```gherkin
@products
Feature: Product Management (Requires Admin Authentication)

  Background:
    * url 'https://serverest.dev'
    * def loginResponse = call read('classpath:serverest/login/Login.feature@reusable-login')
    * def token = loginResponse.token

  @create-product @smoke
  Scenario: Create a new product as an administrator
    * def productName = 'Product ' + new Date().getTime()
    * def productData =
      """
      {
        "nome": "#(productName)",
        "preco": 250,
        "descricao": "Automated test product",
        "quantidade": 100
      }
      """

    Given path '/products'
    And header Authorization = token
    And request productData
    When method POST
    Then status 201
```

### Exemplo 5: Data-Driven Testing

```gherkin
  @regression
  Scenario Outline: CT03 - Validate required fields on login
    * def incompleteData =
      """
      {
        "email": "<email>",
        "password": "<password>"
      }
      """
    
    Given path '/login'
    And request incompleteData
    When method POST
    Then status 400
    * if (!incompleteData.email) karate.match(response, { email: '#string' })
    * if (!incompleteData.password) karate.match(response, { password: '#string' })
    
    Examples:
      | email          | password |
      |                | senha123 |
      | test@email.com |          |
      |                |          |
```

### Exemplo 6: Validações avançadas com filtros (Users)

**Feature**: `src/test/java/serverest/usuarios/Users.feature`

```gherkin
  @advanced-validations @regression
  Scenario: CT04 - Advanced JSON validations with filters
    Given path '/usuarios'
    When method GET
    Then status 200
    
    * def admins = karate.filter(response.usuarios, function(x){ return x.administrador == 'true' })
    * print 'Total administrators:', admins.length
```

---

## 🎯 Funcionalidades do Karate

### 1. Configuração Global (karate-config.js)

```javascript
function fn() {
  var config = {
    baseUrl: 'https://serverest.dev',
    timeout: 10000
    * url 'https://serverest.dev'
    * def loginResponse = call read('classpath:serverest/login/Login.feature@login-success')
    * def token = loginResponse.authToken
    * def randomName = function(){ return 'Product ' + new Date().getTime() }

  @create-product @smoke @regression
  Scenario: CT02 - Create a new product as an administrator
    * def productName = randomName()
    * def productData =
      """
      {
        "nome": "#(productName)",
        "preco": 250,
        "descricao": "Automated test product",
        "quantidade": 100
      }
      """

      Given path '/produtos'
    And header Authorization = token
    And request productData
    When method POST
    Then status 201
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
Referências:
- https://github.com/karatelabs/karate
- https://junit.org/junit5/ 
- https://docs.karatelabs.io/running-tests/parallel-execution

**🚀 Happy Testing!** 🥋
