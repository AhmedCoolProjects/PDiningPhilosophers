// Event declarations
event eAcquireFork: (philosopher: machine, philo_id: int);
event eReleaseFork: int; // philo id
event eForkAcquired;
event eBothForksAcquired;
event eForkBusy: (fork: machine, philo_id: int, fork_id: int);


machine Philo {
    var left_fork: machine;
    var right_fork: machine;
    var left_fork_id: int;
    var right_fork_id: int;
    var philosopher_id: int;
    var forks_acquired: int;
    var isException: bool;
    
    start state Init {
      
        entry (input: (id: int, left: machine, right: machine, isException: bool, left_id: int, right_id: int)) {
            philosopher_id = input.id;
            // forks
            left_fork = input.left;
            right_fork = input.right;
            left_fork_id = input.left_id;
            right_fork_id = input.right_id;
            // one philosopher may be the exception
            isException = input.isException;
            // how many forks i have
            forks_acquired = 0;

            // Start thinking
            print format("Philosopher {0}: left fork {1} and right fork {2}", philosopher_id, left_fork_id, right_fork_id);
            goto thinking;
        }
    }

    state thinking {
       
        entry {
            // Check if this is the first attempt and should be skipped
            if (isException) {
                print format("Philosopher {0} is the Exception", philosopher_id);
                // acquire the right fork first
                send right_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
            } else {
                send left_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
            }
        }

        on eForkAcquired do {
            // the philosopher got a fork, let's check if he can eat
            forks_acquired = forks_acquired + 1;
            if (forks_acquired == 1) {
                // philosopher still needs another fork, let's try to get the right fork
                if (isException) {
                    print format("Philosopher {0} is GOT his right fork {1}, now trying for left fork {2}", philosopher_id, right_fork_id, left_fork_id);   
                    // Request left fork
                    send left_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
                } else {
                    print format("Philosopher {0} is GOT his left fork {1}, now trying for right fork {2}", philosopher_id, left_fork_id, right_fork_id);
                    // Request right fork
                    send right_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
                }
            } else if (forks_acquired == 2) {
                print format("Philosopher {0} acquired both forks: left {1} and right {2}, starting to eat", 
                             philosopher_id, left_fork_id, right_fork_id);
                goto eating;
            }
        }

        on eForkBusy do (info: (fork: machine, philo_id: int, fork_id: int)) {
            print format("Philosopher {0} could not acquire fork {1} (held by philosopher {2}), retrying...", 
                         philosopher_id, info.fork_id, info.philo_id);
            // let's retry acquiring the left fork if it was the first attempt
            if (isException) {
                if (info.fork_id == right_fork_id) {
                    // then the philosopher is waiting for right fork
                    send right_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
                } else {
                    // otherwise, retry acquiring the left fork
                    send left_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
                }
            } else {
                if (info.fork_id == left_fork_id) {
                    // then the philosopher is waiting for left fork
                    send left_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
                } else {
                    // otherwise, retry acquiring the right fork
                    send right_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
                }
            }
        }
    }

    state eating {
        entry {
            print format("Philosopher {0} is eating with forks: left {1} and right {2}", 
                         philosopher_id, left_fork_id, right_fork_id);
            // Reset forks acquired count
            send left_fork, eReleaseFork, philosopher_id;
            send right_fork, eReleaseFork, philosopher_id;
            forks_acquired = 0;
            print format("Philosopher {0} released forks: left {1} and right {2}, now thinking again", 
                         philosopher_id, left_fork_id, right_fork_id);
            goto thinking;
        }
    }
}