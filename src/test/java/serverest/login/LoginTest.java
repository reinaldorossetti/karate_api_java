package serverest.login;

import com.intuit.karate.junit5.Karate;

public class LoginTest {

    @Karate.Test
    Karate testLogin() {
        return Karate.run("login").relativeTo(getClass());
    }

    @Karate.Test
    Karate testLoginSmoke() {
        return Karate.run("login")
                .tags("@smoke")
                .relativeTo(getClass());
    }
}
