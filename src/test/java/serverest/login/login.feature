# language: pt
@login
Funcionalidade: Autenticação de Usuários - Login

  Contexto:
    * url 'https://serverest.dev'

  # ============================================
  # EXEMPLO 1: Login com Sucesso e Validação de Token
  # ============================================
  @login-sucesso @smoke
  Cenario: Realizar login com credenciais válidas e validar token
    * def credenciais =
      """
      {
        "email": "fulano@qa.com",
        "password": "teste"
      }
      """
    
    Dado caminho '/login'
    E request credenciais
    Quando método POST
    Então status 200
    
    # Validar estrutura da resposta
    E combina resposta ==
      """
      {
        message: '#string',
        authorization: '#string'
      }
      """
    
    # Validar mensagem específica
    E combina resposta.message == 'Login realizado com sucesso'
    
    # Validar que token não está vazio
    E combina resposta.authorization == '#notnull'
    E combina resposta.authorization == '#? _.length > 50'
    
    # Salvar token para uso posterior
    * def authToken = resposta.authorization
    * print 'Token gerado:', authToken


  # ============================================
  # EXEMPLO 2: Validação de Login Inválido
  # ============================================
  @login-invalido
  Cenario: Tentar login com credenciais inválidas
    * def credenciaisInvalidas =
      """
      {
        "email": "usuario@inexistente.com",
        "password": "senhaerrada"
      }
      """
    
    Dado caminho '/login'
    E request credenciaisInvalidas
    Quando método POST
    Então status 401
    
    # Validar mensagem de erro
    E combina resposta.message == 'Email e/ou senha inválidos'
    
    # Validar que NÃO retornou token
    E combina resposta !contains { authorization: '#string' }


  # ============================================
  # EXEMPLO 3: Validação de Campos Obrigatórios
  # ============================================
  @validacao-campos-obrigatorios
  Esquema do Cenário: Validar campos obrigatórios no login
    * def dadosIncompletos =
      """
      {
        "email": "<email>",
        "password": "<password>"
      }
      """
    
    Dado caminho '/login'
    E request dadosIncompletos
    Quando método POST
    Então status 400
    E combina resposta contains { email: '#string' }
    
    Exemplos:
      | email              | password |
      |                    | senha123 |
      | teste@email.com    |          |
      |                    |          |


  # ============================================
  # EXEMPLO 4: Login e Uso do Token em Requisição
  # ============================================
  @login-e-usar-token
  Cenario: Fazer login e usar token para acessar recurso protegido
    # Step 1: Realizar login
    * def credenciais = { "email": "fulano@qa.com", "password": "teste" }
    
    Dado caminho '/login'
    E request credenciais
    Quando método POST
    Então status 200
    * def token = resposta.authorization
    
    # Step 2: Usar token para cadastrar produto (requer autenticação)
    * def novoProduto =
      """
      {
        "nome": "Produto Auth Test",
        "preco": 100,
        "descricao": "Produto de teste com autenticação",
        "quantidade": 10
      }
      """
    
    Dado caminho '/produtos'
    E header Authorization = token
    E request novoProduto
    Quando método POST
    Então status 201
    E combina resposta.message == 'Cadastro realizado com sucesso'


  # ============================================
  # EXEMPLO 5: Validação de Formato de Email
  # ============================================
  @validacao-formato-email
  Esquema do Cenário: Validar formato de email inválido
    * def loginInvalido = { "email": "<emailInvalido>", "password": "senha123" }
    
    Dado caminho '/login'
    E request loginInvalido
    Quando método POST
    Então status 400
    E combina resposta contains { email: '#string' }
    
    Exemplos:
      | emailInvalido    |
      | emailsemarroba   |
      | @semnome.com     |
      | email@semdominio |
      | email            |


  # ============================================
  # EXEMPLO 6: Reutilizar Login (Callable Feature)
  # ============================================
  @login-reutilizavel
  Cenario: Login reutilizável para outros testes
    # Este cenário pode ser chamado de outras features usando:
    # * def loginResult = call read('classpath:serverest/login/login.feature@login-reutilizavel')
    # * def token = loginResult.token
    
    * def credenciais = { "email": "fulano@qa.com", "password": "teste" }
    
    Dado caminho '/login'
    E request credenciais
    Quando método POST
    Então status 200
    
    # Retornar informações úteis
    * def token = resposta.authorization
    * def mensagem = resposta.message
