#define N 5 /* Number of philosophers */

bool stick[N]; /* State of the stick (free or taken) */

/* Philosophers' states */
bool hungry[N];
bool eating[N];

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
        hungry[id] = true;

        if
        :: id == 0 ->
            take(right);
            take(left)
        :: else ->
            take(left);
            take(right)
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