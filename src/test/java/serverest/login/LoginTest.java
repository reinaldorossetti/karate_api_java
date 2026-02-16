package serverest.login;

import com.intuit.karate.junit5.Karate;

public class LoginTest {

    @Karate.Test
    Karate testLogin() {
        return Karate.run("Login").relativeTo(getClass());
    }

    @Karate.Test
    Karate testLoginSmoke() {
        return Karate.run("Login")
                .tags("@login")
                .relativeTo(getClass());
    }
}
