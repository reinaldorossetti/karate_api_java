package serverest.usuarios;

import com.intuit.karate.junit5.Karate;

/**
 * Classe de teste JUnit 5 para executar os testes de Usuários
 * 
 * Exemplos de execução:
 * - Executar todos os testes: mvn test
 * - Executar apenas esta classe: mvn test -Dtest=UsuariosTest
 * - Executar por tags: mvn test -Dkarate.options="--tags @smoke"
 */
public class UsuariosTest {

    /**
     * Executa todos os cenários da feature usuarios.feature
     */
    @Karate.Test
    Karate testUsuarios() {
        return Karate.run("usuarios").relativeTo(getClass());
    }

    /**
     * Executa apenas os testes marcados com @smoke
     */
    @Karate.Test
    Karate testSmoke() {
        return Karate.run("usuarios")
                .tags("@smoke")
                .relativeTo(getClass());
    }

    /**
     * Executa testes específicos por tag
     */
    @Karate.Test
    Karate testValidacoes() {
        return Karate.run("usuarios")
                .tags("@validacao-erro,@validacao-regex")
                .relativeTo(getClass());
    }
}
