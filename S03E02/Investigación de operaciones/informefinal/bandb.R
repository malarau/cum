library(lpSolveAPI)
N_CONSTRAINTS = 2
N_DVARS = 20

# Create model
lprec <- make.lp(0, N_DVARS)

# Set objective function
set.objfn(lprec, c(190, 70, 160, 80, 110, 180, 50, 120, 140, 60, 130, 200, 100, 150, 90, 170, 120, 200, 110, 140))

# Set objective (min or max)
lp.control(lprec, sense="max")

# Set constraints
add.constraint(lprec, c(5, 2, 4, 1, 3, 6, 3, 5, 2, 3, 4, 6, 2, 3, 1, 4, 2, 5, 5, 3), "<=", 16)
add.constraint(lprec, c(2, 1, 4, 2, 3, 3, 1, 3, 2, 1, 2, 4, 2, 3, 1, 2, 1, 4, 3, 1), "<=", 14)

# Set only binary solutions
set.type(lprec, c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20), "binary")

# Solver
solve(lprec)

# Get solution
get.objective(lprec)
# Get decision variables
get.variables(lprec)