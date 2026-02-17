# language: en
@products
Feature: Product Management (Requires Admin Authentication)

  Background:
    * url 'https://serverest.dev'
    * def loginPayload = read('classpath:serverest/login/resources/loginPayload.json')
    Given path '/login'
    And request loginPayload
    When method POST
    Then status 200
    * def token = response.authorization
    * def randomName = function(){ return 'Product ' + new Date().getTime() }

  @list-products @smoke @regression
  Scenario: CT01 - List all products and validate JSON structure
    Given path '/produtos'
    When method GET
    Then status 200
    
    And match response ==
      """
      {
        quantidade: '#number',
        produtos: '#array'
      }
      """
    
    And match each response.produtos ==
        """
        {
          nome: '#string',
          preco: '#number',
          descricao: '#string',
          quantidade: '#number',
          _id: '#string'
        }
        """
    
    And match each response.produtos contains { preco: '#number? _ > 0' }
    
    And match each response.produtos contains { quantidade: '#number? _ >= 0' }


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
    
    And match response ==
      """
      {
        message: 'Cadastro realizado com sucesso',
        _id: '#string'
      }
      """
    
    * def productId = response._id
    
    Given path '/produtos/' + productId
    When method GET
    Then status 200
    And match response.nome == productName
    And match response.preco == 250
    And match response.quantidade == 100


  @duplicate-product @regression
  Scenario: CT03 - Validate error when creating a product with a duplicate name
    * def duplicateName = 'Duplicate Product Test ' + new Date().getTime()
    * def product =
      """
      {
        "nome": "#(duplicateName)",
        "preco": 150,
        "descricao": "First product",
        "quantidade": 50
      }
      """
    
      Given path '/produtos'
    And header Authorization = token
    And request product
    When method POST
    Then status 201
    
    Given path '/produtos'
    And header Authorization = token
    And request product
    When method POST
    Then status 400
    
    And match response ==
        """
        {
          message: 'Já existe produto com esse nome'
        }
        """


  @search-with-filters @regression
  Scenario: CT04 - Search for products using query parameters
    Given path '/produtos'
    And param nome = 'Logitech'
    When method GET
    Then status 200
    
    * def products = response.produtos
    * def allContainName = karate.filter(products, function(x){ return x.nome.includes('Logitech') })
      And assert allContainName.length > 0
    
    Given path '/produtos'
    And param preco = 100
    When method GET
    Then status 200


  @update-product @regression
  Scenario: CT05 - Update information of an existing product
    * def productName = randomName()
    * def initialProduct =
      """
      {
        "nome": "#(productName)",
        "preco": 100,
        "descricao": "Original description",
        "quantidade": 50
      }
      """
    
      Given path '/produtos'
    And header Authorization = token
    And request initialProduct
    When method POST
    Then status 201
    * def productId = response._id
    
    * def updatedProduct =
      """
      {
        "nome": "#(productName)",
        "preco": 200,
        "descricao": "Updated description",
        "quantidade": 75
      }
      """
    
    Given path '/produtos/' + productId
    And header Authorization = token
    And request updatedProduct
    When method PUT
    Then status 200
    And match response.message == 'Registro alterado com sucesso'
    
    Given path '/produtos/' + productId
    When method GET
    Then status 200
    And match response.preco == 200
    And match response.descricao == 'Updated description'
    And match response.quantidade == 75


  @price-validation @regression
  Scenario: CT06 - Validate price calculations and comparisons
    Given path '/produtos'
    When method GET
    Then status 200
    
    * def products = response.produtos
    * def prices = karate.map(products, function(x){ return x.preco })
    * def maxPrice = Math.max.apply(null, prices)
    * print 'Highest Price:', maxPrice
    
    * def minPrice = Math.min.apply(null, prices)
    * print 'Lowest Price:', minPrice
    
    * def sumPrices = prices.reduce(function(a, b){ return a + b }, 0)
    * def avgPrice = sumPrices / prices.length
    * print 'Average Price:', avgPrice
    
    And match each products contains { preco: '#number? _ > 0 && _ < 100000' }


  @unauthorized @regression
  Scenario: CT07 - Attempt to create a product without an authentication token
    * def product =
      """
      {
        "nome": "Product Without Auth",
        "preco": 100,
        "descricao": "Test",
        "quantidade": 10
      }
      """
    
      Given path '/produtos'
    And request product
    When method POST
    Then status 401
    
    And match response ==
      """
      {
        message: 'Token de acesso ausente, inválido, expirado ou usuário do token não existe mais'
      }
      """


  @field-validation @regression
  Scenario Outline: CT08 - Validate required fields when creating a product
    * def incompleteProduct =
      """
      {
        "nome": "<nome>",
        "preco": <preco>,
        "descricao": "<descricao>",
        "quantidade": <quantidade>
      }
      """
    
      Given path '/produtos'
    And header Authorization = token
    And request incompleteProduct
    When method POST
    Then status 400
    
    Examples:
      | nome              | preco | descricao | quantidade | reason              |
      |                   | 100   | Desc      | 10         | Empty name          |
      | Product Test      | -10   | Desc      | 10         | Negative price      |
      | Product Test      | 100   |           | 10         | Empty description   |
      | Product Test      | 100   | Desc      | -5         | Negative quantity   |


  @complex-json @regression
  Scenario: CT09 - Work with complex JSON data
    Given path '/produtos'
    When method GET
    Then status 200
    
    * def cheapProducts = karate.filter(response.produtos, function(x){ return x.preco < 100 })
    * def mediumProducts = karate.filter(response.produtos, function(x){ return x.preco >= 100 && x.preco < 500 })
    * def expensiveProducts = karate.filter(response.produtos, function(x){ return x.preco >= 500 })
    
    * def grouping =
      """
      {
        cheap: '#(cheapProducts)',
        medium: '#(mediumProducts)',
        expensive: '#(expensiveProducts)'
      }
      """
    
    * print 'Cheap Products:', cheapProducts.length
    * print 'Medium Products:', mediumProducts.length
    * print 'Expensive Products:', expensiveProducts.length
    
    And match grouping contains { cheap: '#array', medium: '#array', expensive: '#array' }


  @delete-product @regression
  Scenario: CT10 - Delete an existing product
    * def productName = randomName()
    * def product =
      """
      {
        "nome": "#(productName)",
        "preco": 100,
        "descricao": "Product to delete",
        "quantidade": 10
      }
      """
    
      Given path '/produtos'
    And header Authorization = token
    And request product
    When method POST
    Then status 201
    * def productId = response._id
    
    Given path '/produtos/' + productId
    And header Authorization = token
    When method DELETE
    Then status 200
    And match response.message == 'Registro excluído com sucesso'
    
    Given path '/produtos/' + productId
    When method GET
    Then status 400
    And match response.message == 'Produto não encontrado'


  @create-product-from-json @regression
  Scenario: CT11 - Create a product from fixed JSON payload
    * def productPayload = read('resources/productPayload.json')
    * set productPayload.nome = randomName()
    Given path '/produtos'
    And header Authorization = token
    And request productPayload
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'


  @delete-product-in-cart @regression
  Scenario: CT12 - Prevent deleting a product that is part of a cart
    # Create a product that will be associated with a cart
    * def productName = randomName()
    * def product =
      """
      {
        "nome": "#(productName)",
        "preco": 300,
        "descricao": "Product linked to cart",
        "quantidade": 10
      }
      """

      Given path '/produtos'
    And header Authorization = token
    And request product
    When method POST
    Then status 201
    * def productId = response._id

    # Create a non-admin user and login to create a cart
    * def userEmail = 'cart.user.' + new Date().getTime() + '@example.com'
    * def userPassword = 'SenhaSegura@123'
    * def userData =
      """
      {
        "nome": "Cart User",
        "email": "#(userEmail)",
        "password": "#(userPassword)",
        "administrador": "false"
      }
      """

    Given path '/usuarios'
    And request userData
    When method POST
    Then status 201

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

    # Ensure no existing cart for this user
    Given path '/carrinhos/cancelar-compra'
    And header Authorization = userToken
    When method DELETE
    Then status 200

    # Create a cart including the created product
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

    # Try to delete the product and expect an error because it is in a cart
    Given path '/produtos/' + productId
    And header Authorization = token
    When method DELETE
    Then status 400
    And match response.message == 'Não é permitido excluir produto que faz parte de carrinho'


  @admin-only-route @regression
  Scenario: CT13 - Restrict product creation to administrators only
    # Create a non-admin user
    * def userEmail = 'non.admin.' + new Date().getTime() + '@example.com'
    * def userPassword = 'SenhaSegura@123'
    * def userData =
      """
      {
        "nome": "Non Admin User",
        "email": "#(userEmail)",
        "password": "#(userPassword)",
        "administrador": "false"
      }
      """

    Given path '/usuarios'
    And request userData
    When method POST
    Then status 201

    # Login as non-admin user
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
    * def nonAdminToken = response.authorization

    # Try to create a product using non-admin token and expect 403
    * def productData =
      """
      {
        "nome": "Restricted Product",
        "preco": 500,
        "descricao": "Product should be created only by admins",
        "quantidade": 5
      }
      """

      Given path '/produtos'
    And header Authorization = nonAdminToken
    And request productData
    When method POST
    Then status 403
    And match response.message == 'Rota exclusiva para administradores'
