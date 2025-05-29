machine Main {
    var philosophers: seq[machine];
    var forks: seq[machine];
    var numPhilosophers: int;
    var leftFork: machine;
    var rightFork: machine;
    var withException: bool;
    
    start state Init {
        entry {
            var i: int;
            var j: int;
            numPhilosophers = 5;
            withException = false;

            // Create 5 forks
            j = 0;
            while (j < numPhilosophers) {
                forks += (0, new Fork((id = j, id_one = j)));
                j = j + 1;
            }
            
            // Create 5 philosophers
            i = 0;
            while (i < numPhilosophers) {
                // Left fork is at index i, right fork is at index (i+1) % numPhilosophers
                leftFork = forks[i];
                rightFork = forks[(i + 1) % numPhilosophers];

                if (withException && i == 1) { // the philosopher with id 1 is the exception
                    philosophers += (0, new Philo((id=i, left=leftFork, right=rightFork, isException=true, left_id=i, right_id=(i + 1) % numPhilosophers)));
                } else {
                    philosophers += (0, new Philo((id=i, left=leftFork, right=rightFork, isException=false, left_id=i, right_id=(i + 1) % numPhilosophers)));
                }
                
                i = i + 1;
            }
            
            print "Started";
        }
    }
}

test DefaultImpl [main=Main]: assert DeadlockDetection in (union Main, Philo, Fork);