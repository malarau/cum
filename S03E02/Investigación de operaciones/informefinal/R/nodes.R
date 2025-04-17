########################### FUNCIONES

# Function to check if value is an integer
check.integer <- function(x) {
  x == round(x)
}

create_lp_model <- function() {
  # Crear el objeto lprec
  lprec <- make.lp(0, N_DVARS)
  
  # Establecer la función objetivo
  set.objfn(lprec, obj_coefficients)
  
  # Establecer el sentido de la optimización (min o max)
  lp.control(lprec, sense = obj_sense)
  
  # Establecer restricciones
  for (i in 1:N_CONSTRAINTS) {
    add.constraint(lprec, constraint_coefficients[i, ], "<=", constraint_limits[i])
  }
  
  # Establecer nombres
  col_names <- paste0("X", 1:N_DVARS)
  row_names <- paste0("Constraint_", 1:N_CONSTRAINTS)
  dimnames(lprec) <- list(row_names, col_names)
  
  # Devolver el objeto lprec creado
  return(lprec)
}

########################### ESTRUCTURAS

restricciones <- list()
nodo_mejor_solucion <- NULL

get_nuevo_nodo <- function(){
  nodo <- list(
    modelo = NULL,
    solucion = NULL,
    dvars = NULL,
    
    restriccion = NULL,
    
    nodo_padre = NULL,
    nodo_menor = NULL,
    nodo_mayor = NULL
  )
  return (nodo)
}

nodo_restriccion <- list(
  coeficiente_restriccion = NULL,
  tipo_desigualdad = NULL,
  limite_desigualdad = NULL
)

########################### DEFINICIONES 

# Definir parámetros globales
N_CONSTRAINTS <- 2  # Número de restricciones
N_DVARS <- 2  # Número de variables de decisión
obj_coefficients <- c(5, 8)  # Coeficientes para la función objetivo
obj_sense = "max"
constraint_coefficients <- matrix(c(1, 1, 5, 9), ncol = N_DVARS, byrow = TRUE)  # Coeficientes para las restricciones
constraint_limits <- c(6, 45)  # Límites para las restricciones


########################## 
lista_de_nodos <- list()

lprec <- create_lp_model()

# Primera iteracón
nuevo_nodo <- get_nuevo_nodo()

list_rest <- list()

add_res <- function(n){
  appen(list_rest, c(lprec, xt = c(0, 1), type = ">=", rhs = 4))
}
nuevo_nodo$restriccion

nuevo_nodo$modelo = lprec

nuevo_nodo <- solucion_recursiva(nuevo_nodo)

?append()
print("-")
nuevo_nodo

solucion_recursiva <- function(nodo_actual) {
  # Obtener restricciones anteriores
  tmp_restricciones <- list()
  
  tmp_nodo <- nodo_actual$nodo_padre
  while ( is.null(tmp_nodo) == FALSE ) {
    print("  Agregando restriccion")
    print(tmp_nodo$restriccion)
    append(tmp_restricciones, list(tmp_nodo$restriccion))
    tmp_nodo <- tmp_nodo$nodo_padre
  }
  
  # Agregar restriccion de nodo
  if( is.null(nodo_actual$restriccion) == FALSE ){
    append(tmp_restricciones, list(nodo_actual$restriccion))
  }
  
  # Agregar restricciones al modelo
  print("Cantidad de restricciones acumuladas: ")
  tmp_restricciones
  for (rst in tmp_restricciones) {
    print(" Aplicando restriccion: ")
    print(rst)
    add.constraint(nodo_actual$modelo, rst)
  }
  
  # Resolver modelo del actual nodo
  solve(nodo_actual$modelo)
  
  nodo_actual$solucion <- get.objective(nodo_actual$modelo)
  print(nodo_actual$solucion)
  
  nodo_actual$dvars <- get.variables(nodo_actual$modelo)
  print(nodo_actual$dvars)
  
  # Consultar si tenemos solución entera
  is_integer_solution <- all(sapply(get.variables(lprec), check.integer), check.integer(get.objective(lprec)))
  if (is_integer_solution == TRUE){ # Yes
    nodo_mejor_solucion <- nodo_actual
    return (nodo_actual)
  } else{ # No
    print("No es solucion entera")
    # Nuevas restricciones (mayor-menor)
    order_decreasing = TRUE
    #
    sorted_dvar = sort(get.variables(lprec), decreasing = order_decreasing)
    integer_checker_vector = sorted_dvar - floor(sorted_dvar)==0
    integer_checker_idx = match(FALSE, integer_checker_vector)
    # A qué variable se aplicará
    constraint_vector <- rep(0, N_DVARS)
    constraint_vector[integer_checker_idx] <- 1
    
    ####  Rama menor igual
    nodo_menor <- get_nuevo_nodo()
    nodo_menor$nodo_padre <- nodo_actual
    nodo_menor$modelo <- create_lp_model()
      # Agregar restriccion menor igual
    nodo_menor$restriccion <- c(nodo_menor$modelo, xt = constraint_vector, type = "<=", rhs = floor(sorted_dvar[integer_checker_idx]))

    nodo_menor <- solucion_recursiva(nodo_menor)
    nodo_actual$nodo_menor = nodo_menor
    
    #### Rama mayor igual
    nodo_mayor <- get_nuevo_nodo()
    nodo_mayor$nodo_padre <- nodo_actual
    nodo_mayor$modelo <- create_lp_model()
    # Agregar restriccion mayor igual
    nodo_mayor$restriccion <- c(nodo_mayor$modelo, xt = constraint_vector, type = "<=", rhs = floor(sorted_dvar[integer_checker_idx])+1)

    nodo_mayor <- solucion_recursiva(nodo_mayor)
    nodo_actual$nodo_mayor = nodo_mayor
    return (nodo_actual)
  }
}



  
  
  
  
  
  
