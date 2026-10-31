# 04. Normalización de la base de datos
## Sistema de Inventario y Facturación

### 1. Introducción

La normalización es un proceso utilizado en el diseño de bases de datos relacionales para organizar la información, reducir la redundancia y evitar anomalías durante las operaciones de inserción, actualización y eliminación.

El Sistema de Inventario y Facturación fue diseñado utilizando un modelo relacional compuesto por 14 tablas, con el propósito de organizar la información de productos, clientes, proveedores, compras, facturas, pagos y movimientos de inventario.

El diseño considera las tres primeras formas normales: Primera Forma Normal (1FN), Segunda Forma Normal (2FN) y Tercera Forma Normal (3FN).

### 2. Primera Forma Normal (1FN)

Una tabla cumple con la Primera Forma Normal cuando:

- Cada columna contiene valores atómicos, es decir, un solo valor por registro.
- No existen grupos repetitivos de columnas.
- Cada registro puede identificarse de manera única mediante una llave primaria.

**Aplicación en el proyecto**

Las tablas del sistema almacenan información organizada en registros individuales y columnas específicas.

Por ejemplo, en la tabla `productos`, cada registro representa un producto y sus atributos se encuentran separados en columnas:

| id_producto | nombre_producto | precio_venta | stock_actual |
|---:|---|---:|---:|
| 1 | Martillo de acero | 55.00 | 30 |
| 2 | Destornillador plano | 22.00 | 25 |
| 3 | Destornillador Phillips | 25.00 | 18 |

Cada campo almacena un único valor y no se utilizan columnas que contengan listas de productos o cantidades.

También se separaron los encabezados de compras y facturas de sus respectivos detalles, evitando almacenar varios productos en una misma columna.

**Conclusión de 1FN**

El modelo cumple con la Primera Forma Normal porque sus atributos almacenan valores individuales, las tablas cuentan con identificadores únicos y no existen grupos repetitivos de atributos.

### 3. Segunda Forma Normal (2FN)

Una tabla cumple con la Segunda Forma Normal cuando:

- Cumple previamente con la Primera Forma Normal.
- Todos sus atributos que no forman parte de una clave dependen completamente de la llave primaria.
- No existen dependencias parciales respecto a una parte de una llave primaria compuesta.

**Aplicación en el proyecto**

Las tablas principales utilizan llaves primarias individuales, por ejemplo:

- `productos.id_producto`
- `clientes.id_cliente`
- `proveedores.id_proveedor`
- `facturas_encabezado.id_factura`
- `compras_encabezado.id_compra`

Los atributos de cada entidad dependen de su respectivo identificador.

Un ejemplo se encuentra en `facturas_encabezado`, donde los datos generales de una factura dependen de `id_factura`, mientras que los productos, cantidades y precios se almacenan por separado en `detalle_factura`.

La tabla `detalle_factura` utiliza un identificador propio, `id_detalle_factura`, y adicionalmente posee una restricción UNIQUE sobre la combinación `id_factura` e `id_producto`.

Esto permite identificar cada línea de detalle y evitar que un mismo producto se repita dentro de una misma factura.

De manera equivalente, `detalle_compra` utiliza `id_detalle_compra` como llave primaria y una restricción UNIQUE sobre `id_compra` e `id_producto`.

**Conclusión de 2FN**

El modelo cumple con la Segunda Forma Normal porque los atributos de cada entidad dependen de su identificador completo y las tablas de detalle separan los datos correspondientes a cada operación.

### 4. Tercera Forma Normal (3FN)

Una tabla cumple con la Tercera Forma Normal cuando:

- Cumple con la Primera y Segunda Forma Normal.
- Sus atributos que no forman parte de una clave dependen directamente de la llave primaria.
- No existen dependencias transitivas entre atributos no clave.

**Aplicación en el proyecto**

El modelo separa información que pertenece a entidades diferentes, evitando almacenar datos descriptivos de otras entidades dentro de una misma tabla.

Se presentan los siguientes ejemplos:

**Ejemplo 1. Productos y categorías**

La tabla `productos` almacena el identificador de la categoría mediante `id_categoria`, pero el nombre y la descripción de la categoría se mantienen en la tabla `categorias`.

De esta manera, la información de una categoría no necesita repetirse en cada producto.

Dependencia funcional:

`id_categoria → nombre_categoria, descripcion`

**Ejemplo 2. Productos y proveedores**

La información de los proveedores se almacena en la tabla `proveedores`, mientras que `productos` conserva únicamente su identificador de referencia.

Dependencia funcional:

