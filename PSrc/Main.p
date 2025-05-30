
// type
type tFork = (id: int, m: machine);
type tPhilo = (id: int, left: tFork, right: tFork, isException: bool, m: machine);


// Event declarations
event eAcquireFork: (philo: tPhilo, fork: tFork);
event eForkBusy: (philo: tPhilo, fork: tFork);
// 
event eReleaseFork: (philo: tPhilo, fork: tFork);
event eForkAcquired;
event eBothForksAcquired;
event ePhiloReady;
event eLetsEat;
    

machine Main {
    var philosophers: seq[machine];
    var forks: map[int, tFork];
    var _forkM: machine;
    var _fork: tFork;
    var numPhilosophers: int;
    var left: tFork;
    var right: tFork;
    var withException: bool;


    start state Init {
        entry {
            var i: int;
            numPhilosophers = 5;
            withException = false;

            // Create 5 forks
            i = 0;
            while (i < numPhilosophers) {
                _forkM = new Fork(i);
                _fork = (id=i, m=_forkM);

                forks += (i, _fork);
                i = i + 1;
            }

            i = 0;
            
            // Create 5 philosophers
            i = 0;
            while (i < numPhilosophers) {
                // Left fork is at index i, right fork is at index (i+1) % numPhilosophers
                left = forks[i]; // philo i will take left i
                right = forks[(i + 1) % numPhilosophers];

                if (withException && i == 1) { // the philosopher with id 1 is the exception
                    philosophers += (0, new Philo((id=i, left=left, right=right, isException=true, m = null)));
                } else {
                    philosophers += (0, new Philo((id=i, left=left, right=right, isException=false, m = null)));
                }
                
                i = i + 1;
            }
            
            print "Started";
        }
    }
}

test DefaultImpl [main=Main]: assert DeadlockDetection in (union Main, Philo, Fork);