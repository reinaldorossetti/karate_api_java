package serverest.usuarios;

import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import com.intuit.karate.junit5.Karate;

/**
 * JUnit 5 test class to run User tests
 *
 * Execution examples:
 * - Run all tests: mvn test
 * - Run only this class: mvn test -Dtest=UsuariosTest
 * - Run by tags: mvn test -Dkarate.options="--tags @smoke"
 */
public class UsersTest {

    /**
     * Executes all scenarios from the Users.feature feature
     */
    @Karate.Test
    Karate testUsers() {
        return Karate.run("Users").relativeTo(getClass());
    }

    /**
     * Executes only the tests tagged with @smoke
     */
    @Karate.Test
    Karate testSmoke() {
        return Karate.run("Users")
                .tags("@smoke")
                .relativeTo(getClass());
    }

    /**
     * Executes specific tests by tag
     */
    @Karate.Test
    Karate testValidations() {
        return Karate.run("Users")
                .tags("@error-validation,@regex-validation")
                .relativeTo(getClass());
    }

    /**
     * Executes in parallel with X threads
     * Note: Karate report show wrong execution time when run in parallel, so use with caution for performance metrics
     */
    @Test
    void testParallel() {
        Results results = Runner.path("classpath:serverest/usuarios/Users.feature")
                .tags("~@ignore")
                .parallel(1);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