`id_proveedor → nombre_empresa, nit, telefono, correo_electronico, direccion, contacto_principal`

Esto evita repetir los datos completos del proveedor en cada producto.

**Ejemplo 3. Usuarios y roles**

La tabla `usuarios` almacena el identificador del rol asignado, mientras que la descripción del rol se conserva en la tabla `roles`.

Dependencia funcional:

`id_rol → nombre_rol, descripcion`

Así, los datos de los roles se administran en un único lugar.

**Ejemplo 4. Facturas y clientes**

La tabla `facturas_encabezado` conserva `id_cliente` como referencia, mientras que los datos personales y de identificación del cliente se almacenan en `clientes`.

Dependencia funcional:

`id_cliente → nit, nombre_completo, direccion, telefono, correo_electronico`

Esta separación permite que un cliente tenga varias facturas sin duplicar sus datos personales en cada una.

**Ejemplo 5. Compras y facturas**

Los encabezados y detalles se almacenan en tablas independientes.

Los encabezados contienen la información general de cada operación, mientras que las tablas de detalle almacenan los productos, cantidades, precios y subtotales correspondientes.

Esta separación evita repetir los datos generales de las operaciones en cada línea de detalle.

**Conclusión de 3FN**

El modelo aplica la Tercera Forma Normal mediante la separación de entidades independientes y el uso de llaves foráneas para relacionarlas.

De esta manera, los atributos descriptivos se almacenan en las tablas a las que pertenecen, reduciendo la redundancia y facilitando el mantenimiento de la información.

### 5. Dependencias funcionales identificadas

Las principales dependencias funcionales del modelo se presentan a continuación:

| Tabla | Dependencia funcional principal |
|---|---|
| categorias | id_categoria → nombre_categoria, descripcion |
| proveedores | id_proveedor → datos del proveedor |
| clientes | id_cliente → datos del cliente |
| roles | id_rol → nombre_rol, descripcion |
| usuarios | id_usuario → datos del usuario |
| formas_pago | id_forma_pago → datos de la forma de pago |
| tipos_documento | id_tipo_documento → datos del tipo de documento |
| productos | id_producto → datos del producto |
| compras_encabezado | id_compra → datos generales de la compra |
| detalle_compra | id_detalle_compra → id_compra, id_producto, cantidad, precio_unitario |
| facturas_encabezado | id_factura → datos generales de la factura |
| detalle_factura | id_detalle_factura → id_factura, id_producto, cantidad, precio_unitario |
| movimientos_inventario | id_movimiento → datos del movimiento |
| pagos | id_pago → datos del pago |

Las columnas UNIQUE también permiten identificar dependencias funcionales alternativas, por ejemplo, `nit` en clientes y proveedores, y `numero_factura` en facturas.

### 6. Tratamiento de los campos calculados

El sistema utiliza columnas calculadas para evitar que los usuarios tengan que introducir manualmente resultados que pueden obtenerse a partir de otros atributos.

En las tablas `detalle_compra` y `detalle_factura`, el campo `subtotal` se genera automáticamente mediante la multiplicación de la cantidad por el precio unitario.

La fórmula utilizada es:

`subtotal = cantidad × precio_unitario`

Los encabezados de compras y facturas almacenan sus totales, que se recalculan mediante funciones y disparadores cuando se modifican los detalles correspondientes.

Estos valores representan información derivada y requieren mantenerse sincronizados con los detalles para evitar inconsistencias.

### 7. Beneficios de la normalización en el sistema

La aplicación de las formas normales proporciona los siguientes beneficios:

1. Reduce la duplicación de información de clientes, proveedores, categorías y usuarios.
2. Facilita la actualización de los datos sin modificar múltiples registros.
3. Evita anomalías de inserción, actualización y eliminación.
4. Mantiene la integridad de las relaciones mediante llaves primarias y foráneas.
5. Permite administrar compras y facturas mediante encabezados y detalles independientes.
6. Facilita la generación de reportes y consultas SQL.
7. Mejora la organización y el mantenimiento de la base de datos.

### 8. Conclusión general

El diseño de la base de datos del Sistema de Inventario y Facturación aplica los principios de normalización hasta la Tercera Forma Normal.

La separación de las entidades, la utilización de llaves primarias y foráneas, las tablas intermedias y las restricciones de integridad permiten organizar adecuadamente la información y reducir la redundancia.

La estructura resultante facilita la administración de los productos, clientes, proveedores, compras, facturas, pagos y movimientos de inventario, proporcionando una base organizada para el funcionamiento del sistema.