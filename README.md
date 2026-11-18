# T5 — Do-file automatizado## Objetivo
## Objetivo

Convertir el do-file «escrito a mano» de la A5 en uno **automatizado**: sin código
repetido, parametrizado con macros, con un **programa reutilizable** y con los
resultados **guardados y exportados** en vez de solo mirarlos en pantalla.

## Datos
- casen_reducido.csv en data/raw/

## Cómo correrlo
1. Abrir Stata 18 y ubicar la carpeta del proyecto con `cd`.
2. Abrir `scripts/tarea_t5.do` en el Do-file Editor.
3. Ejecutarlo completo (Ctrl+D, sin seleccionar nada).
4. Revisar `output/tarea_t5.log`, que se genera solo con todos los resultados, y `output/tarea_t5_por_sector.xlsx`.
5. La interpretación de los resultados está en los comentarios al final del archivo.

## Estructura
```
Semana_13_STATA/
├── data/
│   └── raw/
│       └── casen_reducido.csv
├── scripts/
│   └── tarea_t5.do
├── output/
│   ├── tarea_t5.log
│   └── tarea_t5_por_sector.xlsx
└── README.md
```
## Qué automaticé
- Macros de configuración al inicio (`datos`, `depvar`, `numericas`, `controles`, `grupos` y el `global umbral`): lo que puede cambiar se edita en un solo lugar.
- `foreach` sobre la lista de variables numéricas para los descriptivos.
- `forvalues` para contar personas por tramos de educación, usando `r(N)`.
- Un `program` (`descriptivos_grupo`) con argumento, llamado desde un `foreach` para `sector`, `region` y `genero`.
- `tempvar` para una variable intermedia (ingreso en miles) que no queda en los datos.
- Manejo de missing al filtrar por el umbral (`!missing(ingreso)`).
- Dos modelos guardados con `estimates store` y comparados con `estimates table`.
- Regresión por sector en un loop, guardada en una matriz `J()` y exportada a Excel con `putexcel`.

## Qué editar para reutilizarlo con otros datos
Cambiar el bloque de parámetros del encabezado: ruta de los datos, variable dependiente, lista de numéricas, controles, lista de grupos y umbral.
Quedan escritos directamente en el cuerpo y habría que cambiarlos a mano:
- `ingreso` y `educ` dentro del programa `descriptivos_grupo`.
- `educ` y `sector` en la regresión por sector.
- La construcción de `experiencia` y `mujer`, que usa `edad`, `educ` y `genero`.
- El `cd` del encabezado está comentado porque la ruta es de mi computador.

## Autor
Paulina Longos Ulloa – 2026-11-19

## Declaración de autoría y uso de IA
- Herramienta utilizada: Claude
- Para qué la usé: para que me guiara paso a paso en la estructura del do-file, para entender y corregir errores.
- Qué hice yo:  desarrolle cada paso de la t5, verificando con claude y con los guiones de la semana 13. Además realice la prueba de parametrización.
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.
