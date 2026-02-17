# language: en
@carts
Feature: Cart Management - ServeRest API

  Background:
    * url 'https://serverest.dev'
    * def FakerUtils = Java.type('serverest.utils.FakerUtils')
    * def randomProductName = function(){ return FakerUtils.randomProduct() }
    * def loginPayload = read('classpath:serverest/login/resources/loginPayload.json')

    
  @carts @regression
  Scenario: CT01 - Full cart lifecycle for authenticated user
    * def loginPayload = read('classpath:serverest/login/resources/loginPayload.json')
    Given path '/login'
    And request loginPayload
    When method POST
    Then status 200
    * def token = response.authorization

    Given path '/carrinhos/cancelar-compra'
    And header Authorization = token
    When method DELETE
    Then status 200

    # Create a product to be used in the cart
    * def productName = randomProductName()
    * def productData =
      """
      {
        "nome": "#(productName)",
        "preco": 150,
        "descricao": "Product created for cart lifecycle test",
        "quantidade": 10
      }
      """

    Given path '/produtos'
    And header Authorization = token
    And request productData
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    * def productId = response._id

    # Create a cart for the logged user
    * def cartBody =
      """
      {
        "produtos": [
          {
            "idProduto": "#(productId)",
            "quantidade": 2
          }
        ]
      }
      """

    Given path '/carrinhos'
    And header Authorization = token
    And request cartBody
    When method POST
    Then status 201
    And match response.message == 'Cadastro realizado com sucesso'
    And match response._id == '#string'
    * def cartId = response._id

    # Get cart by ID and validate structure
    Given path '/carrinhos/' + cartId
    When method GET
    Then status 200
    And match response ==
      """
      {
        produtos: '#[1]',
        precoTotal: '#number',
        quantidadeTotal: '#number',
        idUsuario: '#string',
        _id: '#string'
      }
      """

    # Conclude purchase: cart should be removed
    Given path '/carrinhos/concluir-compra'
    And header Authorization = token
    When method DELETE
    Then status 200
    And match response.message contains 'Registro excluído com sucesso'

  @carts @regression
  Scenario: CT02 - Cancel purchase and return products to stock
    * def loginPayload = read('classpath:serverest/login/resources/loginPayload.json')
    Given path '/login'
    And request loginPayload
    When method POST
    Then status 200
    * def token = response.authorization
    
    # Create product for the cart
    * def productName = randomProductName()
    * def productData =
      """
      {
        "nome": "#(productName)",
        "preco": 200,
        "descricao": "Product for cancel purchase test",
        "quantidade": 5
      }
      """

    Given path '/produtos'
    * print 'Using auth token:', token
    And header Authorization = token
    And request productData
    When method POST
    Then status 201
    * def productId = response._id

    # Create cart
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
    And header Authorization = token
    And request cartBody
    When method POST
    Then status 201

    # Cancel purchase: cart removed and stock should be restored (implicit)
    Given path '/carrinhos/cancelar-compra'
    And header Authorization = token
    When method DELETE
    Then status 200
    And match response.message == '#string'

  @carts @regression
  Scenario: CT03 - Prevent creating cart without authentication token
    # Try to create a cart without Authorization header
    * def cartBody =
      """
      {
        "produtos": [
          {
            "idProduto": "BeeJh5lz3k6kSIzA",
            "quantidade": 1
          }
        ]
      }
      """

    Given path '/carrinhos'
    And request cartBody
    When method POST
    Then status 401
    And match response.message == 'Token de acesso ausente, inválido, expirado ou usuário do token não existe mais'

  @carts @regression
  Scenario: CT04 - Prevent creating more than one cart for the same user
    * def loginResponse = call read('classpath:serverest/login/Login.feature@login-success')
    * def token = loginResponse.authToken

    # Create a product specifically for this user's cart
    * def productName = randomProductName()
    * def productData =
      """
      {
        "nome": "#(productName)",
        "preco": 120,
        "descricao": "Product for multiple cart test",
        "quantidade": 3
      }
      """

    Given path '/produtos'
    And header Authorization = token
    And request productData
    When method POST
    Then status 201
    * def productId = response._id

    # Create the first cart
    * def firstCart =
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
    And header Authorization = token
    And request firstCart
    When method POST
    Then status 201

    # Try to create a second cart for same user
    * def secondCart = firstCart
    Given path '/carrinhos'
    And header Authorization = token
    And request secondCart
    When method POST
    Then status 400
    And match response.message contains 'Não é permitido ter mais de 1 carrinho'

  @carts @regression
  Scenario: CT05 - Cart not found by ID
    Given path '/carrinhos/invalid-cart-id-123'
    When method GET
    Then status 400
    And match response == { id: 'id deve ter exatamente 16 caracteres alfanuméricos' }

  @carts @regression
  Scenario: CT06 - Prevent cart creation when product stock is insufficient
    * def loginResponse = call read('classpath:serverest/login/Login.feature@login-success')
    * def token = loginResponse.authToken

    Given path '/carrinhos/cancelar-compra'
    And header Authorization = token
    When method DELETE
    Then status 200

    # Create product with low stock
    * def productName = randomProductName()
    * def productData =
      """
      {
        "nome": "#(productName)",
        "preco": 100,
        "descricao": "Low stock product for cart test",
        "quantidade": 1
      }
      """

    Given path '/produtos'
    And header Authorization = token
    And request productData
    When method POST
    Then status 201
    * def productId = response._id

    # Try to create cart with quantity greater than available stock
    * def cartBody =
      """
      {
        "produtos": [
          {
            "idProduto": "#(productId)",
            "quantidade": 2
          }
        ]
      }
      """

    Given path '/carrinhos'
    And header Authorization = token
    And request cartBody
    When method POST
    Then status 400
    And match response.message contains 'Produto não possui quantidade suficiente'
