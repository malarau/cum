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

copy_lp_model <- function(original_lprec) {
  # Crear un nuevo objeto lprec
  new_lprec <- make.lp(0, ncol = ncol(original_lprec))
  
  # Copiar la función objetivo
  set.objfn(new_lprec, get.objfn(original_lprec))
  
  # Copiar el sentido de la optimización (min o max)
  lp.control(new_lprec, sense = lp.control(original_lprec)$sense)
  
  # Copiar las restricciones
  for (i in 1:lp.control(original_lprec)$binvars) {
    add.constraint(new_lprec, get.constrtype(original_lprec, i), get.row(original_lprec, i), get.rhs(original_lprec, i))
  }
  
  # Copiar los límites de las variables de decisión
  set.bounds(new_lprec, lower = get.bounds(original_lprec)$lower, upper = get.bounds(original_lprec)$upper)
  
  # Copiar nombres
  dimnames(new_lprec) <- dimnames(original_lprec)
  
  return(new_lprec)
}


# Definir parámetros globales
N_CONSTRAINTS <- 2  # Número de restricciones
N_DVARS <- 2  # Número de variables de decisión
obj_coefficients <- c(5, 8)  # Coeficientes para la función objetivo
obj_sense = "max"
constraint_coefficients <- matrix(c(1, 1, 5, 9), ncol = N_DVARS, byrow = TRUE)  # Coeficientes para las restricciones
constraint_limits <- c(6, 45)  # Límites para las restricciones

lprec <- create_lp_model()
lprec

typeof(lprec)

lapply(lprec, attributes)

lprec_copia <- copy_lp_model(lprec)
lprec_copia


setClass("employee", slots=list(name="character", id="numeric", contact="character"))


