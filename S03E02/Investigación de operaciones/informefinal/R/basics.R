for (i in 1:5) {
  print(i)
}

i <- 0
while (i <= 4) {
  i <- i + 1
  print(i)
}

FALSE %in% (get.variables(lprec)-floor(get.variables(lprec))==0)

###
v <- c('a','b','c','e')

'b' %in% v
## returns TRUE

match('b',v)
## returns the first location of 'b', in this case: 2

# Function to check if value is an integer
check.integer <- function(x) {
  x == round(x)
}

#install.packages("lpSolveAPI")
library(lpSolveAPI)

######################
N_CONSTRAINTS = 2
N_DVARS = 2

# Create model
#
?make.lp # How to use

lprec <- make.lp(0, N_DVARS)
lprec

# Set objective function
#
?set.objfn # How to use

set.objfn(lprec, c(5, 8))

# Set objective (min or max)
#
?lp.control
lp.control(lprec, sense="max")
lprec

# Set constraints
#
?add.constraint # How to use

add.constraint(lprec, c(1, 1), "<=", 6)
add.constraint(lprec, c(5, 9), "<=", 45)
lprec

# Set bounds
#
?set.bounds # How to use

set.bounds(lprec, lower = c(0, 0), columns = c(1,2))

# Names
#
ColNames <- c("X1", "X2")
RowNames <- c("Constraint_1", "Constraint_2")
dimnames(lprec) <- list(RowNames, ColNames)
lprec

# Solution
#
solve(lprec)

get.objective(lprec)

get.variables(lprec)
get.variables(lprec)[1]
get.variables(lprec)[2]

get.constraints(lprec)



###############
###############

# Example usage
weights <- c(2, 3, 5, 7, 1)
values <- c(1, 4, 7, 10, 3)
capacity <- 10

result <- branch_and_bound(weights, values, capacity, 0, 0, 1, numeric(0))
print(result)


##############

library(lpSolve)

# Función para verificar si un número es entero
check.integer <- function(x) {
  x == round(x)
}

# Función de Branch and Bound para resolver problemas lineales enteros
branch_and_bound_integer <- function(lprec, integer_vars) {
  # Resolver el problema lineal
  status <- solve(lprec)
  status
  
  # Verificar si la solución es entera
  is_integer_solution <- all(sapply(get.variables(lprec), check.integer))
  
  if (status == 0 && is_integer_solution) {
    # Si la solución es entera, devolver el resultado
    result <- list(objective = get.objective(lprec), variables = get.variables(lprec))
  } else {
    # Si la solución no es entera, seleccionar una variable para ramificar
    branching_var <- which(!sapply(get.variables(lprec), check.integer))[1]
    
    # Ramificar con la parte entera
    lprec_branch1 <- lprec
    set.bounds(lprec_branch1, upper = floor(get.variables(lprec_branch1)[branching_var]), columns = branching_var)
    result_branch1 <- branch_and_bound_integer(lprec_branch1, integer_vars)
    
    # Ramificar con la parte entera + 1
    lprec_branch2 <- lprec
    set.bounds(lprec_branch2, lower = ceiling(get.variables(lprec_branch2)[branching_var]), columns = branching_var)
    result_branch2 <- branch_and_bound_integer(lprec_branch2, integer_vars)
    
    # Comparar y devolver el mejor resultado
    if (result_branch1$objective > result_branch2$objective) {
      return(result_branch1)
    } else {
      return(result_branch2)
    }
  }
}

# Ejemplo de uso
N_CONSTRAINTS <- 2
N_DVARS <- 2

lprec <- make.lp(0, N_DVARS)
set.objfn(lprec, c(5, 8))
lp.control(lprec, sense="max")

add.constraint(lprec, c(1, 1), "<=", 6)
add.constraint(lprec, c(5, 9), "<=", 45)

set.bounds(lprec, lower = c(0, 0), columns = c(1, 2))

integer_vars <- c(TRUE, TRUE)

result <- branch_and_bound_integer(lprec, integer_vars)
print(result)





