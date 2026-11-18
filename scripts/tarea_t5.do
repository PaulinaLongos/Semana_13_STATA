** 1. Encabezado con macros de configuración
pwd
// cd "C:\Users\TEST\Documents\FUNDAMENTOS-PROGRAMACION\Semana_13_STATA"
version 14
clear all
set more off
capture mkdir "output"
capture log close
log using "output/tarea_t5.log", replace text

* --- Parámetros (lo único que se edita) ---
local datos     "data/raw/casen_reducido.csv"
local depvar    "ingreso"
local numericas "ingreso educ edad experiencia"
local controles "educ experiencia"
local grupos    "sector region genero"
global umbral   = 500000
* local: Existe solo dentro del do-file que lo define y desaparece al terminar, sirve para los parámetros propios de este análisis , así no se arrastran a otros do-files por accidente.
* global: queda disponible en cualquier do-file que se corra en la misma sesión de Stata y se llama con $umbral. queda para un valor que se quiera compartir.

** 2. Carga y prepara los datos
import delimited "`datos'", clear varnames(1) encoding("utf-8")
generate experiencia = max(edad - educ - 6, 0)
generate mujer = (genero == "F")    
label define sexo 0 "Hombre" 1 "Mujer"
label values mujer sexo
tabulate genero mujer

** 3. Un foreach sobre una lista de variables
foreach v of local numericas {
    summarize `v', detail
}

** 4. Un forvalues con un rango
forvalues t = 4(4)16 {
    quietly count if educ >= `t' & educ < `t' + 4
    display "Educación de `t' a " `t' + 3 " años: " r(N) " personas"
}
	
** 5. Un program reutilizable con argumentos
capture program drop descriptivos_grupo
program define descriptivos_grupo
    display _newline "=== Descriptivos por `1' ==="
    tabulate `1'
    tabstat ingreso educ, by(`1') statistics(mean sd n)
end

foreach g of local grupos {
    descriptivos_grupo `g'
}
	
** 6. Usa `tempvar` al menos una vez
tempvar ing_miles
generate `ing_miles' = ingreso / 1000
summarize `ing_miles'
* ¿Por qué `tempvar` es más seguro que crear una variable normal y borrarla después.	
* tempvar es más seguro porque crea una variable temporal que Stata elimina automáticamente cuando termina el programa o bloque donde se utiliza, en cambio si creamos una variable normal y después la borramos manualmente podemos olvidarnos de eliminarla o borrar accidentalmente una variable importante.

** 7. Maneja los missing correctamente
count if ingreso > $umbral
count if ingreso > $umbral & !missing(ingreso)
* ¿Qué pasaría sin el & !missing(ingreso)
* Sin & !missing(ingreso) stata también contaría los valores missing como si fueran mayores al umbral dando un resultado incorrecto.

** 8. Modelos guardados y comparados (S13)
quietly regress `depvar' `controles'
estimates store m1
quietly regress `depvar' `controles' i.mujer
estimates store m2
estimates table m1 m2, b(%9.0f) se stats(N r2) stfmt(%5.3f)

display "Coeficiente de educ (m2): " _b[educ]

** 9. Una regresión por grupo, guardada en una matriz y exportada
levelsof sector, local(sectores)
local n : word count `sectores'
matrix resultados = J(`n', 3, .)
matrix colnames resultados = coef_educ error_est n

local i = 1
foreach s of local sectores {
    quietly regress `depvar' educ if sector == "`s'"
    matrix resultados[`i', 1] = _b[educ]
    matrix resultados[`i', 2] = _se[educ]
    matrix resultados[`i', 3] = e(N)
    local ++i
}
matrix list resultados

putexcel set "output/tarea_t5_por_sector.xlsx", replace
putexcel A1 = ("sector") B1 = ("coef_educ") C1 = ("error_est") D1 = ("n")
putexcel B2 = matrix(resultados)

local fila = 2
foreach s of local sectores {
    putexcel A`fila' = ("`s'")
    local ++fila
}

** 10. Cierra el log e interpreta
* El coeficiente de educación en m2 es de aproximadamente 42.246 pesos, cada año adicional de educación se asocia con unos 42 mil pesos más de ingreso.
* Entre m1 y m2, el coeficiente de educación casi no cambia y el R2 aumenta levemente de 0,458 a 0,475.
* Por sector las regresiones tienen entre 5 y 15 personas por lo que su precisión es limitada.
* Una limitación es que la muestra es pequeña ya que solo considera 55 personas con ingresos válidos.
* Además la experiencia se calcula con la edad y educación por lo que no refleja necesariamente la experiencia laboral real.
log close
	
	
	
	
	
	
	
	
	
	