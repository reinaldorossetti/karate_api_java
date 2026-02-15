package serverest.produtos;

import com.intuit.karate.junit5.Karate;

public class ProdutosTest {

    @Karate.Test
    Karate testProdutos() {
        return Karate.run("produtos").relativeTo(getClass());
    }

    @Karate.Test
    Karate testSmoke() {
        return Karate.run("produtos")
                .tags("@smoke")
                .relativeTo(getClass());
    }
}
