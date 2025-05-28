// Event declarations
event eAcquireFork: (philosopher: machine, philo_id: int);
event eReleaseFork: int; // philo id
event eForkAcquired;
event eBothForksAcquired;
event eForkBusy: (fork: machine, philo_id: int);


machine Philo {
    var left_fork: machine;
    var right_fork: machine;
    var philosopher_id: int;
    var forks_acquired: int;
    
    start state Init {
      
        entry (input: (id: int, left: machine, right: machine)) {
	            philosopher_id = input.id;
            left_fork = input.left;
            right_fork = input.right;
            forks_acquired = 0;

            // Start thinking
        goto thinking;
        }

        
    }

    state thinking {
       
           entry  {
             print format("Philosopher {0} is thinking", philosopher_id);
            
            // Request left fork first
            send left_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
           
        }

        on eForkAcquired do {
            forks_acquired = forks_acquired + 1;
            if (forks_acquired == 1) {
                print format("Philosopher {0} acquired left fork", philosopher_id);
                // Request right fork
                send right_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
            } else if (forks_acquired == 2) {
                print format("Philosopher {0} acquired both forks", philosopher_id);
                goto eating;
            }
        }

        on eForkBusy do (info: (fork: machine, philo_id: int)) {
            print format("Philosopher {0} fork busy, retrying...", philosopher_id);
            // Retry acquiring the left fork
            send left_fork, eAcquireFork, (philosopher = this, philo_id = philosopher_id);
        }
    }

    state eating {
        entry {
            print format("Philosopher {0} is eating", philosopher_id);
            // Simulate eating time
            // sleep(3000); // Simulate eating for 3 seconds
            // Release both forks
            send left_fork, eReleaseFork, philosopher_id;
            send right_fork, eReleaseFork, philosopher_id;
            print format("Philosopher {0} finished eating", philosopher_id);
            goto thinking;
        }
    }
}