import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.Test;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;

class ParallelTest {

    @Test
    void testParallel() {
        Results results = Runner.path("classpath:features")
                .tags("~@ignore", "@regression")
                .parallel(5);  // 5 threads
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
    
    @Test
    void ciOptimized() {
        Results results = Runner.path("classpath:features")
                .tags("@regression", "~@slow")
                .outputJunitXml(true)          // Jenkins/CI integration
                .outputCucumberJson(true)      // Dashboard integration  
                .reportDir("target/ci-reports")
                .parallel(4);                  // Conservative for CI
        
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
}
}