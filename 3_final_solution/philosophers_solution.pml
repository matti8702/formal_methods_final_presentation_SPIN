#define N 5 /* Number of philosophers */

/* Sticks' states */
bool stick[N]; /* State of the stick (free or taken) */
byte owner[N]; /* 0 = available_i, 1 = available_i+1 */


/* Philosophers' states */
bool hungry[N];
bool eating[N];

/*
   Stick s is between Philosopher s and Philosopher (s+1)%N.

   owner[s] == 0  => Stick s is available only for Philosopher s
   owner[s] == 1  => Stick s is available only for Philosopher (s+1)%N
*/

inline can_take(s, p) {
    (
        stick[s] == false &&
        (
            (owner[s] == 0 && p == s) ||
            (owner[s] == 1 && p == ((s + 1) % N))
        )
    )
}

inline take(s, p) {
    atomic {
        can_take(s, p) ->
        stick[s] = true
    }
}

inline release(s) {
    atomic {
        stick[s] = false;

        if
        :: owner[s] == 0 -> owner[s] = 1
        :: owner[s] == 1 -> owner[s] = 0
        fi
    }
}

proctype Philosopher(byte id) {
    byte left = id; /* id of the left stick */
    byte right = (id + N - 1) % N; /* id of the right stick */

    do
    ::
        hungry[id] = true;

        /*
           The philosopher nondeterministically chooses
           which adjacent stick to take first.
        */
        if
        :: take(left, id);
           take(right, id)
        :: take(right, id);
           take(left, id)
        fi;

        atomic{
            eating[id] = true;
            hungry[id] = false;
        }

        /* eating */
        skip;

        eating[id] = false;
        
        release(right);
        release(left)
    od
}

init {
    atomic {
        /*
           As in the slides:
           - Stick 0, 2, 4 start in available_i;
           - Stick 1, 3 start in available_i+1.
        */
        owner[0] = 0;
        owner[1] = 1;
        owner[2] = 0;
        owner[3] = 1;
        owner[4] = 0;

        run Philosopher(0);
        run Philosopher(1);
        run Philosopher(2);
        run Philosopher(3);
        run Philosopher(4)
    }
}

/* LTL PART */

#define hungry0 (hungry[0])
#define hungry1 (hungry[1])
#define hungry2 (hungry[2])
#define hungry3 (hungry[3])
#define hungry4 (hungry[4])

#define eat0 (eating[0])
#define eat1 (eating[1])
#define eat2 (eating[2])
#define eat3 (eating[3])
#define eat4 (eating[4])

ltl starvation_free_all {
    [] (
        (hungry0 -> <> eat0) &&
        (hungry1 -> <> eat1) &&
        (hungry2 -> <> eat2) &&
        (hungry3 -> <> eat3) &&
        (hungry4 -> <> eat4)
    )
}