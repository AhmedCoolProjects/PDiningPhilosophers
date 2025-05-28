

spec DeadlockDetection observes eAcquireFork, eReleaseFork {
    var lastActivity: int; // Simple counter to track activity
    var requestsSinceLastRelease: int;
    
    start state Monitoring {
        entry { 
            lastActivity = 0;
            requestsSinceLastRelease = 0;
        }
        
        on eAcquireFork do {
            requestsSinceLastRelease = requestsSinceLastRelease + 1;

            // assert false, "FALSE LLLLLL";
            
            // If we have too many requests without any releases, potential deadlock
            print format("Activity detected: {0} requests since last release", requestsSinceLastRelease);
            assert requestsSinceLastRelease <= 10, "Hard deadlock: too many fork requests without releases";

        }
        
        on eReleaseFork do {
            // Reset counter when someone releases a fork (progress made)
            requestsSinceLastRelease = 0;
            lastActivity = lastActivity + 1;
        }
    }
}