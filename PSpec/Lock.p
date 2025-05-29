spec DeadlockDetection observes eForkAcquired, eReleaseFork {
    var totalAcquires: int;
    
    start state Monitoring {
        entry { 
            totalAcquires = 0;
        }
        
        on eForkAcquired do {
            totalAcquires = totalAcquires + 1;

            // Print the current number of fork acquisitions
            print format("Total fork acquisitions: {0}", totalAcquires);
            assert totalAcquires < 5, "Too many fork acquisitions, potential deadlock";
        }

        on eReleaseFork do {
            totalAcquires = totalAcquires - 1;
            // Print the current number of fork acquisitions after release
            print format("Total fork acquisitions after release: {0}", totalAcquires);
        }
    }
}