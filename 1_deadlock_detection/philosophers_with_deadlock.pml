#define N 5 /* Number of philosophers */

bool stick[N]; /* State of the stick (free or taken) */

inline take(s) {
    atomic {
        stick[s] == false ->
        stick[s] = true
    }
}

inline release(s) {
    stick[s] = false
}

active [N] proctype Philosopher() {
    byte id = _pid; /* id of the philosopher */
    byte left = id; /* id of the left stick */
    byte right = (id + N - 1) % N; /* id of the right stick */

    do
    ::  
        if
        :: take(left);
           take(right)
        :: take(right);
           take(left)
        fi;

        /* eating */
        skip;

        release(right);
        release(left)
    od
}