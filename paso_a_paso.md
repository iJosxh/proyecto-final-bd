# 05. Guía paso a paso
## Sistema de Inventario y Facturación

### 1. Introducción

El presente documento describe el procedimiento para instalar, configurar y ejecutar la base de datos del Sistema de Inventario y Facturación.

Se detallan los requisitos previos, el orden de ejecución de los scripts SQL, las verificaciones necesarias y algunos problemas comunes que pueden presentarse durante la instalación.

### 2. Requisitos previos

Para ejecutar correctamente el proyecto se necesitan los siguientes programas:

| Recurso | Descripción |
|---|---|
| PostgreSQL | Sistema gestor de base de datos. |
| DBeaver | Cliente utilizado para administrar la base de datos y ejecutar consultas SQL. |
| Scripts SQL | Archivos de creación de estructura, inserción de datos y consultas. |
| Git | Herramienta opcional para descargar el repositorio del proyecto. |

### 3. Preparación del entorno

Antes de ejecutar los scripts, se debe comprobar que PostgreSQL esté instalado y que el servicio se encuentre iniciado.

Posteriormente, se debe abrir DBeaver y configurar una conexión con PostgreSQL utilizando los datos correspondientes al servidor:

- Servidor: localhost, si se trabaja localmente.
- Puerto: 5432, salvo que se haya configurado otro.
- Usuario: usuario de PostgreSQL configurado durante la instalación.
- Contraseña: contraseña correspondiente al usuario.

Una vez establecida la conexión, se puede comenzar con la creación de la base de datos.

### 4. Orden de ejecución de los scripts

Los archivos SQL deben ejecutarse en orden, respetando las dependencias entre los objetos de la base de datos.

#### Paso 1. Creación de la base de datos

**Archivo:** `sql/01_ddl_crear_base_datos.sql`

Este script se encarga de crear la base de datos que utilizará el sistema.

Después de ejecutar el script, se debe actualizar la conexión de DBeaver y seleccionar la nueva base de datos.

#### Paso 2. Creación de las tablas

**Archivo:** `sql/02_ddl_crear_tablas.sql`

Este script crea las 14 tablas que conforman el modelo relacional.

También establece:

- Llaves primarias.
- Llaves foráneas.
- Restricciones UNIQUE.
- Restricciones CHECK.
- Campos NOT NULL.
- Valores DEFAULT.
- Columnas calculadas, cuando corresponda.

Es importante ejecutar este archivo después de crear la base de datos.

#### Paso 3. Inserción de datos de prueba

**Archivo:** `sql/03_dml_datos_prueba.sql`

Este script contiene las instrucciones INSERT INTO necesarias para poblar las tablas con información de prueba.

Los registros deben insertarse respetando las relaciones y dependencias entre las entidades.

Se recomienda comenzar con las tablas de catálogo y continuar con las entidades principales y las transacciones.

#### Paso 4. Consultas y reportes

**Archivo:** `sql/04_consultas_reportes.sql`

Este archivo contiene las consultas SQL utilizadas para demostrar las funcionalidades del sistema.

Entre los reportes contemplados se encuentran:

- Productos con bajo stock.
- Productos con su categoría y proveedor.
- Detalle completo de facturas.
- Ventas totales por cliente.
- Ventas por producto.
- Compras por proveedor.
- Productos que nunca han sido vendidos.
- Ventas por rango de fechas.
- Consultas con subconsultas, agrupaciones y funciones de agregación.

#### Paso 5. Funcionalidades adicionales

**Archivo:** `sql/05_extras_opcional.sql`

Este archivo puede utilizarse para organizar funcionalidades adicionales, como funciones, disparadores y vistas, si estas no están incluidas en el script principal de creación de tablas.

Su ejecución debe realizarse después de crear las tablas y cargar los datos que requieran las pruebas.

### 5. Verificación de la instalación

Después de ejecutar los scripts, se recomienda realizar las siguientes comprobaciones.

#### 5.1. Verificar las tablas creadas

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

El resultado debe mostrar las 14 tablas del sistema.

#### 5.2. Verificar la cantidad de registros

