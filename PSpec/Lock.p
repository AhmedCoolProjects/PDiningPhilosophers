spec DeadlockDetection observes eForkAcquired, eReleaseFork, ePhiloReady, eLetsEat {
    var totalAcquires: int;
    var howManyPhilosophers: int;
    var totalAcquiresAfterPhilosophers: int;
    var eatingCounter: int;
    
    start state Monitoring {
        entry { 
            totalAcquires = 0;
            howManyPhilosophers = 0;
            totalAcquiresAfterPhilosophers = 0;
            eatingCounter = 0;
        }

        on eLetsEat do {
            eatingCounter = eatingCounter + 1;
        }

        on eForkAcquired do {
            totalAcquires = totalAcquires + 1;

            if (howManyPhilosophers == 5) {
                totalAcquiresAfterPhilosophers = totalAcquiresAfterPhilosophers + 1;
            }

            // Print the current number of fork acquisitions
            print format("Total fork acquisitions: {0}", totalAcquires);
            // TODO
            if (howManyPhilosophers == 5) {
                 assert totalAcquires - 2 * eatingCounter < 5, "Too many fork acquisitions, potential deadlock";
            }
        }

        on eReleaseFork do {
            totalAcquires = totalAcquires - 1;
            eatingCounter = eatingCounter - 1;
            if (howManyPhilosophers == 5) {
                totalAcquiresAfterPhilosophers = totalAcquiresAfterPhilosophers - 1;
            }
            // Print the current number of fork acquisitions after release
            print format("Total fork acquisitions after release: {0}", totalAcquires);
        }

        on ePhiloReady do {
            howManyPhilosophers = howManyPhilosophers + 1;
            // print format("Philosopher {0} is ready", howManyPhilosophers);
            assert howManyPhilosophers <= 5, "More philosophers than expected, potential deadlock";
        }
    }
}