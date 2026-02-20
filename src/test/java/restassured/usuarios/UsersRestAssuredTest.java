package restassured.usuarios;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.everyItem;
import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.greaterThanOrEqualTo;
import static org.hamcrest.Matchers.hasKey;
import static org.hamcrest.Matchers.matchesPattern;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import io.restassured.http.ContentType;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import restassured.BaseApiTest;
import serverest.utils.FakerUtils;

public class UsersRestAssuredTest extends BaseApiTest {

    @Test
    @DisplayName("CT01 - List all users and validate JSON structure")
    void ct01_listAllUsersAndValidateStructure() {
        Response response =
            givenWithAllure()
                .basePath("/usuarios")
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        int quantidade = response.path("quantidade");
        List<Map<String, Object>> usuarios = response.path("usuarios");

        assertThat(quantidade, greaterThan(0));
        assertThat(usuarios.size(), greaterThan(0));

        assertThat(usuarios, everyItem(hasKey("nome")));
        assertThat(usuarios, everyItem(hasKey("email")));
        assertThat(usuarios, everyItem(hasKey("password")));
        assertThat(usuarios, everyItem(hasKey("administrador")));
        assertThat(usuarios, everyItem(hasKey("_id")));

        List<String> emails = usuarios.stream()
            .map(u -> String.valueOf(u.get("email")))
            .collect(Collectors.toList());

        assertThat(emails, everyItem(matchesPattern(".+@.+\\..+")));
    }

    @Test
    @DisplayName("CT02 - Get a specific user by ID")
    void ct02_getUserById() {
        Response listResponse =
            givenWithAllure()
                .basePath("/usuarios")
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        String userId = listResponse.path("usuarios[0]._id");

        givenWithAllure()
            .basePath("/usuarios/" + userId)
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("_id", equalTo(userId))
            .body("nome", notNullValue())
            .body("email", notNullValue());
    }

    @Test
            @DisplayName("CT03 - Create a new user with complete validations")
    void ct03_createUser() {
        String email = FakerUtils.randomEmail();
        String name = FakerUtils.randomName();
        String password = FakerUtils.randomPassword();

        String payload = String.format("{\n  \"nome\": \"%s\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"true\"\n}",
                name, email, password);

        Response createResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/usuarios")
                .body(payload)
            .when()
                .post()
            .then()
                .statusCode(201)
                .body("message", equalTo("Cadastro realizado com sucesso"))
                .body("_id", notNullValue())
                .extract().response();

        String newUserId = createResponse.path("_id");

        givenWithAllure()
            .basePath("/usuarios/" + newUserId)
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("nome", equalTo(name))
            .body("email", equalTo(email));
    }

    @Test
            @DisplayName("CT05 - Validate error messages when creating a duplicate email")
    void ct05_duplicateEmailValidation() {
        String duplicateEmail = FakerUtils.randomEmail();

        String user1 = "{\n  \"nome\": \"User 1\",\n  \"email\": \"" + duplicateEmail + "\",\n  \"password\": \"senha123\",\n  \"administrador\": \"false\"\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(user1)
        .when()
            .post()
        .then()
            .statusCode(201);

        String user2 = "{\n  \"nome\": \"User 2\",\n  \"email\": \"" + duplicateEmail + "\",\n  \"password\": \"anotherpassword\",\n  \"administrador\": \"true\"\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(user2)
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("message", equalTo("Este email já está sendo usado"))
            .body("message", notNullValue());
    }

    @Test
    @DisplayName("CT04 - Advanced JSON validations with filters")
    void ct04_advancedJsonValidationsWithFilters() {
        Response response =
            givenWithAllure()
                .basePath("/usuarios")
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        List<Map<String, Object>> usuarios = response.path("usuarios");

        List<Map<String, Object>> admins = usuarios.stream()
            .filter(u -> "true".equals(String.valueOf(u.get("administrador"))))
            .collect(Collectors.toList());

        assertThat(admins.size(), greaterThan(0));

        List<Map<String, Object>> filteredUsers = response.jsonPath()
            .getList("usuarios.findAll { it.administrador == 'true' }");

        assertThat(filteredUsers.size(), greaterThan(0));

        List<String> emails = usuarios.stream()
            .map(u -> String.valueOf(u.get("email")))
            .collect(Collectors.toList());

        assertThat(emails, everyItem(notNullValue()));
    }

