# language: en
@login
Feature: User Authentication - Login

  Background:
    * url 'https://serverest.dev'

  @login-success @smoke
  Scenario: CT01 - Perform login with valid credentials and validate token
    * def credentials =
      """
      {
        "email": "fulano@qa.com",
        "password": "teste"
      }
      """
    
    Given path '/login'
    And request credentials
    When method POST
    Then status 200
    
    And match response ==
      """
      {
        message: '#string',
        authorization: '#string'
      }
      """
    
    And match response.message == 'Login realizado com sucesso'
    
    And match response.authorization == '#notnull'
    And match response.authorization == '#? _.length > 50'
    
    * def authToken = response.authorization
    * print 'Generated Token:', authToken


  @login-invalid
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


  @required-fields-validation
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
    And match response contains { email: '#string' }
    
    Examples:
      | email              | password |
      |                    | senha123 |
      | test@email.com     |          |
      |                    |          |


  @login-and-use-token
  Scenario: CT04 - Login and use token to access a protected resource
    * def credentials = { "email": "fulano@qa.com", "password": "teste" }
    
    Given path '/login'
    And request credentials
    When method POST
    Then status 200
    * def token = response.authorization
    
    * def newProduct =
      """
      {
        "nome": "Auth Test Product",
        "preco": 100,
        "descricao": "Authentication test product",
        "quantidade": 10
      }
      """
    
    Given path '/produtos'
    And header Authorization = token
    And request newProduct
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'


  @email-format-validation
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


  @reusable-login
  Scenario: CT06 - Reusable login for other tests
    * def credentials = { "email": "fulano@qa.com", "password": "teste" }
    
    Given path '/login'
    And request credentials
    When method POST
    Then status 200
    
    * def token = response.authorization
    * def message = response.message


  @login-from-json
  Scenario: CT07 - Perform login using fixed JSON payload
    * def loginPayload = read('resources/loginPayload.json')
    Given path '/login'
    And request loginPayload
    When method POST
    Then status 200
    And match response.message == 'Login realizado com sucesso'
    And match response.authorization == '#string'
