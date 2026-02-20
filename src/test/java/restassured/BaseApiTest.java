package restassured;

import org.junit.jupiter.api.BeforeAll;

import io.qameta.allure.restassured.AllureRestAssured;
import io.restassured.RestAssured;
import io.restassured.specification.RequestSpecification;

public abstract class BaseApiTest {

    protected RequestSpecification givenWithAllure() {
        return RestAssured.given().filter(new AllureRestAssured());
    }

    @BeforeAll
    static void setupRestAssured() {
        RestAssured.baseURI = "https://serverest.dev";
    }
}
