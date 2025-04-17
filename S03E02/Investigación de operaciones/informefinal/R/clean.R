library(lpSolveAPI)

#### Estructura y función

# Estructura para almacenar información de nodos explorados
explored_nodes <- list()

get_constraint <- function(model, ineq, dvars){
  order_decreasing = TRUE
  #
  sorted_dvar = sort(get.variables(model), decreasing = order_decreasing)
  
  integer_checker_vector = sorted_dvar - floor(sorted_dvar)==0
  integer_checker_idx = match(FALSE, integer_checker_vector)
  
  ## Create constraint vector
  actual_pos <- match(sorted_dvar[integer_checker_idx], dvars)
  
  constraint_vector <- rep(0, num_elementos)
  constraint_vector[actual_pos] <- 1
  
  if( ineq == "<=" ){
    nueva_restriccion <- list(coeficientes = constraint_vector, operador = "<=", limite = floor(sorted_dvar[integer_checker_idx]))  
  }else{
    nueva_restriccion <- list(coeficientes = constraint_vector, operador = ">=", limite = floor(sorted_dvar[integer_checker_idx]) + 1)
  }
  
  return(nueva_restriccion)
}

check.integer <- function(x) {
  x == round(x)
}

# Función para agregar información de un nodo a la lista
add_explored_node <- function(lp_model) {
  explored_node <- list(
    resultado = get.objective(lp_model),
    variables_decision = get.variables(lp_model)
  )
  explored_nodes <<- c(explored_nodes, list(explored_node))
}

#### Datos del problema

num_elementos <- 3

valores <- c(10, 8, 15)
pesos <- c(2.2, 1.5, 3.3)
volumenes <- c(3.6, 2.7, 5.4)

# Límites de la mochila
limite_peso <- 12
limite_volumen <- 15

#### Modelo inicial

# Modelo de programación lineal
lp_model <- make.lp(0, ncol = num_elementos)

# Función objetivo (maximizar)
set.objfn(lp_model, valores)

# Especificar la dirección de optimización (maximizar)
lp.control(lp_model, sense = "max")

# Restricciones de peso y volumen
add.constraint(lp_model, pesos, "<=", limite_peso)
add.constraint(lp_model, volumenes, "<=", limite_volumen)

# Establecer tipo
#?set.type
set.type(lp_model, columns = 1:num_elementos, type = "integer")

# Resolver el modelo y almacenar información del nodo
solve(lp_model)

get.objective(lp_model)
get.variables(lp_model)

is_integer_solution <- all(sapply(get.variables(lp_model), check.integer), check.integer(get.objective(lp_model)))
is_integer_solution
if (is_integer_solution == TRUE){ # Yes
  print("La solución es entera")
}

add_explored_node(lp_model)

?list()

constraints_list <- list()

recursive_sol <- function(model, level){
  is_integer_solution <- all(sapply(get.variables(model), check.integer), check.integer(get.objective(model)))
  
  if (is_integer_solution == TRUE){ # Yes
    return ()
  }
  
  # Restricción menor
  nueva_restriccion <- get_constraint(lp_model, "<=", get.variables(lp_model))
}


## Segundo nivel
  ## Restricción menor
nueva_restriccion <- get_constraint(lp_model, "<=", get.variables(lp_model))
nueva_restriccion
add.constraint(lp_model, nueva_restriccion$coeficientes, nueva_restriccion$operador, nueva_restriccion$limite)
  ## Resolver con nueva restricción
solve(lp_model)
get.objective(lp_model)
get.variables(lp_model)

### Tercer nivel
    ### Restricción menor
nueva_restriccion <- get_constraint(lp_model, "<=", get.variables(lp_model))
nueva_restriccion
add.constraint(lp_model, nueva_restriccion$coeficientes, nueva_restriccion$operador, nueva_restriccion$limite)
lp_model
    ### Resolver con nueva restricción
solve(lp_model)
get.objective(lp_model)
get.variables(lp_model)

## Segundo nivel
  ## Restricción mayor
nueva_restriccion <- get_constraint(lp_model, ">=")
add.constraint(lp_model, constraint_vector, ">=", floor(sorted_dvar[integer_checker_idx])+1)
lp_model

