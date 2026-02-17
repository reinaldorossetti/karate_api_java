# language: en
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
    * def newEmail = randomEmail()
    * def newName = randomName()
    * def newPassword = randomPassword()
    * def userData =
      """
      {
        "nome": "#(newName)",
        "email": "#(newEmail)",
        "password": "#(newPassword)",
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


  @get-by-id @regression
  Scenario: CT02 - Get a specific user by ID
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
    And match response._id == '#notnull'
    
    * def newUserId = response._id
    
    Given path '/usuarios/' + newUserId
    When method GET
    Then status 200
    And match response.nome == name
    And match response.email == newEmail


  @advanced-validations @regression
  Scenario: CT04 - Advanced JSON validations with filters
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


  @error-validation @regression
  Scenario: CT05 - Validate error messages when creating a duplicate email
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


  @fuzzy-validation @regression
  Scenario: CT06 - Validate with fuzzy matching
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


  @conditional-validation @regression
  Scenario: CT07 - Conditional validations based on values
    Given path '/usuarios'
    When method GET
    Then status 200
    
    * def user = response.usuarios[0]
    * if (user.administrador == 'true') karate.log('User is an administrator')
    * if (user.administrador == 'false') karate.log('User is not an administrator')
    
    And match user.email == '#? _.length > 5'
    And match user.password == '#? _.length > 0'

  @regex-validation @regression
  Scenario: CT08 - Validate formats with regular expressions
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


  @negative-validation @regression
  Scenario: CT09 - Validate absence of fields
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response !contains { error: '#string' }
    And match response !contains { errorMessage: '#string' }
    * def user = response.usuarios[0]
    And match user !contains { cpf: '#string' }
    And match user !contains { phone: '#string' }


  @variable-validation @regression
  Scenario: CT10 - Use variables for dynamic validations
    * def expectedEmail = randomEmail()
    * def userPayload = read('resources/userPayload.json')
    * userPayload.email = expectedEmail
    Given path '/usuarios'
    And request userPayload
    When method POST
    Then status 201

    Given path '/usuarios'
    And param email = expectedEmail
    When method GET
    Then status 200
    * def user = response.usuarios[0]
    And match user.email == expectedEmail
    And match user contains { email: '#(expectedEmail)', nome: '#string' }


  @nested-json-validation @regression
  Scenario: CT11 - Prepare data for nested object validation
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


  @create-from-json @regression
  Scenario: CT12 - Create a user from fixed JSON file
    * def userPayload = read('resources/userPayload.json')
    # opcional: evitar erro de e-mail duplicado sobrescrevendo apenas o e-mail
    * userPayload.email = randomEmail()
    Given path '/usuarios'
    And request userPayload
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'


  @create-and-delete @regression
  Scenario: CT13 - Create and delete user based on JSON payload
    * def expectedEmail = randomEmail()
    * def userPayload = read('resources/userPayload.json')
    * userPayload.email = expectedEmail

    Given path '/usuarios'
    And request userPayload
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    * def userId = response._id

    Given path '/usuarios/' + userId
    When method DELETE
    Then status 200
    And match response.message == 'Registro excluído com sucesso'

    Given path '/usuarios'
    And param email = expectedEmail
    When method GET
    Then status 200
    And match response.quantidade == 0
    And match response.usuarios == '#[0]'


  @delete-with-cart @regression
  Scenario: CT14 - Prevent deleting user that has an associated cart
    # Create a non-admin user
    * def userEmail = randomEmail()
    * def userPassword = 'SenhaSegura@123'
    * def userData =
      """
      {
        "nome": "User With Cart",
        "email": "#(userEmail)",
        "password": "#(userPassword)",
        "administrador": "false"
      }
      """

    Given path '/usuarios'
    And request userData
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    * def userId = response._id

    # Login with the created user to obtain a token
    * def loginPayload =
      """
      {
        "email": "#(userEmail)",
        "password": "#(userPassword)"
      }
      """

    Given path '/login'
    And request loginPayload
    When method POST
    Then status 200
    * def userToken = response.authorization

    # Create a product as admin to be used in the cart
    * def adminToken = userToken
    * def productName = 'Product for user cart ' + new Date().getTime()
    * def productData =
      """
      {
        "nome": "#(productName)",
        "preco": 100,
        "descricao": "Product associated to user cart",
        "quantidade": 5
      }
      """

    Given path '/produtos'
    And header Authorization = adminToken
    And request productData
    When method POST
    Then status 201
    * def productId = response._id

    # Ensure the user has no previous cart
    Given path '/carrinhos/cancelar-compra'
    And header Authorization = userToken
    When method DELETE
    Then status 200

    # Create a cart for this user
    * def cartBody =
      """
      {
        "produtos": [
          {
            "idProduto": "#(productId)",
            "quantidade": 1
          }
        ]
      }
      """

    Given path '/carrinhos'
    And header Authorization = userToken
    And request cartBody
    When method POST
    Then status 201

    # Try to delete the user and expect business rule error
    Given path '/usuarios/' + userId
    When method DELETE
    Then status 400
    And match response.message == 'Não é permitido excluir usuário com carrinho cadastrado'
    And match response.idCarrinho == '#string'
