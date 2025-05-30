
machine Philo {
    var id: int;
    var left: tFork;
    var right: tFork;
    // 
    var isException: bool;
    var counterPhiloCreated: int;
    var acquireCounter: int;
    var _philo: tPhilo;

    
    start state Init {

        entry (input: tPhilo) {
            _philo = input;
            _philo.m = this; // Set the machine reference for the philosopher

            id = input.id;
            left = input.left;
            right = input.right;
            isException = input.isException;
            counterPhiloCreated = 0;
            acquireCounter = 0;

            // Start thinking
            print format("Philosopher {0}: left {1} and right {2}", id, left.id, right.id);
            goto thinking;
        }
    }

    state philoReady {
        entry {
            print format("Philosopher {0} is READY", id);
            counterPhiloCreated = counterPhiloCreated + 1;
            send this, ePhiloReady; // Notify that the philosopher is ready

        }

        on ePhiloReady do {
            goto thinking; // Go to thinking state after being ready
        }

        
    }


    state thinking {
       
        entry {
            if (counterPhiloCreated == 0) {
                goto philoReady;
            }

            if (isException) {
                print format("Philosopher {0} is the Exception", id);
                send right.m, eAcquireFork, (philo = _philo, fork = right);
            } else {
                send left.m, eAcquireFork, (philo = _philo, fork = left);
            }
 
        }

        on eForkAcquired do {
            // the philosopher got a fork, let's check if he can eat
            acquireCounter = acquireCounter + 1;
            if (acquireCounter == 1) {
               print format("Philo {0} ASKING for second FORK with counter {1}", id, acquireCounter);
                if (isException) {
                    send left.m, eAcquireFork, (philo = _philo, fork = left);
                } else {
                    send right.m, eAcquireFork, (philo = _philo, fork = right);
                }
            } 
            if (acquireCounter == 2) {
                print format("Philo {0} GOT both FORKS {1} and {2}, ready to eat with counter {3}", id, left.id, right.id, acquireCounter);
                send this, eLetsEat;
            }
        }

        on eLetsEat do {
            goto eating;
        }

        on eForkBusy do (info: (philo: tPhilo, fork: tFork)) {
            print format("Philosopher {0} CAN NOT take {1} (held by philosopher {2}), retrying...", 
                         id, info.fork.id, info.philo.id);
            if (isException) {
                if (info.fork.id == right.id) {
                    // then the philosopher is waiting for right fork
                    send right.m, eAcquireFork, (philo = _philo, fork = right);
                } else {
                    print format("Philosopher {0} oh EXCEPTION, for left fork {1}, retrying...", id, left.id);
                    // otherwise, retry acquiring the left fork
                    send left.m, eAcquireFork, (philo = _philo, fork = left);
                }
            } else {
                if (info.fork.id == left.id) {
                    // then the philosopher is waiting for left fork
                    send left.m, eAcquireFork, (philo = _philo, fork = left);
                } else {
                    // otherwise, retry acquiring the right fork
                    send right.m, eAcquireFork, (philo = _philo, fork = right);
                }
            }
        }
    }

    state eating {
        entry {
            print format("Philosopher {0} is eating with forks: left {1} and right {2}", 
                         id, left.id, right.id);
            // Reset forks acquired count
            send left.m, eReleaseFork, (philo = _philo, fork = left);
            send right.m, eReleaseFork, (philo = _philo, fork = right);
            acquireCounter = 0;
            print format("Philosopher {0} released forks: left {1} and right {2}, now thinking again", 
                         id, left.id, right.id);
            send this, eStopEating;
        }

        on eStopEating do {
            goto thinking; // Go back to thinking state after eating
        }
    }
}