# language: pt
@usuarios
Funcionalidade: Gerenciamento de Usuários - ServeRest API

  Contexto:
    * url 'https://serverest.dev'
    * def randomEmail = function(){ return 'user' + new Date().getTime() + '@test.com' }

  # ============================================
  # EXEMPLO 1: GET - Validações Básicas de JSON
  # ============================================
  @listar @smoke
  Cenario: Listar todos os usuários e validar estrutura JSON
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Validar estrutura básica da resposta
    E combina resposta ==
      """
      {
        quantidade: '#number',
        usuarios: '#array'
      }
      """
    
    # Validar que quantidade é maior que 0
    E combina resposta.quantidade > 0
    
    # Validar que usuarios é um array não vazio
    E combina resposta.usuarios == '#[_ > 0]'
    
    # Validar estrutura de cada usuário no array
    E combina cada resposta.usuarios ==
      """
      {
        nome: '#string',
        email: '#regex .+@.+\\..+',
        password: '#string',
        administrador: '#string',
        _id: '#string'
      }
      """
    
    # Validar que administrador só contém 'true' ou 'false'
    E combina cada resposta.usuarios contains { administrador: '#regex true|false' }
    
    # Salvar dados para reutilização
    * def primeiroUsuario = resposta.usuarios[0]
    * print 'Primeiro usuário:', primeiroUsuario


  # ============================================
  # EXEMPLO 2: GET por ID - Validações Específicas
  # ============================================
  @buscar-por-id
  Cenario: Buscar usuário específico por ID
    # Primeiro, obter um ID válido
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    * def userId = resposta.usuarios[0]._id
    
    # Buscar por ID específico
    Dado caminho '/usuarios/' + userId
    Quando método GET
    Então status 200
    
    # Validar que resposta contém campos obrigatórios
    E combina resposta contains
      """
      {
        nome: '#present',
        email: '#present',
        _id: '#present'
      }
      """
    
    # Validar tipos específicos
    E combina resposta.nome == '#string'
    E combina resposta.email == '#string'
    E combina resposta._id == userId
    
    # Validar que não contém campos extras não esperados
    E combina resposta == { nome: '#string', email: '#string', password: '#string', administrador: '#string', _id: '#string' }


  # ============================================
  # EXEMPLO 3: POST - Criar e Validar Resposta
  # ============================================
  @cadastrar @smoke
  Cenario: Cadastrar novo usuário com validações completas
    * def novoEmail = randomEmail()
    * def dadosUsuario =
      """
      {
        "nome": "João Silva",
        "email": "#(novoEmail)",
        "password": "senha@123",
        "administrador": "true"
      }
      """
    
    Dado caminho '/usuarios'
    E request dadosUsuario
    Quando método POST
    Então status 201
    
    # Validar mensagem de sucesso
    E combina resposta.message == 'Cadastro realizado com sucesso'
    
    # Validar que retornou um ID
    E combina resposta._id == '#string'
    E combina resposta._id == '#notnull'
    
    # Salvar ID para limpeza posterior
    * def novoUserId = resposta._id
    
    # Verificar se usuário foi realmente criado
    Dado caminho '/usuarios/' + novoUserId
    Quando método GET
    Então status 200
    E combina resposta.nome == 'João Silva'
    E combina resposta.email == novoEmail


  # ============================================
  # EXEMPLO 4: Validações Avançadas com JsonPath
  # ============================================
  @validacoes-avancadas
  Cenario: Validações avançadas de JSON com filtros
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Filtrar usuários administradores
    * def admins = karate.filter(resposta.usuarios, function(x){ return x.administrador == 'true' })
    * print 'Total de administradores:', admins.length
    
    # Validar que existe pelo menos um admin
    E combina admins == '#[_ > 0]'
    
    # Buscar usuário específico por email usando JsonPath
    * def usuariosFiltrados = karate.jsonPath(resposta, "$.usuarios[?(@.administrador=='true')]")
    * print 'Usuários admin encontrados:', usuariosFiltrados.length
    
    # Extrair apenas os emails
    * def emails = karate.map(resposta.usuarios, function(x){ return x.email })
    * print 'Lista de emails:', emails
    
    # Validar array de emails
    E combina emails == '#[] #string'


  # ============================================
  # EXEMPLO 5: Validação de Erros e Status Codes
  # ============================================
  @validacao-erro
  Cenario: Validar mensagens de erro ao cadastrar email duplicado
    # Primeiro cadastro
    * def emailDuplicado = randomEmail()
    * def usuario1 =
      """
      {
        "nome": "Usuário 1",
        "email": "#(emailDuplicado)",
        "password": "senha123",
        "administrador": "false"
      }
      """
    
    Dado caminho '/usuarios'
    E request usuario1
    Quando método POST
    Então status 201
    
    # Tentar cadastrar novamente com mesmo email
    * def usuario2 =
      """
      {
        "nome": "Usuário 2",
        "email": "#(emailDuplicado)",
        "password": "outrasenha",
        "administrador": "true"
      }
      """
    
    Dado caminho '/usuarios'
    E request usuario2
    Quando método POST
    Então status 400
    
    # Validar mensagem de erro
    E combina resposta ==
      """
      {
        message: 'Este email já está sendo usado',
        idUsuario: '#string'
      }
      """
    
    # Validar que retornou o ID do usuário existente
    E combina resposta.idUsuario == '#notnull'


  # ============================================
  # EXEMPLO 6: Validações com Schema Fuzzy
  # ============================================
  @validacao-fuzzy
  Cenario: Validar com fuzzy matching (validação flexível)
    Dado caminho '/usuarios'
    E param administrador = 'true'
    Quando método GET
    Então status 200
    
    # Fuzzy matching - valida estrutura sem ser exato
    E combina resposta ==
      """
      {
        quantidade: '#number',
        usuarios: '#[]'
      }
      """
    
    # Validar que cada usuário contém pelo menos esses campos
    E combina cada resposta.usuarios contains
      """
      {
        nome: '#string',
        email: '#string',
        administrador: 'true'
      }
      """


  # ============================================
  # EXEMPLO 7: Validação Condicional
  # ============================================
  @validacao-condicional
  Cenario: Validações condicionais baseadas em valores
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Pegar primeiro usuário
    * def usuario = resposta.usuarios[0]
    
    # Validação condicional
    * if (usuario.administrador == 'true') karate.log('Usuário é administrador')
    * if (usuario.administrador == 'false') karate.log('Usuário não é administrador')
    
    # Validar comprimento do email
    E combina usuario.email == '#? _.length > 5'
    
    # Validar que senha existe e não está vazia
    E combina usuario.password == '#? _.length > 0'


  # ============================================
  # EXEMPLO 8: Validação de Arrays e Contains
  # ============================================
  @validacao-arrays
  Cenario: Validações complexas de arrays
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Validar tamanho do array
    E combina resposta.usuarios == '#[10]'
    # Ou validar que array não está vazio
    E combina resposta.usuarios == '#[_ > 0]'
    
    # Validar que array contém objeto com propriedades específicas
    E combina resposta.usuarios contains { administrador: 'true' }
    
    # Validar que todos os IDs são únicos
    * def ids = karate.map(resposta.usuarios, function(x){ return x._id })
    * def idsUnicos = new Set(ids)
    E combina ids.length == idsUnicos.size


  # ============================================
  # EXEMPLO 9: Validação com Regex
  # ============================================
  @validacao-regex
  Cenario: Validar formatos com expressões regulares
    * def novoEmail = 'teste.regex.' + new Date().getTime() + '@example.com'
    * def dadosUsuario =
      """
      {
        "nome": "Teste Regex",
        "email": "#(novoEmail)",
        "password": "SenhaForte@123",
        "administrador": "false"
      }
      """
    
    Dado caminho '/usuarios'
    E request dadosUsuario
    Quando método POST
    Então status 201
    
    # Buscar usuário criado
    Dado caminho '/usuarios/' + resposta._id
    Quando método GET
    Então status 200
    
    # Validar email com regex (formato email válido)
    E combina resposta.email == '#regex .+@.+\\..+'
    
    # Validar que nome contém apenas letras e espaços
    E combina resposta.nome == '#regex [A-Za-z\\s]+'
    
    # Validar que ID é alfanumérico
    E combina resposta._id == '#regex [A-Za-z0-9]+'


  # ============================================
  # EXEMPLO 10: Validação Negativa (Not Contains)
  # ============================================
  @validacao-negativa
  Cenario: Validar ausência de campos
    Dado caminho '/usuarios'
    Quando método GET
    Então status 200
    
    # Validar que resposta NÃO contém campos de erro
    E combina resposta !contains { error: '#string' }
    E combina resposta !contains { mensagemErro: '#string' }
    
    # Validar que usuário não tem campos sensíveis extras
    * def usuario = resposta.usuarios[0]
    E combina usuario !contains { cpf: '#string' }
    E combina usuario !contains { telefone: '#string' }


  # ============================================
  # EXEMPLO 11: Validação com Variáveis e Reutilização
  # ============================================
  @validacao-variaveis
  Cenario: Usar variáveis para validações dinâmicas
    * def emailEsperado = 'fulano@qa.com'
    * def nomeEsperado = 'Fulano da Silva'
    
    Dado caminho '/usuarios'
    E param email = emailEsperado
    Quando método GET
    Então status 200
    
    # Validar primeiro resultado
    * def usuario = resposta.usuarios[0]
    E combina usuario.email == emailEsperado
    
    # Validar múltiplos campos de uma vez
    E combina usuario contains { email: '#(emailEsperado)', nome: '#string' }


  # ============================================
  # EXEMPLO 12: Validar JSON Aninhado
  # ============================================
  @validacao-json-aninhado
  Cenario: Preparar dados para validação de objetos aninhados
    * def dadosComplexos =
      """
      {
        "nome": "Usuário Complexo",
        "email": "#(randomEmail())",
        "password": "senha123",
        "administrador": "true"
      }
      """
    
    Dado caminho '/usuarios'
    E request dadosComplexos
    Quando método POST
    Então status 201
    
    # Validar resposta aninhada
    E combina resposta ==
      """
      {
        message: '#string',
        _id: '#string'
      }
      """
    
    # Validar propriedades específicas
    E combina resposta.message == 'Cadastro realizado com sucesso'
    E combina resposta._id == '#? _.length > 10'