    @Test
    @DisplayName("CT06 - Validate with fuzzy matching")
    void ct06_validateWithFuzzyMatching() {
        Response response =
            givenWithAllure()
                .basePath("/usuarios")
                .param("administrador", "true")
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        int quantidade = response.path("quantidade");
        List<Map<String, Object>> usuarios = response.path("usuarios");

        assertThat(quantidade, greaterThanOrEqualTo(0));

        for (Map<String, Object> user : usuarios) {
            assertThat(user.get("nome"), notNullValue());
            assertThat(user.get("email"), notNullValue());
            assertThat(String.valueOf(user.get("administrador")), equalTo("true"));
        }
    }

    @Test
    @DisplayName("CT07 - Conditional validations based on values")
    void ct07_conditionalValidationsBasedOnValues() {
        Response response =
            givenWithAllure()
                .basePath("/usuarios")
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        Map<String, Object> user = response.path("usuarios[0]");

        String adminFlag = String.valueOf(user.get("administrador"));
        assertTrue("true".equals(adminFlag) || "false".equals(adminFlag));

        String email = String.valueOf(user.get("email"));
        String password = String.valueOf(user.get("password"));

        assertTrue(email != null && email.length() > 5);
        assertTrue(password != null && password.length() > 0);
    }

    @Test
    @DisplayName("CT08 - Validate formats with regular expressions")
    void ct08_validateFormatsWithRegularExpressions() {
        String newEmail = "test.regex." + System.currentTimeMillis() + "@example.com";

        String userData = String.format("{\n  \"nome\": \"%s\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"false\"\n}",
                "Regex Test", newEmail, "StrongPassword@123");

        Response createResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/usuarios")
                .body(userData)
            .when()
                .post()
            .then()
                .statusCode(201)
                .extract().response();

        String userId = createResponse.path("_id");

        givenWithAllure()
            .basePath("/usuarios/" + userId)
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("email", matchesPattern(".+@.+\\..+"))
            .body("nome", matchesPattern("[A-Za-z\\s]+"))
            .body("_id", matchesPattern("[A-Za-z0-9]+"));
    }

    @Test
    @DisplayName("CT09 - Validate absence of fields")
    void ct09_validateAbsenceOfFields() {
        Response response =
            givenWithAllure()
                .basePath("/usuarios")
            .when()
                .get()
            .then()
                .statusCode(200)
                .body("error", nullValue())
                .body("errorMessage", nullValue())
                .extract().response();

        Map<String, Object> user = response.path("usuarios[0]");

        assertThat(user.containsKey("cpf"), equalTo(false));
        assertThat(user.containsKey("phone"), equalTo(false));
    }

    @Test
    @DisplayName("CT10 - Use variables for dynamic validations")
    void ct10_useVariablesForDynamicValidations() throws Exception {
        String expectedEmail = FakerUtils.randomEmail();

        Map<String, Object> userPayload = loadUserPayloadFromResource();
        userPayload.put("email", expectedEmail);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(userPayload)
        .when()
            .post()
        .then()
            .statusCode(201);

        Response searchResponse =
            givenWithAllure()
                .basePath("/usuarios")
                .param("email", expectedEmail)
            .when()
                .get()
            .then()
                .statusCode(200)
                .extract().response();

        List<Map<String, Object>> usuarios = searchResponse.path("usuarios");
        Map<String, Object> user = usuarios.get(0);

        assertThat(String.valueOf(user.get("email")), equalTo(expectedEmail));
        assertThat(user.get("nome"), notNullValue());
    }

    @Test
    @DisplayName("CT11 - Prepare data for nested object validation")
    void ct11_prepareDataForNestedObjectValidation() {
        String complexEmail = FakerUtils.randomEmail();

        String complexData = String.format("{\n  \"nome\": \"%s\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"true\"\n}",
                "Complex User", complexEmail, "senha123");

        Response response =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/usuarios")
                .body(complexData)
            .when()
                .post()
            .then()
                .statusCode(201)
                .extract().response();

        String message = response.path("message");
        String id = response.path("_id");

        assertThat(message, notNullValue());
        assertThat(message, equalTo("Cadastro realizado com sucesso"));
        assertThat(id, notNullValue());
        assertTrue(id.length() > 10);
    }

    @Test
    @DisplayName("CT12 - Create a user from fixed JSON file")
    void ct12_createUserFromFixedJsonFile() throws Exception {
        Map<String, Object> userPayload = loadUserPayloadFromResource();
        userPayload.put("email", FakerUtils.randomEmail());

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(userPayload)
        .when()
            .post()
        .then()
            .statusCode(201)
            .body("message", equalTo("Cadastro realizado com sucesso"))
            .body("_id", notNullValue());
    }

