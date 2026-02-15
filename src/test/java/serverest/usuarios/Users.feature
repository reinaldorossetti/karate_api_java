# language: en
@users
Feature: User Management - ServeRest API

  Background:
    * url 'https://serverest.dev'
    * def randomEmail = function(){ return 'user' + new Date().getTime() + '@test.com' }

  @list @smoke
  Scenario: List all users and validate JSON structure
    * def newEmail = randomEmail()
    * def userData =
      """
      {
        "nome": "John Doe",
        "email": "#(newEmail)",
        "password": "senha@123",
        "administrador": "true"
      }
      """
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response ==
      """
      {
        quantidade: '#number',
        usuarios: '#array'
      }
      """
    
    And match response.quantidade == '#number? _ > 0'
    And match response.usuarios == '#[_ > 0]'
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
    
    And match each response.usuarios contains { administrador: '#regex true|false' }
    
    * def firstUser = response.usuarios[0]
    * print 'First user:', firstUser


  @get-by-id
  Scenario: Get a specific user by ID
    * def newEmail = randomEmail()
    Given path '/usuarios'
    When method GET
    Then status 200
    * def userId = response.usuarios[0]._id
    
    Given path '/usuarios/' + userId
    When method GET
    Then status 200
    And match response contains
      """
      {
        nome: '#present',
        email: '#present',
        _id: '#present'
      }
      """
    And match response.nome == '#string'
    And match response.email == '#string'
    And match response._id == userId
    And match response == { nome: '#string', email: '#string', password: '#string', administrador: '#string', _id: '#string' }


  @create @smoke
  Scenario: Create a new user with complete validations
    * def newEmail = randomEmail()
    * def userData =
      """
      {
        "nome": "John Doe",
        "email": "#(newEmail)",
        "password": "senha@123",
        "administrador": "true"
      }
      """
    
    Given path '/usuarios'
    And request userData
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'
    And match response._id == '#notnull'
    
    * def newUserId = response._id
    
    Given path '/usuarios/' + newUserId
    When method GET
    Then status 200
    And match response.nome == 'John Doe'
    And match response.email == newEmail


  @advanced-validations
  Scenario: Advanced JSON validations with filters
    Given path '/usuarios'
    When method GET
    Then status 200
    
    * def admins = karate.filter(response.usuarios, function(x){ return x.administrador == 'true' })
    * print 'Total administrators:', admins.length
    
    And match admins == '#[_ > 0]'
    
    * def filteredUsers = karate.jsonPath(response, "$.usuarios[?(@.administrador=='true')]")
    * print 'Admin users found:', filteredUsers.length
    
    * def emails = karate.map(response.usuarios, function(x){ return x.email })
    * print 'List of emails:', emails
    
    And match emails == '#[] #string'


  @error-validation
  Scenario: Validate error messages when creating a duplicate email
    * def duplicateEmail = randomEmail()
    * def user1 =
      """
      {
        "nome": "User 1",
        "email": "#(duplicateEmail)",
        "password": "senha123",
        "administrador": "false"
      }
      """
    
    Given path '/usuarios'
    And request user1
    When method POST
    Then status 201
    
    * def user2 =
      """
      {
        "nome": "User 2",
        "email": "#(duplicateEmail)",
        "password": "anotherpassword",
        "administrador": "true"
      }
      """
    
    Given path '/usuarios'
    And request user2
    When method POST
    Then status 400
    
    And match response ==
      """
      {
        message: 'Este email já está sendo usado',
      }
      """
    And match response.message == '#notnull'


  @fuzzy-validation
  Scenario: Validate with fuzzy matching
    Given path '/usuarios'
    And param administrador = 'true'
    When method GET
    Then status 200
    And match response ==
      """
      {
        quantidade: '#number',
        usuarios: '#[]'
      }
      """
    And match each response.usuarios contains
      """
      {
        nome: '#string',
        email: '#string',
        administrador: 'true'
      }
      """


  @conditional-validation
  Scenario: Conditional validations based on values
    Given path '/usuarios'
    When method GET
    Then status 200
    
    * def user = response.usuarios[0]
    * if (user.administrador == 'true') karate.log('User is an administrator')
    * if (user.administrador == 'false') karate.log('User is not an administrator')
    
    And match user.email == '#? _.length > 5'
    And match user.password == '#? _.length > 0'

  @regex-validation
  Scenario: Validate formats with regular expressions
    * def newEmail = 'test.regex.' + new Date().getTime() + '@example.com'
    * def userData =
      """
      {
        "nome": "Regex Test",
        "email": "#(newEmail)",
        "password": "StrongPassword@123",
        "administrador": "false"
      }
      """
    
    Given path '/usuarios'
    And request userData
    When method POST
    Then status 201
    
    Given path '/usuarios/' + response._id
    When method GET
    Then status 200
    And match response.email == '#regex .+@.+\\..+'
    And match response.nome == '#regex [A-Za-z\\s]+'
    And match response._id == '#regex [A-Za-z0-9]+'


  @negative-validation
  Scenario: Validate absence of fields
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response !contains { error: '#string' }
    And match response !contains { errorMessage: '#string' }
    * def user = response.usuarios[0]
    And match user !contains { cpf: '#string' }
    And match user !contains { phone: '#string' }


  @variable-validation
  Scenario: Use variables for dynamic validations
    * def expectedEmail = 'fulano@qa.com'
    * def expectedName = 'Fulano da Silva'
    
    Given path '/usuarios'
    And param email = expectedEmail
    When method GET
    Then status 200
    * def user = response.usuarios[0]
    And match user.email == expectedEmail
    And match user contains { email: '#(expectedEmail)', nome: '#string' }


  @nested-json-validation
  Scenario: Prepare data for nested object validation
    * def complexData =
      """
      {
        "nome": "Complex User",
        "email": "#(randomEmail())",
        "password": "senha123",
        "administrador": "true"
      }
      """
    
    Given path '/usuarios'
    And request complexData
    When method POST
    Then status 201
    And match response ==
      """
      {
        message: '#string',
        _id: '#string'
      }
      """
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#? _.length > 10'