```sql
SELECT 'categorias' AS tabla, COUNT(*) AS registros
FROM categorias

UNION ALL

SELECT 'proveedores', COUNT(*)
FROM proveedores

UNION ALL

SELECT 'clientes', COUNT(*)
FROM clientes

UNION ALL

SELECT 'productos', COUNT(*)
FROM productos

UNION ALL

SELECT 'compras_encabezado', COUNT(*)
FROM compras_encabezado

UNION ALL

SELECT 'detalle_compra', COUNT(*)
FROM detalle_compra

UNION ALL

SELECT 'facturas_encabezado', COUNT(*)
FROM facturas_encabezado

UNION ALL

SELECT 'detalle_factura', COUNT(*)
FROM detalle_factura

UNION ALL

SELECT 'movimientos_inventario', COUNT(*)
FROM movimientos_inventario

UNION ALL

SELECT 'pagos', COUNT(*)
FROM pagos;
```

Los resultados deben corresponder con los registros insertados en el script DML.

#### 5.3. Verificar las vistas

```sql
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;
```

Se deben encontrar las vistas creadas para los reportes del sistema.

#### 5.4. Verificar las funciones

```sql
SELECT
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;
```

Esta consulta permite identificar las funciones y procedimientos disponibles en el esquema.

#### 5.5. Verificar los disparadores

```sql
SELECT
    trigger_name,
    event_object_table,
    event_manipulation,
    action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;
```

Esta consulta permite comprobar los disparadores asociados a las tablas del sistema.

### 6. Pruebas funcionales

Una vez instalada la base de datos, se recomienda realizar pruebas para comprobar el funcionamiento de sus principales procesos.

Entre las pruebas realizadas durante el desarrollo se encuentran:

1. Registrar una entrada de inventario y comprobar el incremento de existencias.
2. Registrar una salida y comprobar la disminución de existencias.
3. Realizar un ajuste de inventario y verificar la nueva existencia.
4. Intentar realizar una salida superior al stock disponible y comprobar que el sistema rechaza la operación.
5. Cambiar el estado de una compra a recibida y comprobar la generación automática de movimientos de entrada.
6. Cambiar el estado de una factura a pagada y comprobar la generación automática de movimientos de salida.
7. Modificar los detalles de compras y facturas y comprobar el recálculo de sus totales.

Las pruebas que modifican datos deben ejecutarse dentro de transacciones controladas cuando se requiera conservar intacta la información original.

### 7. Problemas comunes y soluciones

| Problema | Posible solución |
|---|---|
| No se puede conectar a PostgreSQL. | Verificar que el servicio esté iniciado y que el puerto y las credenciales sean correctos. |
| La base de datos no existe. | Ejecutar primero el script de creación de la base de datos. |
| Error de llave foránea durante los INSERT. | Verificar que los registros relacionados existan antes de insertar los datos dependientes. |
| Error de objeto duplicado. | Comprobar si las tablas, funciones o vistas ya existen antes de ejecutar nuevamente el script. |
| Error de función no encontrada. | Verificar que la función haya sido creada y que se utilicen los parámetros y tipos de datos correctos. |
| Error de stock insuficiente. | Comprobar las existencias actuales antes de registrar una salida. |
| Error de permisos. | Verificar los permisos del usuario utilizado para conectarse a PostgreSQL. |

### 8. Evidencias de ejecución

Para demostrar el funcionamiento del proyecto se recomienda incluir capturas de pantalla de DBeaver que muestren:

- Conexión exitosa a PostgreSQL.
- Creación de la base de datos.
- Listado de las 14 tablas.
- Relaciones entre las entidades.
- Inserción de datos de prueba.
- Resultados de las consultas SQL.
- Ejecución de funciones y disparadores.
- Actualización de existencias.
- Resultados de las vistas de reportes.

Las capturas deben mostrar tanto las instrucciones ejecutadas como los resultados obtenidos.

### 9. Conclusión

La guía permite reproducir la instalación y ejecución del Sistema de Inventario y Facturación en un entorno PostgreSQL utilizando DBeaver.

El seguimiento del orden de ejecución garantiza que las estructuras, relaciones, datos y funcionalidades se creen respetando sus dependencias.

Asimismo, las consultas de verificación y las pruebas funcionales permiten comprobar que la base de datos se encuentra correctamente instalada y que sus principales operaciones funcionan según las reglas de negocio definidas.