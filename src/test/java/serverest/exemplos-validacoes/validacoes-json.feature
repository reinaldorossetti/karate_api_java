# language: pt
@exemplos-validacoes
Funcionalidade: Exemplos Completos de Validações JSON com Karate

  # ============================================
  # GUIA COMPLETO DE VALIDAÇÕES JSON NO KARATE
  # ============================================

  Contexto:
    * url 'https://serverest.dev'

  # ============================================
  # 1. VALIDAÇÕES BÁSICAS DE TIPO
  # ============================================
  @validacao-tipos
  Cenario: Validar tipos de dados em JSON
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Validar tipos primitivos
    E combina resposta.quantidade == '#number'           # É um número
    E combina resposta.usuarios == '#array'              # É um array
    E combina resposta.usuarios[0].nome == '#string'     # É uma string
    E combina resposta.usuarios[0].administrador == '#string'  # String (não boolean)
    
    # Validar nullable/optional
    E combina resposta.quantidade == '#notnull'          # Não é null
    E combina resposta.quantidade == '#present'          # Campo está presente
    
    # Validar tipos com predicado
    E combina resposta.quantidade == '#number? _ > 0'    # Número maior que 0
    E combina resposta.usuarios == '#[_ > 0]'            # Array com tamanho > 0


  # ============================================
  # 2. VALIDAÇÕES DE ESTRUTURA (SCHEMA)
  # ============================================
  @validacao-schema
  Cenario: Validar estrutura completa do JSON
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Validação exata da estrutura
    E combina resposta ==
      """
      {
        quantidade: '#number',
        usuarios: '#array'
      }
      """
    
    # Validação de cada item do array
    E combina cada resposta.usuarios ==
      """
      {
        nome: '#string',
        email: '#string',
        password: '#string',
        administrador: '#string',
        _id: '#string'
      }
      """
    
    # Validação parcial (contém pelo menos estes campos)
    E combina resposta contains
      """
      {
        quantidade: '#number'
      }
      """


  # ============================================
  # 3. VALIDAÇÕES COM REGEX
  # ============================================
  @validacao-regex
  Cenario: Usar expressões regulares para validar formatos
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    * def usuario = resposta.usuarios[0]
    
    # Validar formato de email
    E combina usuario.email == '#regex .+@.+\\..+'
    
    # Validar que nome contém apenas letras e espaços
    E combina usuario.nome == '#regex ^[A-Za-zÀ-ÿ\\s]+$'
    
    # Validar que ID é alfanumérico
    E combina usuario._id == '#regex ^[A-Za-z0-9]+$'
    
    # Validar que administrador é 'true' ou 'false'
    E combina usuario.administrador == '#regex ^(true|false)$'


  # ============================================
  # 4. VALIDAÇÕES DE ARRAY
  # ============================================
  @validacao-arrays
  Cenario: Validações avançadas de arrays
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Validar que é um array
    E combina resposta.usuarios == '#array'
    
    # Validar tamanho do array
    E combina resposta.usuarios == '#[10]'              # Exatamente 10 itens
    E combina resposta.usuarios == '#[_ > 0]'           # Mais de 0 itens
    E combina resposta.usuarios == '#[_ >= 5]'          # 5 ou mais itens
    
    # Validar que array contém um objeto específico
    E combina resposta.usuarios contains { administrador: 'true' }
    
    # Validar que TODOS os itens atendem uma condição
    E combina cada resposta.usuarios contains { _id: '#string' }
    
    # Validar primeiro e último elemento
    E combina resposta.usuarios[0] == '#object'
    * def ultimoIndex = resposta.usuarios.length - 1
    E combina resposta.usuarios[ultimoIndex] == '#object'


  # ============================================
  # 5. VALIDAÇÕES CONDICIONAIS (PREDICADOS)
  # ============================================
  @validacao-predicados
  Cenario: Usar predicados JavaScript para validações complexas
    Dado caminho '/produtos'
    Quando método GET
    Então status 200
    
    # Validar com função anônima
    E combina cada resposta.produtos contains { preco: '#number? _ > 0' }
    E combina cada resposta.produtos contains { quantidade: '#number? _ >= 0' }
    
    # Validar comprimento de string
    E combina cada resposta.produtos contains { nome: '#string? _.length > 3' }
    
    # Validações múltiplas
    E combina cada resposta.produtos contains { preco: '#number? _ > 0 && _ < 1000000' }
    
    # Validar IDs únicos
    * def produtos = resposta.produtos
    * def ids = karate.map(produtos, function(x){ return x._id })
    * def idsUnicos = new Set(ids)
    E combina ids.length == idsUnicos.size


  # ============================================
  # 6. VALIDAÇÕES COM CONTAINS E NOT CONTAINS
  # ============================================
  @validacao-contains
  Cenario: Validar presença e ausência de campos
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Validar que contém campos
    E combina resposta contains { quantidade: '#number' }
    E combina resposta contains { usuarios: '#array' }
    
    # Validar que NÃO contém campos
    E combina resposta !contains { erro: '#string' }
    E combina resposta !contains { mensagemErro: '#string' }
    
    # Validar que cada usuário contém campos obrigatórios
    E combina cada resposta.usuarios contains { nome: '#string', email: '#string' }
    
    # Validar que usuários NÃO têm campos sensíveis extras
    E combina cada resposta.usuarios !contains { cpf: '#string' }


  # ============================================
  # 7. VALIDAÇÕES COM ONLY (Campos Exatos)
  # ============================================
  @validacao-only
  Cenario: Validar que JSON contém APENAS os campos especificados
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Validar campos exatos da resposta principal
    E combina resposta == { quantidade: '#number', usuarios: '#array' }
    
    # Validar que cada usuário tem APENAS estes campos
    E combina cada resposta.usuarios ==
      """
      {
        nome: '#string',
        email: '#string',
        password: '#string',
        administrador: '#string',
        _id: '#string'
      }
      """


  # ============================================
  # 8. VALIDAÇÕES COM JSON PATH
  # ============================================
  @validacao-jsonpath
  Cenario: Usar JSON Path para extrair e validar dados
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Extrair usuários administradores usando JsonPath
    * def admins = karate.jsonPath(resposta, "$.usuarios[?(@.administrador=='true')]")
    * print 'Administradores encontrados:', admins.length
    E combina admins == '#array'
    
    # Extrair todos os emails
    * def emails = karate.jsonPath(resposta, "$.usuarios[*].email")
    * print 'Emails:', emails
    E combina emails == '#[] #string'
    
    # Extrair primeiro usuário
    * def primeiroUsuario = karate.jsonPath(resposta, "$.usuarios[0]")
    E combina primeiroUsuario == '#object'


  # ============================================
  # 9. VALIDAÇÕES COM FUNÇÕES JAVASCRIPT
  # ============================================
  @validacao-javascript
  Cenario: Usar JavaScript para validações customizadas
    Dado caminho '/produtos'
    Quando método GET
    Então status 200
    
    # Filtrar produtos por condição
    * def produtosCaros = karate.filter(resposta.produtos, function(x){ return x.preco > 100 })
    * print 'Produtos caros:', produtosCaros.length
    
    # Mapear para extrair campos específicos
    * def nomesProdutos = karate.map(resposta.produtos, function(x){ return x.nome })
    * print 'Nomes dos produtos:', nomesProdutos
    
    # Calcular soma de preços
    * def precos = karate.map(resposta.produtos, function(x){ return x.preco })
    * def somaPrecos = precos.reduce(function(a, b){ return a + b }, 0)
    * print 'Soma total dos preços:', somaPrecos
    
    # Verificar se existe produto específico
    * def produtoExiste = resposta.produtos.some(function(x){ return x.nome.includes('Logitech') })
    * print 'Existe produto Logitech?', produtoExiste


  # ============================================
  # 10. VALIDAÇÕES FUZZY MATCHING
  # ============================================
  @validacao-fuzzy
  Cenario: Validações flexíveis (fuzzy matching)
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Fuzzy match - ignora campos extras
    E combina resposta ==
      """
      {
        quantidade: '#number',
        usuarios: '#array'
      }
      """
    
    # Fuzzy match em arrays - valida estrutura sem ser exato
    E combina cada resposta.usuarios contains
      """
      {
        nome: '#string',
        email: '#string'
      }
      """


  # ============================================
  # 11. VALIDAÇÕES DE VALORES ESPERADOS
  # ============================================
  @validacao-valores
  Cenario: Comparar com valores esperados específicos
    * def emailEsperado = 'fulano@qa.com'
    
    Dado caminho '/usuarios'
    E param email = emailEsperado
    Quando método GET
    Então status 200
    
    # Validar valor exato
    * def usuario = resposta.usuarios[0]
    E combina usuario.email == emailEsperado
    
    # Validar múltiplos valores
    E combina usuario contains { email: '#(emailEsperado)', administrador: 'true' }
    
    # Validar usando variável
    * def idEsperado = usuario._id
    E combina usuario._id == idEsperado


  # ============================================
  # 12. VALIDAÇÕES DE ERRO
  # ============================================
  @validacao-erros
  Cenario: Validar estrutura de mensagens de erro
    * def emailDuplicado = 'teste' + new Date().getTime() + '@test.com'
    * def usuario =
      """
      {
        "nome": "Teste",
        "email": "#(emailDuplicado)",
        "password": "senha123",
        "administrador": "true"
      }
      """
    
    # Primeiro cadastro
    Dado caminho '/usuarios'
    E request usuario
    Quando método POST
    Então status 201
    
    # Segundo cadastro (duplicado)
    Dado caminho '/usuarios'
    E request usuario
    Quando método POST
    Então status 400
    
    # Validar estrutura do erro
    E combina resposta ==
      """
      {
        message: '#string',
        idUsuario: '#string'
      }
      """
    
    # Validar mensagem específica
    E combina resposta.message == 'Este email já está sendo usado'


  # ============================================
  # 13. VALIDAÇÕES ANINHADAS
  # ============================================
  @validacao-aninhada
  Cenario: Validar JSON com objetos aninhados complexos
    # Este é um exemplo genérico pois ServeRest não tem JSON muito aninhado
    * def jsonComplexo =
      """
      {
        "usuario": {
          "nome": "João",
          "contato": {
            "email": "joao@test.com",
            "telefones": [
              { "tipo": "celular", "numero": "11999999999" },
              { "tipo": "residencial", "numero": "1133333333" }
            ]
          }
        }
      }
      """
    
    # Validar estrutura aninhada
    E combina jsonComplexo.usuario.nome == 'João'
    E combina jsonComplexo.usuario.contato.email == 'joao@test.com'
    E combina jsonComplexo.usuario.contato.telefones == '#[2]'
    E combina jsonComplexo.usuario.contato.telefones[0].tipo == 'celular'
    
    # Validar com each em array aninhado
    E combina cada jsonComplexo.usuario.contato.telefones contains { numero: '#string' }


  # ============================================
  # 14. VALIDAÇÃO DE COMPARAÇÕES NUMÉRICAS
  # ============================================
  @validacao-numerica
  Cenario: Validações de comparações entre números
    Dado caminho '/produtos'
    Quando método GET
    Então status 200
    
    * def produto = resposta.produtos[0]
    
    # Comparações numéricas
    E combina produto.preco > 0
    E combina produto.preco >= 0
    E combina produto.quantidade >= 0
    
    # Validar range
    E combina produto.preco > 0 && produto.preco < 1000000
    
    # Validar que é número inteiro
    E combina Math.floor(produto.quantidade) == produto.quantidade


  # ============================================
  # 15. VALIDAÇÕES COMBINADAS
  # ============================================
  @validacao-combinada
  Cenario: Combinar múltiplas técnicas de validação
    Dado caminho '/usuarios'
    E param administrador = 'true'
    Quando método GET
    Então status 200
    
    # Validar estrutura E valores E tipos E condições
    E combina resposta contains { quantidade: '#number', usuarios: '#array' }
    E combina resposta.usuarios == '#[_ > 0]'
    E combina cada resposta.usuarios ==
      """
      {
        nome: '#string? _.length > 0',
        email: '#regex .+@.+\\..+',
        password: '#string',
        administrador: 'true',
        _id: '#string? _.length > 10'
      }
      """
    
    # Validar com filtro JavaScript
    * def usuarios = resposta.usuarios
    * def todosAdmins = usuarios.every(function(x){ return x.administrador == 'true' })
    E combina todosAdmins == true
    
    * print '✅ Todas as validações passaram com sucesso!'
