
# Function to check if value is an integer
check.integer <- function(x) {
  x == round(x)
}

#######################

?sapply()
?all()

branch_and_bound <- function(lprec) {
  # 1.- Solve
  solve(lprec)
  
  # 2.- Check if we have an integer solution
  is_integer_solution <- all(sapply(get.variables(lprec), check.integer), check.integer(get.objective(lprec)))
  if (is_integer_solution == TRUE){ # Yes
    return (lprec)
  }
  
  # 3.- Not an integer solution
  # Check which value is greater/not integer from dvars
  order_decreasing = TRUE
  #
  sorted_dvar = sort(get.variables(lprec), decreasing = order_decreasing)
  integer_checker_vector = sorted_dvar - floor(sorted_dvar)==0
  integer_checker_idx = match(FALSE, integer_checker_vector)
  sorted_dvar[integer_checker_idx]
  
  # Create constraint vector
  constraint_vector <- rep(0, N_DVARS)
  constraint_vector[integer_checker_idx] <- 1
  
  # Add new constraint
  add.constraint(lprec, constraint_vector, "<=", round(sorted_dvar[integer_checker_idx]))
  return (lprec)
}

?assign()

###################### 1


#install.packages("lpSolveAPI")
library(lpSolveAPI)

N_CONSTRAINTS = 2
N_DVARS = 2

# Create model
#?make.lp # How to use

lprec <- make.lp(0, N_DVARS)

# Set objective function
#?set.objfn # How to use

set.objfn(lprec, c(5, 8))

# Set objective (min or max)
#?lp.control
lp.control(lprec, sense="max")

# Set constraints
#?add.constraint # How to use

add.constraint(lprec, c(1, 1), "<=", 6)
add.constraint(lprec, c(5, 9), "<=", 45)

set.type(lprec, 1, "integer")
set.type(lprec, 2, "integer")

# Names
#
#ColNames <- c("X1", "X2")
#RowNames <- c("Constraint_1", "Constraint_2")
#dimnames(lprec) <- list(RowNames, ColNames)

set.branch.mode(lprec, columns = c(1, 2), modes = c("ceiling", "floor"))

solve(lprec)
lprec

get.objective(lprec)
get.variables(lprec)

#################

get.branch.mode(lprec)



status<-solve(lprec)
sols<-list() # create list for more solutions
obj0<-get.objective(lprec) # Find values of best solution (in this case four)
counter <- 0 #construct a counter so you wont get more than 100 solutions

# find more solutions
while(counter < 100) {
  sol <- get.variables(lprec)
  sols <- rbind(sols,sol)
  add.constraint(lprec,2*sol-1,"<=", sum(sol)-1) 
  rc<-solve(lprec)
  if (status!=0) break;
  if (get.objective(lprec)<obj0) break;
  counter <- counter + 1
}
sols












