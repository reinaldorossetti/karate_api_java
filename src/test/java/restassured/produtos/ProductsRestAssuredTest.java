package restassured.produtos;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.everyItem;
import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.hasKey;
import static org.hamcrest.Matchers.lessThan;
import static org.hamcrest.Matchers.notNullValue;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import io.restassured.http.ContentType;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import restassured.BaseApiTest;

public class ProductsRestAssuredTest extends BaseApiTest {

    private String getAdminToken() {
        String email = "admin." + System.currentTimeMillis() + "@example.com";
        String password = "SenhaSegura@123";

        String userPayload = String.format("{\n  \"nome\": \"Admin User\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"true\"\n}",
                email, password);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(userPayload)
        .when()
            .post()
        .then()
            .statusCode(201);

        Response loginResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/login")
                .body("{\"email\": \"" + email + "\", \"password\": \"" + password + "\"}")
            .when()
                .post()
            .then()
                .statusCode(200)
                .extract().response();

        return loginResponse.path("authorization");
    }

    @Test
    @DisplayName("CT01 - List all products and validate JSON structure")
    void ct01_listProducts() {
        givenWithAllure()
            .basePath("/produtos")
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("quantidade", greaterThanOrEqualTo(0))
            .body("produtos", notNullValue())
            .body("produtos", everyItem(hasKey("nome")))
            .body("produtos", everyItem(hasKey("preco")))
            .body("produtos", everyItem(hasKey("descricao")))
            .body("produtos", everyItem(hasKey("quantidade")))
            .body("produtos", everyItem(hasKey("_id")));
    }

    @Test
    @DisplayName("CT02 - Create a new product as an administrator")
    void ct02_createProductAsAdmin() {
        String token = getAdminToken();
        String productName = "Product " + System.currentTimeMillis();

        String productPayload = String.format("{\n  \"nome\": \"%s\",\n  \"preco\": 250,\n  \"descricao\": \"Automated test product\",\n  \"quantidade\": 100\n}",
                productName);

        Response createResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .header("Authorization", token)
                .basePath("/produtos")
                .body(productPayload)
            .when()
                .post()
            .then()
                .statusCode(201)
                .body("message", equalTo("Cadastro realizado com sucesso"))
                .body("_id", notNullValue())
                .extract().response();

        String productId = createResponse.path("_id");

        givenWithAllure()
            .basePath("/produtos/" + productId)
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("nome", equalTo(productName))
            .body("preco", equalTo(250))
            .body("quantidade", equalTo(100));
    }

    @Test
    @DisplayName("CT03 - Validate error when creating a product with a duplicate name")
    void ct03_duplicateProductName() {
        String token = getAdminToken();
        String name = "Duplicate Product Test " + System.currentTimeMillis();

        String productPayload = String.format("{\n  \"nome\": \"%s\",\n  \"preco\": 150,\n  \"descricao\": \"First product\",\n  \"quantidade\": 50\n}",
                name);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/produtos")
            .body(productPayload)
        .when()
            .post()
        .then()
            .statusCode(201);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/produtos")
            .body(productPayload)
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("message", equalTo("Já existe produto com esse nome"));
    }

    @Test
    @DisplayName("CT04 - Search for products using query parameters")
    void ct04_searchForProductsWithFilters() {
        Response response =
            givenWithAllure()
                .basePath("/produtos")
                .param("nome", "Logitech")
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        List<String> names = response.path("produtos.nome");
        if (names != null && !names.isEmpty()) {
            assertThat(names, everyItem(containsString("Logitech")));
        }

        givenWithAllure()
            .basePath("/produtos")
            .param("preco", 100)
        .when()
            .get()
        .then()
            .statusCode(200);
    }

    @Test
    @DisplayName("CT05 - Update information of an existing product")
    void ct05_updateExistingProduct() {
        String token = getAdminToken();
        String productName = "Product " + System.currentTimeMillis();

        String initialProduct = String.format("{\n  \"nome\": \"%s\",\n  \"preco\": 100,\n  \"descricao\": \"Original description\",\n  \"quantidade\": 50\n}",
                productName);

        Response createResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .header("Authorization", token)
                .basePath("/produtos")
                .body(initialProduct)
            .when()
                .post()
            .then()
                .statusCode(201)
                .extract().response();

        String productId = createResponse.path("_id");

        String updatedProduct = String.format("{\n  \"nome\": \"%s\",\n  \"preco\": 200,\n  \"descricao\": \"Updated description\",\n  \"quantidade\": 75\n}",
                productName);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/produtos/" + productId)
            .body(updatedProduct)
        .when()
            .put()
        .then()
            .statusCode(200)
            .body("message", equalTo("Registro alterado com sucesso"));

        givenWithAllure()
            .basePath("/produtos/" + productId)
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("preco", equalTo(200))
            .body("descricao", equalTo("Updated description"))
            .body("quantidade", equalTo(75));
    }

