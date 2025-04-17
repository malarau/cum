########################### FUNCIONES

# Function to check if value is an integer
check.integer <- function(x) {
  tol = 1e-10
  abs(x - round(x)) < tol
}

add_explored_node <- function(lp_model, current_level, r) {
  explored_node <- list(
    resultado = get.objective(lp_model),
    variables_decision = get.variables(lp_model),
    nivel_padre = current_level,
    padre_viende_desde = r
  )
  explored_nodes <<- c(explored_nodes, list(explored_node))
}

get_constraint <- function(model, ineq, dvars, num_elementos){
  order_decreasing = TRUE
  #
  sorted_dvar = sort(dvars, decreasing = order_decreasing)
  
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

create_lp_model <- function() {
  # Modelo de programación lineal
  lp_model <- make.lp(0, ncol = num_elementos)
  
  # Función objetivo (maximizar)
  set.objfn(lp_model, valores)
  
  # Especificar la dirección de optimización (maximizar)
  lp.control(lp_model, sense = "max")
  
  # Restricciones de peso y volumen
  add.constraint(lp_model, pesos, "<=", limite_peso)
  add.constraint(lp_model, volumenes, "<=", limite_volumen)
  
  return(lp_model)
}

########################### DEFINICIONES 

# Uso de la función para crear el modelo
num_elementos <- 3
valores <- c(10, 8, 15)
pesos <- c(2.2, 1.5, 3.3)
volumenes <- c(3.6, 2.7, 5.4)
limite_peso <- 12
limite_volumen <- 15

#lp_model <- create_lp_model()

constraints_list <- list()
explored_nodes <- list()

mejor_solucion_entera <- 0
mejores_dvar_enteros <- NULL

#########################

recursive_sol(1, constraints_list, "root")

explored_nodes
mejor_solucion_entera
mejores_dvar_enteros

recursive_sol <- function(level, constraints_list, branch){
  ########## Restricción menor
  print("")
  print(c("Nivel: ", level))
  
  # Obtener nuevo modelo
  lp_model <- create_lp_model()
  
  # Agregar actuales restricciones
  for (rst in constraints_list) {
    add.constraint(lp_model, rst$coeficientes, rst$operador, rst$limite)
  }
  
  # Resolver
  solve(lp_model)
  
  # Nueva restriccion
  nueva_restriccion <- get_constraint(lp_model, "<=", get.variables(lp_model), num_elementos)
  
  # Verificar si es nula
  if( all(nueva_restriccion$coeficientes == 0) ){
    print("son 0s")
    return (NULL)
  }
  # Agregar al modelo
  add.constraint(lp_model, nueva_restriccion$coeficientes, nueva_restriccion$operador, nueva_restriccion$limite)

  # Agregar a la lista
  constraints_list[level] <- list(nueva_restriccion)
  print(c("Restricciones actuales: ", length(constraints_list)))
  
  # Imprimir restricciones
  for (rst in constraints_list) {
    print(c("Valores: ", rst$coeficientes, rst$operador, rst$limite))
  }
  
  # Solucionar con tal restriccion
  solve(lp_model)
  
  # Revisar si es factible
  if (get.objective(lp_model) == -1e+30 || get.objective(lp_model) == 1e+30) {
    cat("El problema no tiene solución factible.\n")
    return (NULL)
  }else{
    # Guardar datos
    add_explored_node(lp_model, level, branch)
  }
  
  # Revisar si tiene solución o ramificar
  print(c("Solucion: ", get.objective(lp_model), check.integer(get.objective(lp_model))))
  print(c("Dvars: ", get.variables(lp_model), sapply(get.variables(lp_model), check.integer)))
  is_integer_solution <- all(sapply(get.variables(lp_model), check.integer), check.integer(get.objective(lp_model)))
  
  print(is_integer_solution)
  if (is_integer_solution == TRUE){ # Yes
    print("Es una solución entera!")
    
    # Actualizar mejor solución
    if (get.objective(lp_model) > mejor_solucion_entera){
      print(c(get.objective(lp_model), " es mejor solución quue la actual: ", mejor_solucion_entera))
      mejor_solucion_entera <<- get.objective(lp_model)
      mejores_dvar_enteros <<- get.variables(lp_model)
    }else{
      print(c(get.objective(lp_model), " NO es mejor solución quue la actual: ", mejor_solucion_entera))
    }
    return (NULL)
  }else{
    # No es entera y no es mejor que la mejor guardada
    if (get.objective(lp_model) < mejor_solucion_entera){
      return (NULL)
    }
    # Ramificar +1 level
    print("No es una solución entera, pero puede mejorar, ramificar.")
    recursive_sol(level+1, constraints_list, "left")
  }
  
  # Retirar restriccion
  constraints_list[level] <- NULL
  
  ########## Restricción mayor
  print("")
  print(c("Nivel: ", level))
  # Obtener nuevo modelo
  lp_model <- create_lp_model()
  
  # Agregar actuales restricciones
  for (rst in constraints_list) {
    add.constraint(lp_model, rst$coeficientes, rst$operador, rst$limite)
  }
  
  # Resolver
  solve(lp_model)
  
  # Nueva restriccion
  nueva_restriccion <- get_constraint(lp_model, ">=", get.variables(lp_model), num_elementos)
  
  # Verificar si es nula
  if( all(nueva_restriccion$coeficientes == 0) ){
    print("son 0s")
    return (NULL)
  }
  # Agregar al modelo
  add.constraint(lp_model, nueva_restriccion$coeficientes, nueva_restriccion$operador, nueva_restriccion$limite)
  
  # Agregar a la lista
  constraints_list[level] <- list(nueva_restriccion)
  print(c("Restricciones actuales: ", length(constraints_list)))
  
  # Imprimir restricciones
  for (rst in constraints_list) {
    print(c("Valores: ", rst$coeficientes, rst$operador, rst$limite))
  }

  # Solucionar con tal restriccion
  solve(lp_model)
  
  # Revisar si es factible
  if (get.objective(lp_model) == -1e+30 || get.objective(lp_model) == 1e+30) {
    cat("El problema no tiene solución factible.\n")
    return (NULL)
  }else{
    # Guardar datos
    add_explored_node(lp_model, level, branch)
  }
  
  # Revisar si tiene solución o ramificar
  print(c("Solucion: ", get.objective(lp_model)))
  print(c("Dvars: ", get.variables(lp_model)))
  is_integer_solution <- all(sapply(get.variables(lp_model), check.integer), check.integer(get.objective(lp_model)))
  if (is_integer_solution == TRUE){ # Yes
    print("Es una solución entera!")
    
    # Actualizar mejor solución
    if (get.objective(lp_model) > mejor_solucion_entera){
      print(c(get.objective(lp_model), " es mejor solución quue la actual: ", mejor_solucion_entera))
      mejor_solucion_entera <<- get.objective(lp_model)
      mejores_dvar_enteros <<- get.variables(lp_model)
    }
    return (NULL)
  }else{
    if (get.objective(lp_model) < mejor_solucion_entera){
      return (NULL)
    }
    # Ramificar +1 level
    print("No es una solución entera, pero puede mejorar, ramificar(r).")
    recursive_sol(level+1, constraints_list, "right")
  }
}













