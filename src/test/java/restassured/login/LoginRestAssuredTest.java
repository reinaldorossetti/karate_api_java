package restassured.login;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.nullValue;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.junit.jupiter.api.TestInstance.Lifecycle;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvFileSource;

import io.restassured.http.ContentType;
import io.restassured.response.Response;
import restassured.BaseApiTest;
import serverest.utils.FakerUtils;

@TestInstance(Lifecycle.PER_CLASS)
@Execution(ExecutionMode.CONCURRENT)
public class LoginRestAssuredTest extends BaseApiTest {

    private Response createUser(String email, String password, boolean admin) {
        String payload = String.format("{\n  \"nome\": \"%s\",\n  \"email\": \"%s\",\n  \"password\": \"%s\",\n  \"administrador\": \"%s\"\n}",
                email, email, password, admin ? "true" : "false");

        return givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/usuarios")
                .body(payload)
            .when()
                .post();
    }

    @Test
    @DisplayName("CT01 - Perform login with valid credentials and validate token")
    void ct01_loginWithValidCredentials() {
        String email = FakerUtils.randomEmail();
        String password = "SenhaSegura@123";

        createUser(email, password, false)
            .then()
            .statusCode(201);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/login")
            .body("{\"email\": \"" + email + "\", \"password\": \"" + password + "\"}")
        .when()
            .post()
        .then()
            .statusCode(200)
            .body("message", equalTo("Login realizado com sucesso"))
            .body("authorization", notNullValue());
    }

    @Test
    @DisplayName("CT02 - Attempt login with invalid credentials")
    void ct02_loginWithInvalidCredentials() {
        String body = "{\n  \"email\": \"usuario@inexistente.com\",\n  \"password\": \"senhaerrada\"\n}";

        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/login")
            .body(body)
        .when()
            .post()
        .then()
            .statusCode(401)
            .body("message", equalTo("Email e/ou senha inválidos"))
            .body("authorization", nullValue());
    }

    @Test
    @DisplayName("CT03 - Validate required fields on login")
    void ct03_validateRequiredFields() {
        // 1) Email vazio, senha preenchida
        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/login")
            .body("{\"email\": \"\", \"password\": \"senha123\"}")
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("email", notNullValue());

        // 2) Email preenchido, senha vazia
        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/login")
            .body("{\"email\": \"test@email.com\", \"password\": \"\"}")
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("password", notNullValue());

        // 3) Ambos vazios
        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/login")
            .body("{\"email\": \"\", \"password\": \"\"}")
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("email", notNullValue())
            .body("password", notNullValue());
    }

    @Test
    @DisplayName("CT04 - Login and use token to access a protected resource")
    void ct04_loginAndUseTokenInProtectedRoute() {
        // Cria usuário comum (não administrador)
        String userEmail = FakerUtils.randomEmail();
        String userPassword = "SenhaSegura@123";

        createUser(userEmail, userPassword, false)
            .then()
            .statusCode(201);

        // Faz login com usuário comum
        Response loginResponse =
            givenWithAllure()
                .contentType(ContentType.JSON)
                .basePath("/login")
                .body("{\"email\": \"" + userEmail + "\", \"password\": \"" + userPassword + "\"}")
            .when()
                .post()
            .then()
                .statusCode(200)
                .body("message", equalTo("Login realizado com sucesso"))
                .extract().response();

        String authToken = loginResponse.path("authorization");

        // Tenta acessar rota protegida de criação de produto
        String productName = FakerUtils.randomProduct();
        String productPayload = String.format("{\n  \"nome\": \"%s\",\n  \"preco\": 100,\n  \"descricao\": \"Produto gerado com Faker para teste de autenticacao\",\n  \"quantidade\": 10\n}",
                productName);

        givenWithAllure()
            .contentType(ContentType.JSON)
            .header("Authorization", authToken)
            .basePath("/produtos")
            .body(productPayload)
        .when()
            .post()
        .then()
            .statusCode(403)
            .body("message", equalTo("Rota exclusiva para administradores"));
    }

    @ParameterizedTest(name = "CT05 - Validate invalid email format: {0}")
    @CsvFileSource(resources = "/restassured/login/invalid-login-emails.csv", numLinesToSkip = 1)
    @Execution(ExecutionMode.CONCURRENT)
    @DisplayName("CT05 - Validate invalid email format")
    void ct05_validateInvalidEmailFormat(String invalidEmail) {
        givenWithAllure()
            .contentType(ContentType.JSON)
            .basePath("/login")
            .body("{\"email\": \"" + invalidEmail + "\", \"password\": \"senha123\"}")
        .when()
            .post()
        .then()
            .statusCode(400)
            .body("email", notNullValue())
            .body("email", containsString(""));
    }
}