    @Test
    @DisplayName("CT06 - Validate price calculations and comparisons")
    void ct06_validatePriceCalculationsAndComparisons() {
        Response response =
            givenWithAllure()
                .basePath("/produtos")
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        List<Integer> prices = response.path("produtos.preco");
        if (prices == null || prices.isEmpty()) {
            return;
        }

        int maxPrice = Collections.max(prices);
        int minPrice = Collections.min(prices);
        double avgPrice = prices.stream().mapToInt(Integer::intValue).average().orElse(0);

        System.out.println("Highest Price: " + maxPrice);
        System.out.println("Lowest Price: " + minPrice);
        System.out.println("Average Price: " + avgPrice);

        for (Integer price : prices) {
            assertThat(price, greaterThan(0));
            assertThat(price, lessThan(100000));
        }
    }

    @Test
    @DisplayName("CT07 - Attempt to create a product without an authentication token")
    void ct07_createProductWithoutToken() {
        String productPayload = "{\n  \"nome\": \"Product Without Auth\",\n  \"preco\": 100,\n  \"descricao\": \"Test\",\n  \"quantidade\": 10\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/produtos")
            .body(productPayload)
        .when()
            .post()
        .then()
            .statusCode(401)
            .body("message", equalTo("Token de acesso ausente, inválido, expirado ou usuário do token não existe mais"));
    }

    @Test
    @DisplayName("CT08 - Validate required fields when creating a product")
    void ct08_validateRequiredFieldsWhenCreatingProduct() {
        String token = getAdminToken();

        // Empty name
        String payloadEmptyName = "{\n  \"nome\": \"\",\n  \"preco\": 100,\n  \"descricao\": \"Desc\",\n  \"quantidade\": 10\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/produtos")
            .body(payloadEmptyName)
        .when()
            .post()
        .then()
            .statusCode(400);

        // Negative price
        String payloadNegativePrice = "{\n  \"nome\": \"Product Test\",\n  \"preco\": -10,\n  \"descricao\": \"Desc\",\n  \"quantidade\": 10\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/produtos")
            .body(payloadNegativePrice)
        .when()
            .post()
        .then()
            .statusCode(400);

        // Empty description
        String payloadEmptyDescription = "{\n  \"nome\": \"Product Test\",\n  \"preco\": 100,\n  \"descricao\": \"\",\n  \"quantidade\": 10\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/produtos")
            .body(payloadEmptyDescription)
        .when()
            .post()
        .then()
            .statusCode(400);

        // Negative quantity
        String payloadNegativeQuantity = "{\n  \"nome\": \"Product Test\",\n  \"preco\": 100,\n  \"descricao\": \"Desc\",\n  \"quantidade\": -5\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/produtos")
            .body(payloadNegativeQuantity)
        .when()
            .post()
        .then()
            .statusCode(400);
    }

    @Test
    @DisplayName("CT09 - Work with complex JSON data")
    void ct09_workWithComplexJsonData() {
        Response response =
            givenWithAllure()
                .basePath("/produtos")
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        List<Map<String, Object>> products = response.path("produtos");
        if (products == null) {
            return;
        }

        List<Map<String, Object>> cheapProducts = products.stream()
            .filter(p -> ((Number) p.get("preco")).doubleValue() < 100)
            .toList();
        List<Map<String, Object>> mediumProducts = products.stream()
            .filter(p -> {
                double price = ((Number) p.get("preco")).doubleValue();
                return price >= 100 && price < 500;
            })
            .toList();
        List<Map<String, Object>> expensiveProducts = products.stream()
            .filter(p -> ((Number) p.get("preco")).doubleValue() >= 500)
            .toList();

        System.out.println("Cheap Products: " + cheapProducts.size());
        System.out.println("Medium Products: " + mediumProducts.size());
        System.out.println("Expensive Products: " + expensiveProducts.size());

        assertThat(cheapProducts, notNullValue());
        assertThat(mediumProducts, notNullValue());
        assertThat(expensiveProducts, notNullValue());
    }

    @Test
    @DisplayName("CT10 - Delete an existing product")
    void ct10_deleteExistingProduct() {
        String token = getAdminToken();
        String productName = "Product " + System.currentTimeMillis();

        String productPayload = String.format("{\n  \"nome\": \"%s\",\n  \"preco\": 100,\n  \"descricao\": \"Product to delete\",\n  \"quantidade\": 10\n}",
                productName);

        Response createResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .header("Authorization", token)
                .basePath("/produtos")
                .body(productPayload)
            .when()
                .post()
            .then()
                .statusCode(201)
                .extract().response();

        String productId = createResponse.path("_id");

        givenWithAllure()
            .header("Authorization", token)
            .basePath("/produtos/" + productId)
        .when()
            .delete()
        .then()
            .statusCode(200)
            .body("message", equalTo("Registro excluído com sucesso"));

        givenWithAllure()
            .basePath("/produtos/" + productId)
        .when()
            .get()
        .then()
            .statusCode(400)
            .body("message", equalTo("Produto não encontrado"));
    }

    @Test
    @DisplayName("CT11 - Create a product from fixed JSON payload")
    void ct11_createProductFromFixedJsonPayload() throws Exception {
        String token = getAdminToken();

        InputStream is = getClass().getClassLoader()
            .getResourceAsStream("serverest/produtos/resources/productPayload.json");
        if (is == null) {
            throw new IllegalStateException("productPayload.json not found in classpath");
        }
        String json = new String(is.readAllBytes(), StandardCharsets.UTF_8);

        Map<String, Object> productPayload = JsonPath.from(json).getMap("");
        productPayload.put("nome", "Product " + System.currentTimeMillis());

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", token)
            .basePath("/produtos")
            .body(productPayload)
        .when()
            .post()
        .then()
            .statusCode(201)
            .body("message", equalTo("Cadastro realizado com sucesso"))
            .body("_id", notNullValue());
    }

    @Test
    @DisplayName("CT12 - Prevent deleting a product that is part of a cart")
    void ct12_preventDeletingProductInCart() {
        String adminToken = getAdminToken();

        // Create product
        String productName = "Product " + System.currentTimeMillis();
        String productPayload = String.format("{\n  \"nome\": \"%s\",\n  \"preco\": 300,\n  \"descricao\": \"Product linked to cart\",\n  \"quantidade\": 10\n}",
                productName);

        Response createProductResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .header("Authorization", adminToken)
                .basePath("/produtos")
                .body(productPayload)
            .when()
                .post()
            .then()
                .statusCode(201)
                .extract().response();

        String productId = createProductResponse.path("_id");

        // Create non-admin user and login
        String userEmail = "cart.user." + System.currentTimeMillis() + "@example.com";
        String userPassword = "SenhaSegura@123";

        String userData = String.format("{\n  \"nome\": \"Cart User\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"false\"\n}",
                userEmail, userPassword);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(userData)
        .when()
            .post()
        .then()
            .statusCode(201);

        String loginPayload = String.format("{\n  \"email\": \"%s\",\n  \"password\": \"%s\"\n}",
                userEmail, userPassword);

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

        String userToken = loginResponse.path("authorization");

        // Ensure no existing cart
        givenWithAllure()
            .header("Authorization", userToken)
            .basePath("/carrinhos/cancelar-compra")
        .when()
            .delete()
        .then()
            .statusCode(200);

        // Create cart
        String cartBody = String.format("{\n  \"produtos\": [\n    {\n      \"idProduto\": \"%s\",\n      \"quantidade\": 1\n    }\n  ]\n}",
                productId);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", userToken)
            .basePath("/carrinhos")
            .body(cartBody)
        .when()
            .post()
        .then()
            .statusCode(201);

        // Try to delete product that is in a cart
        givenWithAllure()
            .header("Authorization", adminToken)
            .basePath("/produtos/" + productId)
        .when()
            .delete()
        .then()
            .statusCode(400)
            .body("message", equalTo("Não é permitido excluir produto que faz parte de carrinho"));
    }

    @Test
    @DisplayName("CT13 - Restrict product creation to administrators only")
    void ct13_restrictProductCreationToAdmins() {
        // Create non-admin user
        String userEmail = "non.admin." + System.currentTimeMillis() + "@example.com";
        String userPassword = "SenhaSegura@123";

        String userData = String.format("{\n  \"nome\": \"Non Admin User\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"false\"\n}",
                userEmail, userPassword);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(userData)
        .when()
            .post()
        .then()
            .statusCode(201);

        // Login as non-admin
        String loginPayload = String.format("{\n  \"email\": \"%s\",\n  \"password\": \"%s\"\n}",
                userEmail, userPassword);

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

        String nonAdminToken = loginResponse.path("authorization");

        // Try to create product with non-admin token
        String productData = "{\n  \"nome\": \"Restricted Product\",\n  \"preco\": 500,\n  \"descricao\": \"Product should be created only by admins\",\n  \"quantidade\": 5\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", nonAdminToken)
            .basePath("/produtos")
            .body(productData)
        .when()
            .post()
        .then()
            .statusCode(403)
            .body("message", equalTo("Rota exclusiva para administradores"));
    }
}