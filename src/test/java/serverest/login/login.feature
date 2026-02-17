# language: en
@login
Feature: User Authentication - Login

  Background:
    * url 'https://serverest.dev'
    * def FakerUtils = Java.type('serverest.utils.FakerUtils')
    * def randomProductName = function(){ return FakerUtils.randomProduct() }

  @regression @smoke @login-success
  Scenario: CT01 - Perform login with valid credentials and validate token
    * def randomEmail = function(){ return FakerUtils.randomEmail() }
    Given path '/login'
    And request {
      "email": "#(randomEmail())",
      "password": "minhaSenha123"
    }
    When method POST
    Then status 200
    * def message = response.message
    * def authToken = response.authorization

    And match message == 'Login realizado com sucesso'
    And match authToken == '#notnull'
    And match authToken == '#? _.length > 50'
    * print 'Generated Token:', authToken

  @regression
  Scenario: CT02 - Attempt login with invalid credentials
    * def invalidCredentials =
      """
      {
        "email": "usuario@inexistente.com",
        "password": "senhaerrada"
      }
      """
    
    Given path '/login'
    And request invalidCredentials
    When method POST
    Then status 401
    And match response.message == 'Email e/ou senha inválidos'
    And match response !contains { authorization: '#string' }


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
      | email              | password |
      |                    | senha123 |
      | test@email.com     |          |
      |                    |          |

  @regression
  Scenario: CT04 - Login and use token to access a protected resource
    * def adminEmail = 'admin.' + new Date().getTime() + '@example.com'
    * def adminPassword = 'SenhaSegura@123'
    * def adminUser =
      """
      {
        "nome": "Admin User",
        "email": "#(adminEmail)",
        "password": "#(adminPassword)",
        "administrador": "true"
      }
      """

    Given path '/usuarios'
    And request adminUser
    When method POST
    Then status 201

    * def loginPayload = { email: adminEmail, password: adminPassword }
    Given path '/login'
    And request loginPayload
    When method POST
    Then status 200
    * def message = response.message
    * def authToken = response.authorization
    And match message == 'Login realizado com sucesso'

    * def productName = randomProductName()
    * def newProduct =
      """
      {
        "nome": "#(productName)",
        "preco": 100,
        "descricao": "Produto gerado com Faker para teste de autenticação",
        "quantidade": 10
      }
      """
    
    Given path '/produtos'
    And header Authorization = authToken
    And request newProduct
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'

  @regression
  Scenario Outline: CT05 - Validate invalid email format
    * def invalidLogin = { "email": "<invalidEmail>", "password": "senha123" }
    
    Given path '/login'
    And request invalidLogin
    When method POST
    Then status 400
    And match response contains { email: '#string' }
    
    Examples:
      | invalidEmail     |
      | emailwithoutat   |
      | @noname.com      |
      | email@nodomain   |
      | email            |
      | 12345@test.c     |
      | !@#$%            |
