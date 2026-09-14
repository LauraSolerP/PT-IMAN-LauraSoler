# Explicación del modelo de datos

## Cómo se resuelve el almacenamiento de valores de tipos distintos

En este modelo, los campos no son columnas de una tabla `productos`, sino filas en un catálogo (`campos`), y el valor de cada campo para cada producto es a su vez una fila en `valores_producto`. Esto permite que dos inventarios con conjuntos de campos completamente distintos ("Vehículos" y "Material informático") convivan sobre exactamente las mismas siete tablas, sin que crear un campo nuevo implique ningún `ALTER TABLE`.

Dentro de `valores_producto`, en lugar de una única columna genérica de tipo texto, se usa una columna tipada por cada tipo de dato soportado (`valor_texto`, `valor_numero`, `valor_fecha`, `valor_booleano`, `valor_opcion_id`), quedando en cada fila solo una de ellas rellena, según el tipo del campo al que corresponde. Un `CHECK` con `num_nonnulls()` garantiza que como máximo una columna esté rellena por fila.

## Alternativas descartadas

- **Una sola columna de valor en texto** (`valor TEXT`): esto convierte cada consulta que filtre, ordene o sume por un campo numérico o de fecha en un `CAST` sobre texto, con el consiguiente coste y riesgo de errores de formato. Se descartó por perder toda garantía de tipo a nivel de base de datos.
- **Una columna JSON/JSONB en `productos`** con todos los valores del producto: escritura muy sencilla y sin tablas adicionales, pero imposibilita una `FOREIGN KEY` real hacia `opciones_campo` (no se puede garantizar que el valor elegido sea una opción válida), dificulta indexar y consultar campos individuales sin índices de expresión, y no se beneficia del catálogo compartido de campos entre inventarios.
- **Una tabla por inventario, o `ALTER TABLE` dinámico**: daría tipado nativo e integridad completa, pero contradice directamente el requisito: crear un campo pasaría a requerir intervención de un programador y despliegue de la base de datos.

## Inconvenientes de la solución elegida

- **Rendimiento**: reconstruir la "ficha" completa de un producto exige un `JOIN`/pivote de tantas filas como campos tenga asignados, en vez de leer una sola fila de una tabla ancha. Con inventarios muy grandes y muchos campos, `valores_producto` crece como (nº productos × nº campos), lo que puede volverse costoso de paginar y ordenar por columnas concretas.
- **Integridad de tipos**: el `CHECK` solo garantiza que se rellena una única columna, no que sea la columna correcta según `campos.tipo_campo_id`. Eso requeriría un trigger (o validación exclusivamente en la capa de aplicación), ya que un `CHECK` no puede consultar otra tabla. Del mismo modo, no hay nada a nivel de base de datos que impida que `valor_opcion_id` apunte a una opción de un campo distinto al de la fila.
- **Validación de datos**: reglas como `obligatorio` no se pueden expresar como un `NOT NULL` de base de datos, porque la ausencia de un valor no es un `NULL` en una columna sino la ausencia de una fila en `valores_producto`. Comprobar que todos los campos obligatorios de un producto tienen valor es responsabilidad de la aplicación, no de una restricción declarativa del esquema.
 