package restassured.carrinhos;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.notNullValue;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;

import io.restassured.http.ContentType;
import io.restassured.response.Response;
import restassured.BaseApiTest;
import serverest.utils.FakerUtils;

@TestInstance(Lifecycle.PER_CLASS)
@Execution(ExecutionMode.CONCURRENT)
public class CartsRestAssuredTest extends BaseApiTest {

    private Response loginWithDefaultPayload() {
        // Cria um usuário administrador único para o teste e realiza o login
        String userEmail = FakerUtils.randomEmail();
        String userPassword = "SenhaSegura@123";

        String newUser = "{" +
                "\"nome\":\"Cart Default User\"," +
                "\"email\":\"" + userEmail + "\"," +
                "\"password\":\"" + userPassword + "\"," +
                "\"administrador\":\"true\"" +
                "}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(newUser)
        .when()
            .post()
        .then()
            .statusCode(201);

        String loginPayload = "{" +
                "\"email\":\"" + userEmail + "\"," +
                "\"password\":\"" + userPassword + "\"" +
                "}";

        return givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/login")
            .body(loginPayload)
        .when()
            .post();
    }

    private String createAdminUserAndGetToken() {
        String userEmail = FakerUtils.randomEmail();
        String userPassword = "SenhaSegura@123";

        String newUser = "{"
                + "\"nome\":\"Cart User\"," 
                + "\"email\":\"" + userEmail + "\"," 
                + "\"password\":\"" + userPassword + "\"," 
                + "\"administrador\":\"true\"" 
                + "}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(newUser)
        .when()
            .post()
        .then()
            .statusCode(201);

        String loginPayload = "{"
                + "\"email\":\"" + userEmail + "\"," 
                + "\"password\":\"" + userPassword + "\"" 
                + "}";

        Response loginResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/login")
                .body(loginPayload)
            .when()
                .post()
            .then()
                .statusCode(200)
                .extract().response();

        return loginResponse.path("authorization");
    }

    private String createProduct(String token, int price, int quantity, String description) {
        String productName = FakerUtils.randomProduct();

        String productData = "{"
                + "\"nome\":\"" + productName + "\"," 
                + "\"preco\":" + price + "," 
                + "\"descricao\":\"" + description + "\"," 
                + "\"quantidade\":" + quantity 
                + "}";

        Response productResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .header("Authorization", token)
                .basePath("/produtos")
                .body(productData)
            .when()
                .post()
            .then()
                .statusCode(201)
                .body("message", equalTo("Cadastro realizado com sucesso"))
                .extract().response();

        return productResponse.path("_id");
    }

    @Test
    @DisplayName("CT01 - Full cart lifecycle for authenticated user")
    void ct01_fullCartLifecycleForAuthenticatedUser() {
        String token = createAdminUserAndGetToken();

        givenWithAllure()
            .header("Authorization", token)
            .basePath("/carrinhos/cancelar-compra")
        .when()
            .delete()
        .then()
            .statusCode(200);

        String productId = createProduct(token, 150, 10, "Product created for cart lifecycle test");

        String cartBody = "{\"produtos\":[{\"idProduto\":\"" + productId + "\",\"quantidade\":2}]}";

        Response createCartResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .header("Authorization", token)
                .basePath("/carrinhos")
                .body(cartBody)
            .when()
                .post()
            .then()
                .statusCode(201)
                .body("message", equalTo("Cadastro realizado com sucesso"))
                .body("_id", notNullValue())
                .extract().response();

        String cartId = createCartResponse.path("_id");

        Response getCartResponse =
            givenWithAllure()
                .basePath("/carrinhos/" + cartId)
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        assertThat(getCartResponse.path("produtos.size()"), equalTo(1));
        assertThat(getCartResponse.path("precoTotal"), notNullValue());
        assertThat(getCartResponse.path("quantidadeTotal"), notNullValue());
        assertThat(getCartResponse.path("idUsuario"), notNullValue());
        assertThat(getCartResponse.path("_id"), equalTo(cartId));

        Response concludeResponse =
            givenWithAllure()
                .header("Authorization", token)
                .basePath("/carrinhos/concluir-compra")
            .when()
                .delete()
            .then()
                .statusCode(200)
                .extract().response();

        String message = concludeResponse.path("message");
        assertThat(message, containsString("Registro excluído com sucesso"));
    }

    @Test
    @DisplayName("CT02 - Cancel purchase and return products to stock")
    void ct02_cancelPurchaseAndReturnProductsToStock() {
        Response loginResponse = loginWithDefaultPayload()
            .then()
            .statusCode(200)
            .extract().response();

        String token = loginResponse.path("authorization");

        givenWithAllure()
            .header("Authorization", token)
            .basePath("/carrinhos/cancelar-compra")
        .when()
            .delete()
        .then()
            .statusCode(200);

        String productId = createProduct(token, 200, 5, "Product for cancel purchase test");

        String cartBody = "{\"produtos\":[{\"idProduto\":\"" + productId + "\",\"quantidade\":1}]}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/carrinhos")
            .body(cartBody)
        .when()
            .post()
        .then()
            .statusCode(201);

