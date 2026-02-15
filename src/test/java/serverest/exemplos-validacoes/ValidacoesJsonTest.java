package serverest.exemplos;

import com.intuit.karate.junit5.Karate;

/**
 * Testes com exemplos práticos de todas as validações JSON possíveis no Karate
 */
public class ValidacoesJsonTest {

    @Karate.Test
    Karate testTodasValidacoes() {
        return Karate.run("validacoes-json").relativeTo(getClass());
    }

    @Karate.Test
    Karate testValidacaoTipos() {
        return Karate.run("validacoes-json")
                .tags("@validacao-tipos")
                .relativeTo(getClass());
    }

    @Karate.Test
    Karate testValidacaoSchema() {
        return Karate.run("validacoes-json")
                .tags("@validacao-schema")
                .relativeTo(getClass());
    }

    @Karate.Test
    Karate testValidacaoRegex() {
        return Karate.run("validacoes-json")
                .tags("@validacao-regex")
                .relativeTo(getClass());
    }
}
