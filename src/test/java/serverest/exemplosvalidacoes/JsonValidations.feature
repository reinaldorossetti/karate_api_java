# language: en
@validation-examples
Feature: Complete Examples of JSON Validations with Karate

  Background:
    * url 'https://serverest.dev'

  @type-validation
  Scenario: CT01 - Validate data types in JSON
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response.quantidade == '#number'
    And match response.usuarios == '#array'
    And match response.usuarios[0].nome == '#string'
    And match response.usuarios[0].administrador == '#string'
    And match response.quantidade == '#notnull'
    And match response.quantidade == '#present'
    And match response.quantidade == '#number? _ > 0'
    And match response.usuarios == '#[_ > 0]'


  @schema-validation
  Scenario: CT02 - Validate the complete JSON structure
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
    
    And match response contains
      """
      {
        quantidade: '#number'
      }
      """


  @regex-validation
  Scenario: CT03 - Use regular expressions to validate formats
    Given path '/usuarios'
    When method GET
    Then status 200
    * def user = response.usuarios[0]
    And match user.email == '#regex .+@.+\\..+'
    And match user.nome == '#regex ^[A-Za-zÀ-ÿ\\s]+$'
    And match user._id == '#regex ^[A-Za-z0-9]+$'
    And match user.administrador == '#regex ^(true|false)$'


  @array-validations
  Scenario: CT04 - Advanced array validations
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response.usuarios == '#array'
    And match response.usuarios == '#[10]'
    And match response.usuarios == '#[_ > 0]'
    And match response.usuarios == '#[_ >= 5]'
    And match response.usuarios contains { administrador: 'true' }
    And match each response.usuarios contains { _id: '#string' }
    And match response.usuarios[0] == '#object'
    * def lastIndex = response.usuarios.length - 1
    And match response.usuarios[lastIndex] == '#object'

  @predicate-validations
  Scenario: CT05 - Use JavaScript predicates for complex validations
    Given path '/produtos'
    When method GET
    Then status 200
    And match each response.produtos contains { preco: '#number? _ > 0' }
    And match each response.produtos contains { quantidade: '#number? _ >= 0' }
    And match each response.produtos contains { nome: '#string? _.length > 3' }
    And match each response.produtos contains { preco: '#number? _ > 0 && _ < 1000000' }
    
    * def products = response.produtos
    * def ids = karate.map(products, function(x){ return x._id })
    * def uniqueIds = new Set(ids)
    And match ids.length == uniqueIds.size

  @contains-validation
  Scenario: CT06 - Validate presence and absence of fields
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response contains { quantidade: '#number' }
    And match response contains { usuarios: '#array' }
    And match response !contains { error: '#string' }
    And match response !contains { errorMessage: '#string' }
    And match each response.usuarios contains { nome: '#string', email: '#string' }
    And match each response.usuarios !contains { cpf: '#string' }


  @only-validation
  Scenario: CT07 - Validate that JSON contains ONLY the specified fields
    Given path '/usuarios'
    When method GET
    Then status 200
    And match response == { quantidade: '#number', usuarios: '#array' }
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

  @jsonpath-validation
  Scenario: CT08 - Use JSON Path to extract and validate data
    Given path '/usuarios'
    When method GET
    Then status 200
    
    * def admins = karate.jsonPath(response, "$.usuarios[?(@.administrador=='true')]")
    * print 'Admins found:', admins.length
    And match admins == '#array'
    
    * def emails = karate.jsonPath(response, "$.usuarios[*].email")
    * print 'Emails:', emails
    And match emails == '#[] #string'
    
    * def firstUser = karate.jsonPath(response, "$.usuarios[0]")
    And match firstUser == '#object'


  @javascript-validation
  Scenario: CT09 - Use JavaScript for custom validations
    Given path '/produtos'
    When method GET
    Then status 200
    
    * def expensiveProducts = karate.filter(response.produtos, function(x){ return x.preco > 100 })
    * print 'Expensive products:', expensiveProducts.length
    
    * def productNames = karate.map(response.produtos, function(x){ return x.nome })
    * print 'Product names:', productNames
    
    * def prices = karate.map(response.produtos, function(x){ return x.preco })
    * def totalPrice = prices.reduce(function(a, b){ return a + b }, 0)
    * print 'Total sum of prices:', totalPrice
    
    * def productExists = response.produtos.some(function(x){ return x.nome.includes('Logitech') })
    * print 'Does Logitech product exist?', productExists


  @fuzzy-validation
  Scenario: CT10 - Flexible validations (fuzzy matching)
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
    
    And match each response.usuarios contains
      """
      {
        nome: '#string',
        email: '#string'
      }
      """


  @value-validation
  Scenario: CT11 - Compare with specific expected values
    * def expectedEmail = 'fulano@qa.com'
    
    Given path '/usuarios'
    And param email = expectedEmail
    When method GET
    Then status 200
    
    * def user = response.usuarios[0]
    And match user.email == expectedEmail
    And match user contains { email: '#(expectedEmail)', administrador: 'true' }
    
    * def expectedId = user._id
    And match user._id == expectedId


  @error-validations
  Scenario: CT12 - Validate error message structure
    * def duplicateEmail = 'test' + new Date().getTime() + '@test.com'
    * def user =
      """
      {
        "nome": "Test",
        "email": "#(duplicateEmail)",
        "password": "senha123",
        "administrador": "true"
      }
      """
    
    Given path '/usuarios'
    And request user
    When method POST
    Then status 201
    
    Given path '/usuarios'
    And request user
    When method POST
    Then status 400
    And match response ==
      """
      {
        message: '#string',
        idUsuario: '#string'
      }
      """
    
    And match response.message == 'Este email já está sendo usado'


  @nested-validation
  Scenario: CT13 - Validate JSON with complex nested objects
    * def complexJson =
      """
      {
        "user": {
          "name": "John",
          "contact": {
            "email": "john@test.com",
            "phones": [
              { "type": "mobile", "number": "11999999999" },
              { "type": "home", "number": "1133333333" }
            ]
          }
        }
      }
      """
    
    And match complexJson.user.name == 'John'
    And match complexJson.user.contact.email == 'john@test.com'
    And match complexJson.user.contact.phones == '#[2]'
    And match complexJson.user.contact.phones[0].type == 'mobile'
    And match each complexJson.user.contact.phones contains { number: '#string' }


  @numeric-validation
  Scenario: CT14 - Number comparison validations
    Given path '/produtos'
    When method GET
    Then status 200
    
    * def product = response.produtos[0]
    
    And match product.preco > 0
    And match product.preco >= 0
    And match product.quantidade >= 0
    And match product.preco > 0 && product.preco < 1000000
    And match Math.floor(product.quantidade) == product.quantidade


  @combined-validation
  Scenario: CT15 - Combine multiple validation techniques
    Given path '/usuarios'
    And param administrador = 'true'
    When method GET
    Then status 200
    
    And match response contains { quantidade: '#number', usuarios: '#array' }
    And match response.usuarios == '#[_ > 0]'
    And match each response.usuarios ==
      """
      {
        nome: '#string? _.length > 0',
        email: '#regex .+@.+\\..+',
        password: '#string',
        administrador: 'true',
        _id: '#string? _.length > 10'
      }
      """
    
    * def users = response.usuarios
    * def allAdmins = users.every(function(x){ return x.administrador == 'true' })
    And match allAdmins == true
    * print '✅ All validations passed successfully!'
