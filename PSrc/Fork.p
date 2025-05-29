machine Fork {
    var holder: machine;
    var holder_id: int;
    var id: int;
    

    start state Init {
        entry (input: (id: int, id_one: int)) { // this id_one has no since, but i use it because idk how to use the input with just one variable, it keeps throwing errors
            holder = null;
            holder_id = -1;
            id = input.id;
            print format("Fork {0} initialized", input.id);
            goto available;
        }
    }
    
    state available {
        entry {
            print format("Fork {0} is available", id);
        }

        on eAcquireFork do (info: (philosopher: machine, philo_id: int)) {
            holder = info.philosopher;
            holder_id = info.philo_id;
            send info.philosopher, eForkAcquired;
            print format("Fork {0} acquired by philosopher {1}", id, holder_id);
            goto taken;
        }

        on eReleaseFork do (philo_id: int) {
            // Fork is available, ignore the release request
            print format("Fork {0} is already available, cannot release by {1}", id, philo_id);

        }
    }
    
    state taken {
       
        on eReleaseFork do (philo_id: int) {
            assert philo_id == holder_id, format("Only holder can release fork");
            print format("Fork {0} released by philosopher {1}", id, philo_id);
            holder = null;
            holder_id = -1;
            goto available;
        }

        on eAcquireFork do (info: (philosopher: machine, philo_id: int)) {
            // Send a delayed retry message to the philosopher
            print format("Fork {0} is busy by philosopher {1}, philosopher {2} cannot acquire it", id, holder_id, info.philo_id);
            send info.philosopher, eForkBusy, (fork = this, philo_id = holder_id, fork_id = id);
        }
    }
}