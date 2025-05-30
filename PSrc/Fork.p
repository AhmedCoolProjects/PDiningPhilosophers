machine Fork {
    var holder: machine;
    var holder_id: int;
    var id: int;
    

    start state Init {
        entry (input: int) { 
            holder = null;
            holder_id = -1;
            id = input;
            print format("Fork {0} initialized", input);
            goto available;
        }
    }
    
    state available {

        on eAcquireFork do (info: (philo: tPhilo, fork: tFork)) {
            assert info.fork.id == id, format("Fork id mismatch: expected {0}, got {1}", id, info.fork.id);
            holder = info.philo.m;
            holder_id = info.philo.id;
            print format("Philosopher {0} GOT fork {1}", holder_id, id);
            send info.philo.m, eForkAcquired;
            goto taken;
        }

        on eReleaseFork do (info: (philo: tPhilo, fork: tFork)) {
            print format("You CAN NOT release an available fork {0} by philosopher {1}", id, info.philo.id);
        }
    }
    
    state taken {

        on eReleaseFork do (info: (philo: tPhilo, fork: tFork)) {
            assert info.philo.id == holder_id, format("Only holder can release fork");
            holder = null;
            holder_id = -1;
            goto available;
        }

        on eAcquireFork do (info: (philo: tPhilo, fork: tFork)) {
            assert info.fork.id == id, format("Fork id mismatch: expected {0}, got {1}", id, info.fork.id);
            send info.philo.m, eForkBusy, (philo=info.philo, fork=info.fork);
        }
    }
}