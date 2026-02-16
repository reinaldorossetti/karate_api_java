package serverest.produtos;

import com.intuit.karate.junit5.Karate;

public class ProductsTest {

    @Karate.Test
    Karate testProdutos() {
        return Karate.run("Products").relativeTo(getClass());
    }

    @Karate.Test
    Karate testSmoke() {
        return Karate.run("Products")
                .tags("@products")
                .relativeTo(getClass());
    }
}