    @Test
    @DisplayName("CT13 - Create and delete user based on JSON payload")
    void ct13_createAndDeleteUserBasedOnJsonPayload() throws Exception {
        String expectedEmail = FakerUtils.randomEmail();
        Map<String, Object> userPayload = loadUserPayloadFromResource();
        userPayload.put("email", expectedEmail);

        Response createResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/usuarios")
                .body(userPayload)
            .when()
                .post()
            .then()
                .statusCode(201)
                .body("message", equalTo("Cadastro realizado com sucesso"))
                .extract().response();

        String userId = createResponse.path("_id");

        givenWithAllure()
            .basePath("/usuarios/" + userId)
        .when()
            .delete()
        .then()
            .statusCode(200)
            .body("message", equalTo("Registro excluído com sucesso"));

        givenWithAllure()
            .basePath("/usuarios")
            .param("email", expectedEmail)
        .when()
            .get()
        .then()
            .statusCode(200)
            .body("quantidade", equalTo(0))
            .body("usuarios.size()", equalTo(0));
    }

    @Test
    @DisplayName("CT14 - Prevent deleting user that has an associated cart")
    void ct14_preventDeletingUserThatHasAssociatedCart() {
        String userEmail = FakerUtils.randomEmail();
        String userPassword = "SenhaSegura@123";

        String userData = String.format("{\n  \"nome\": \"%s\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"true\"\n}",
                "User With Cart", userEmail, userPassword);

        Response createUserResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/usuarios")
                .body(userData)
            .when()
                .post()
            .then()
                .statusCode(201)
                .body("message", equalTo("Cadastro realizado com sucesso"))
                .extract().response();

        String userId = createUserResponse.path("_id");

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

        String productName = "Product for user cart " + System.currentTimeMillis();
        String productData = String.format("{\n  \"nome\": \"%s\",\n  \"preco\": 100,\n  \"descricao\": \"Product associated to user cart\",\n  \"quantidade\": 5\n}",
                productName);

        Response productResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .header("Authorization", userToken)
                .basePath("/produtos")
                .body(productData)
            .when()
                .post()
            .then()
                .statusCode(201)
                .extract().response();

        String productId = productResponse.path("_id");

        String cartBody = String.format("{\n  \"produtos\": [ { \"idProduto\": \"%s\", \"quantidade\": 1 } ]\n}",
                productId);

        givenWithAllure()
            .header("Authorization", userToken)
            .basePath("/carrinhos/cancelar-compra")
        .when()
            .delete()
        .then()
            .statusCode(200);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", userToken)
            .basePath("/carrinhos")
            .body(cartBody)
        .when()
            .post()
        .then()
            .statusCode(201);

        givenWithAllure()
            .basePath("/usuarios/" + userId)
        .when()
            .delete()
        .then()
            .statusCode(400)
            .body("message", equalTo("Não é permitido excluir usuário com carrinho cadastrado"))
            .body("idCarrinho", notNullValue());
    }

    @Test
    @DisplayName("CT15 - Get user by invalid ID should return 400")
    void ct15_getUserByInvalidIdShouldReturn400() {
        givenWithAllure()
            .basePath("/usuarios/3F7K9P2XQ8M1R6TB")
        .when()
            .get()
        .then()
            .statusCode(400)
            .body("message", equalTo("Usuário não encontrado"));
    }

    @Test
    @DisplayName("CT16 - Prevent updating user with duplicate e-mail")
    void ct16_preventUpdatingUserWithDuplicateEmail() {
        String email1 = FakerUtils.randomEmail();
        String email2 = FakerUtils.randomEmail();

        String user1 = String.format("{\n  \"nome\": \"%s\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"false\"\n}",
                "User One", email1, "Senha123@");

        String user2 = String.format("{\n  \"nome\": \"%s\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"true\"\n}",
                "User Two", email2, "Senha456@");

        Response createUser1Response =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/usuarios")
                .body(user1)
            .when()
                .post()
            .then()
                .statusCode(201)
                .extract().response();

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios")
            .body(user2)
        .when()
            .post()
        .then()
            .statusCode(201);

        String userId1 = createUser1Response.path("_id");

        String updatePayload = String.format("{\n  \"nome\": \"%s\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"true\"\n}",
                "User One Updated", email2, "Senha123@");

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/usuarios/" + userId1)
            .body(updatePayload)
        .when()
            .put()
        .then()
            .statusCode(400)
            .body("message", equalTo("Este email já está sendo usado"));
    }

    private Map<String, Object> loadUserPayloadFromResource() throws Exception {
        String resourcePath = "serverest/usuarios/resources/userPayload.json";
        InputStream is = Thread.currentThread().getContextClassLoader().getResourceAsStream(resourcePath);
        if (is == null) {
            throw new IllegalStateException("Resource not found: " + resourcePath);
        }
        String json = new String(is.readAllBytes(), StandardCharsets.UTF_8);
        return JsonPath.from(json).getMap("");
    }
}