        Response cancelResponse =
            givenWithAllure()
                .header("Authorization", token)
                .basePath("/carrinhos/cancelar-compra")
            .when()
                .delete()
            .then()
                .statusCode(200)
                .extract().response();

        assertThat(cancelResponse.path("message"), notNullValue());
    }

    @Test
    @DisplayName("CT03 - Prevent creating cart without authentication token")
    void ct03_preventCreatingCartWithoutAuthenticationToken() {
        String cartBody = "{\"produtos\":[{\"idProduto\":\"BeeJh5lz3k6kSIzA\",\"quantidade\":1}]}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/carrinhos")
            .body(cartBody)
        .when()
            .post()
        .then()
            .statusCode(401)
            .body("message", equalTo("Token de acesso ausente, inválido, expirado ou usuário do token não existe mais"));
    }

    @Test
    @DisplayName("CT04 - Prevent creating more than one cart for the same user")
    void ct04_preventCreatingMoreThanOneCartForSameUser() {
        Response loginResponse = loginWithDefaultPayload()
            .then()
            .statusCode(200)
            .extract().response();

        String token = loginResponse.path("authorization");

        givenWithAllure()
            .header("Authorization", token)
            .basePath("/carrinhos/cancelar-compra")
        .when()
            .delete()
        .then()
            .statusCode(200);

        String productId = createProduct(token, 120, 3, "Product for multiple cart test");

        String firstCart = "{\"produtos\":[{\"idProduto\":\"" + productId + "\",\"quantidade\":1}]}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/carrinhos")
            .body(firstCart)
        .when()
            .post()
        .then()
            .statusCode(201);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/carrinhos")
            .body(firstCart)
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("message", containsString("Não é permitido ter mais de 1 carrinho"));
    }

    @Test
    @DisplayName("CT05 - Cart not found by ID")
    void ct05_cartNotFoundById() {
        givenWithAllure()
            .basePath("/carrinhos/invalid-cart-id-123")
        .when()
            .get()
        .then()
            .statusCode(400)
            .body("id", equalTo("id deve ter exatamente 16 caracteres alfanuméricos"));
    }

    @Test
    @DisplayName("CT06 - Prevent cart creation when product stock is insufficient")
    void ct06_preventCartCreationWhenProductStockIsInsufficient() {
        Response loginResponse = loginWithDefaultPayload()
            .then()
            .statusCode(200)
            .extract().response();

        String token = loginResponse.path("authorization");

        givenWithAllure()
            .header("Authorization", token)
            .basePath("/carrinhos/cancelar-compra")
        .when()
            .delete()
        .then()
            .statusCode(200);

        String productId = createProduct(token, 100, 1, "Low stock product for cart test");

        String cartBody = "{\"produtos\":[{\"idProduto\":\"" + productId + "\",\"quantidade\":2}]}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/carrinhos")
            .body(cartBody)
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("message", containsString("Produto não possui quantidade suficiente"));
    }

    @Test
    @DisplayName("CT07 - Prevent cart creation with duplicated products in the same cart")
    void ct07_preventCartCreationWithDuplicatedProductsInSameCart() {
        Response loginResponse = loginWithDefaultPayload()
            .then()
            .statusCode(200)
            .extract().response();

        String token = loginResponse.path("authorization");

        givenWithAllure()
            .header("Authorization", token)
            .basePath("/carrinhos/cancelar-compra")
        .when()
            .delete()
        .then()
            .statusCode(200);

        String productId = createProduct(token, 150, 10, "Product created for duplicated products cart test");

        String duplicatedCartBody = "{\"produtos\":[{\"idProduto\":\"" + productId + "\",\"quantidade\":1},{\"idProduto\":\"" + productId + "\",\"quantidade\":1}]}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/carrinhos")
            .body(duplicatedCartBody)
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("message", containsString("Não é permitido possuir produto duplicado"));
    }

    @Test
    @DisplayName("CT08 - Prevent cart creation with non-existing product")
    void ct08_preventCartCreationWithNonExistingProduct() {
        Response loginResponse = loginWithDefaultPayload()
            .then()
            .statusCode(200)
            .extract().response();

        String token = loginResponse.path("authorization");

        givenWithAllure()
            .header("Authorization", token)
            .basePath("/carrinhos/cancelar-compra")
        .when()
            .delete()
        .then()
            .statusCode(200);

        String invalidCartBody = "{\"produtos\":[{\"idProduto\":\"AAAAAAAAAAAAAAAA\",\"quantidade\":1}]}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/carrinhos")
            .body(invalidCartBody)
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("message", containsString("Produto não encontrado"));
    }
}
