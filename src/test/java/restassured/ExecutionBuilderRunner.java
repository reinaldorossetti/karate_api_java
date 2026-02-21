package restassured;

import org.junit.platform.suite.api.ConfigurationParameter;
import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;
import org.junit.platform.suite.api.SuiteDisplayName;

/**
 * JUnit 5 suite para executar em conjunto (e em paralelo, via Surefire)
 * os testes RestAssured de Login, Usuários, Produtos e Carrinhos.
 *
 * Para executar apenas esse suite:
 *   mvn test -Dtest=restassured.ExecutionBuilderRunner
 */
@Suite
@SuiteDisplayName("Run Projeto Serverest API Tests with RestAssured")
@SelectClasses({
    restassured.login.LoginRestAssuredTest.class,
    restassured.usuarios.UsersRestAssuredTest.class,
    restassured.produtos.ProductsRestAssuredTest.class,
    restassured.carrinhos.CartsRestAssuredTest.class
})

@ConfigurationParameter(key = "junit.jupiter.execution.parallel.config.strategy", value = "fixed")
@ConfigurationParameter(key = "junit.jupiter.execution.parallel.config.fixed.parallelism", value = "4")
public class ExecutionBuilderRunner {
}
