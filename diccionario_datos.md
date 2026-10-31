# 02. Diccionario de datos
## Sistema de Inventario y Facturación

### 1. Introducción

El presente diccionario de datos describe la estructura de la base de datos del Sistema de Inventario y Facturación, desarrollado en PostgreSQL.

La base de datos está compuesta por 14 tablas que permiten administrar categorías, proveedores, clientes, usuarios, productos, compras, facturas, pagos y movimientos de inventario.

Se documentan los nombres de los campos, tipos de datos, llaves primarias y foráneas, restricciones y descripción de cada atributo.

**Motor de base de datos:** PostgreSQL 15.12.

### 2. Convenciones utilizadas

| Abreviatura | Significado |
|---|---|
| PK | Llave primaria |
| FK | Llave foránea |
| UNIQUE | Valor único |
| NOT NULL | Campo obligatorio |
| DEFAULT | Valor predeterminado |
| CHECK | Restricción de validación |

Los campos identificadores utilizan columnas `INTEGER` generadas mediante `IDENTITY`, para asignar valores automáticamente.

---

### 3. Diccionario de datos por entidad

### 3.1. Tabla: categorias

Almacena las categorías utilizadas para clasificar los productos del inventario.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_categoria | INTEGER | PK | NOT NULL, IDENTITY | Identificador de la categoría. |
| nombre_categoria | VARCHAR(100) | | NOT NULL, UNIQUE | Nombre de la categoría. |
| descripcion | VARCHAR(250) | | NULL | Descripción de la categoría. |

### 3.2. Tabla: proveedores

Almacena la información de las empresas o personas que suministran productos.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_proveedor | INTEGER | PK | NOT NULL, IDENTITY | Identificador del proveedor. |
| nombre_empresa | VARCHAR(150) | | NOT NULL | Nombre de la empresa proveedora. |
| nit | VARCHAR(20) | | NOT NULL, UNIQUE | Número de identificación tributaria. |
| telefono | VARCHAR(20) | | NULL | Teléfono del proveedor. |
| correo_electronico | VARCHAR(150) | | UNIQUE, NULL | Correo electrónico del proveedor. |
| direccion | VARCHAR(250) | | NULL | Dirección del proveedor. |
| contacto_principal | VARCHAR(100) | | NULL | Nombre del contacto principal. |

### 3.3. Tabla: clientes

Registra la información de los clientes que realizan compras en el establecimiento.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_cliente | INTEGER | PK | NOT NULL, IDENTITY | Identificador del cliente. |
| nit | VARCHAR(20) | | NOT NULL, UNIQUE | Número de identificación tributaria. |
| nombre_completo | VARCHAR(150) | | NOT NULL | Nombre completo del cliente. |
| direccion | VARCHAR(250) | | NULL | Dirección del cliente. |
| telefono | VARCHAR(20) | | NULL | Número telefónico. |
| correo_electronico | VARCHAR(150) | | UNIQUE, NULL | Correo electrónico del cliente. |

### 3.4. Tabla: roles

Almacena los diferentes roles que pueden asignarse a los usuarios del sistema.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_rol | INTEGER | PK | NOT NULL, IDENTITY | Identificador del rol. |
| nombre_rol | VARCHAR(50) | | NOT NULL, UNIQUE | Nombre del rol. |
| descripcion | VARCHAR(200) | | NULL | Descripción de las funciones del rol. |

### 3.5. Tabla: usuarios

Almacena las cuentas de los usuarios que participan en las operaciones del sistema.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_usuario | INTEGER | PK | NOT NULL, IDENTITY | Identificador del usuario. |
| nombre_completo | VARCHAR(150) | | NOT NULL | Nombre completo del usuario. |
| nombre_usuario | VARCHAR(50) | | NOT NULL, UNIQUE | Nombre utilizado para iniciar sesión. |
| correo_electronico | VARCHAR(150) | | NOT NULL, UNIQUE | Correo electrónico del usuario. |
| contrasena_hash | VARCHAR(255) | | NOT NULL | Contraseña almacenada mediante un hash. |
| id_rol | INTEGER | FK | NOT NULL | Referencia al rol asignado al usuario. |
| activo | BOOLEAN | | NOT NULL, DEFAULT TRUE | Indica si el usuario está activo. |

**Relación:** `id_rol` referencia a `roles(id_rol)`.

### 3.6. Tabla: formas_pago

Contiene los métodos de pago disponibles para registrar los pagos de las facturas.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_forma_pago | INTEGER | PK | NOT NULL, IDENTITY | Identificador de la forma de pago. |
| nombre_forma_pago | VARCHAR(50) | | NOT NULL, UNIQUE | Nombre de la forma de pago. |
| descripcion | VARCHAR(200) | | NULL | Descripción de la forma de pago. |
| activo | BOOLEAN | | NOT NULL, DEFAULT TRUE | Indica si la forma de pago está habilitada. |

### 3.7. Tabla: tipos_documento

Almacena los tipos de documentos utilizados en las operaciones de compra y facturación.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_tipo_documento | INTEGER | PK | NOT NULL, IDENTITY | Identificador del tipo de documento. |
| nombre_tipo_documento | VARCHAR(80) | | NOT NULL, UNIQUE | Nombre del tipo de documento. |
| descripcion | VARCHAR(200) | | NULL | Descripción del tipo de documento. |

### 3.8. Tabla: productos

Almacena los productos comercializados y permite controlar sus precios y existencias.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_producto | INTEGER | PK | NOT NULL, IDENTITY | Identificador del producto. |
| codigo_barras | VARCHAR(50) | | NOT NULL, UNIQUE | Código de identificación del producto. |
| nombre_producto | VARCHAR(150) | | NOT NULL | Nombre del producto. |
| descripcion | VARCHAR(250) | | NULL | Descripción del producto. |
| precio_compra | NUMERIC(12,2) | | NOT NULL, CHECK > 0 | Precio de adquisición. |
| precio_venta | NUMERIC(12,2) | | NOT NULL, CHECK > 0 | Precio de venta. |
| stock_actual | INTEGER | | NOT NULL, DEFAULT 0, CHECK >= 0 | Existencias disponibles. |
| stock_minimo | INTEGER | | NOT NULL, DEFAULT 0, CHECK >= 0 | Cantidad mínima establecida. |
| id_categoria | INTEGER | FK | NOT NULL | Categoría a la que pertenece el producto. |
| id_proveedor | INTEGER | FK | NOT NULL | Proveedor asociado al producto. |
| activo | BOOLEAN | | NOT NULL, DEFAULT TRUE | Indica si el producto está activo. |

**Relaciones:**
- `id_categoria` referencia a `categorias(id_categoria)`.
- `id_proveedor` referencia a `proveedores(id_proveedor)`.

### 3.9. Tabla: compras_encabezado

Registra la información general de las compras realizadas a los proveedores.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_compra | INTEGER | PK | NOT NULL, IDENTITY | Identificador de la compra. |
| numero_compra | VARCHAR(30) | | NOT NULL, UNIQUE | Número correlativo de compra. |
| fecha_compra | TIMESTAMP | | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha y hora de la compra. |
| id_proveedor | INTEGER | FK | NOT NULL | Proveedor de la compra. |
| id_usuario | INTEGER | FK | NOT NULL | Usuario responsable. |
| id_tipo_documento | INTEGER | FK | NOT NULL | Tipo de documento asociado. |
| estado | VARCHAR(20) | | NOT NULL, DEFAULT 'PENDIENTE', CHECK | Estado de la compra. |
| total | NUMERIC(12,2) | | NOT NULL, DEFAULT 0, CHECK >= 0 | Importe total de la compra. |

**Estados permitidos:** `PENDIENTE`, `RECIBIDA` y `ANULADA`.

**Relaciones:**
- `id_proveedor` referencia a `proveedores(id_proveedor)`.
- `id_usuario` referencia a `usuarios(id_usuario)`.
- `id_tipo_documento` referencia a `tipos_documento(id_tipo_documento)`.

### 3.10. Tabla: detalle_compra

Almacena los productos y cantidades que forman parte de cada compra.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_detalle_compra | INTEGER | PK | NOT NULL, IDENTITY | Identificador del detalle. |
| id_compra | INTEGER | FK | NOT NULL | Compra a la que pertenece. |
| id_producto | INTEGER | FK | NOT NULL | Producto adquirido. |
| cantidad | INTEGER | | NOT NULL, CHECK > 0 | Cantidad comprada. |
| precio_unitario | NUMERIC(12,2) | | NOT NULL, CHECK > 0 | Precio por unidad. |
| subtotal | NUMERIC(12,2) | | GENERATED ALWAYS AS STORED | Resultado de multiplicar cantidad por precio unitario. |

**Relaciones:**
- `id_compra` referencia a `compras_encabezado(id_compra)`.
- `id_producto` referencia a `productos(id_producto)`.

**Restricción adicional:** UNIQUE (`id_compra`, `id_producto`).

### 3.11. Tabla: facturas_encabezado

Registra la información general de las facturas emitidas a los clientes.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_factura | INTEGER | PK | NOT NULL, IDENTITY | Identificador de la factura. |
| numero_factura | VARCHAR(30) | | NOT NULL, UNIQUE | Número correlativo de factura. |
| fecha_emision | TIMESTAMP | | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha y hora de emisión. |
| id_cliente | INTEGER | FK | NOT NULL | Cliente asociado. |
| id_usuario | INTEGER | FK | NOT NULL | Usuario responsable de la factura. |
| id_tipo_documento | INTEGER | FK | NOT NULL | Tipo de documento asociado. |
| estado | VARCHAR(20) | | NOT NULL, DEFAULT 'PENDIENTE', CHECK | Estado de la factura. |
| subtotal | NUMERIC(12,2) | | NOT NULL, DEFAULT 0, CHECK >= 0 | Suma de los subtotales de los detalles. |
| impuesto | NUMERIC(12,2) | | NOT NULL, DEFAULT 0, CHECK >= 0 | Importe correspondiente al impuesto. |
| total | NUMERIC(12,2) | | NOT NULL, DEFAULT 0, CHECK >= 0 | Total de la factura. |

**Estados permitidos:** `PENDIENTE`, `PAGADO` y `ANULADO`.

**Relaciones:**
- `id_cliente` referencia a `clientes(id_cliente)`.
- `id_usuario` referencia a `usuarios(id_usuario)`.
- `id_tipo_documento` referencia a `tipos_documento(id_tipo_documento)`.

### 3.12. Tabla: detalle_factura

Almacena los productos, cantidades y precios correspondientes a cada factura. Esta tabla permite establecer la relación entre las facturas y los productos.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_detalle_factura | INTEGER | PK | NOT NULL, IDENTITY | Identificador del detalle. |
| id_factura | INTEGER | FK | NOT NULL | Factura a la que pertenece. |
| id_producto | INTEGER | FK | NOT NULL | Producto vendido. |
| cantidad | INTEGER | | NOT NULL, CHECK > 0 | Cantidad vendida. |
| precio_unitario | NUMERIC(12,2) | | NOT NULL, CHECK > 0 | Precio de venta por unidad. |
| subtotal | NUMERIC(12,2) | | GENERATED ALWAYS AS STORED | Resultado de multiplicar cantidad por precio unitario. |

**Relaciones:**
- `id_factura` referencia a `facturas_encabezado(id_factura)`.
- `id_producto` referencia a `productos(id_producto)`.

**Restricción adicional:** UNIQUE (`id_factura`, `id_producto`).

### 3.13. Tabla: movimientos_inventario

Registra las entradas, salidas y ajustes realizados sobre las existencias de los productos.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_movimiento | INTEGER | PK | NOT NULL, IDENTITY | Identificador del movimiento. |
| id_producto | INTEGER | FK | NOT NULL | Producto afectado. |
| fecha_movimiento | TIMESTAMP | | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha y hora del movimiento. |
| tipo_movimiento | VARCHAR(20) | | NOT NULL, CHECK | Tipo de movimiento. |
| cantidad | INTEGER | | NOT NULL, CHECK > 0 | Cantidad involucrada en el movimiento. |
| existencia_anterior | INTEGER | | NOT NULL, CHECK >= 0 | Existencia antes del movimiento. |
| existencia_nueva | INTEGER | | NOT NULL, CHECK >= 0 | Existencia después del movimiento. |
| observacion | VARCHAR(250) | | NULL | Descripción del movimiento. |
| id_usuario | INTEGER | FK | NOT NULL | Usuario responsable del movimiento. |
| id_compra | INTEGER | FK | NULL | Compra que origina la entrada, cuando corresponde. |
| id_factura | INTEGER | FK | NULL | Factura que origina la salida, cuando corresponde. |

**Tipos permitidos:** `ENTRADA`, `SALIDA` y `AJUSTE`.

**Relaciones:**
- `id_producto` referencia a `productos(id_producto)`.
- `id_usuario` referencia a `usuarios(id_usuario)`.
- `id_compra` referencia a `compras_encabezado(id_compra)`.
- `id_factura` referencia a `facturas_encabezado(id_factura)`.

**Restricciones adicionales:**
- No se permite asociar simultáneamente una compra y una factura en el mismo movimiento.
- Se utilizan índices únicos parciales para evitar duplicar el movimiento de un mismo producto dentro de una compra o factura.

### 3.14. Tabla: pagos

Registra los pagos realizados por los clientes y los asocia con las facturas correspondientes.

| Campo | Tipo de dato | Llave | Restricción | Descripción |
|---|---|---|---|---|
| id_pago | INTEGER | PK | NOT NULL, IDENTITY | Identificador del pago. |
| id_factura | INTEGER | FK | NOT NULL | Factura a la que corresponde el pago. |
| id_forma_pago | INTEGER | FK | NOT NULL | Método utilizado para realizar el pago. |
| fecha_pago | TIMESTAMP | | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Fecha y hora del pago. |
| monto | NUMERIC(12,2) | | NOT NULL, CHECK > 0 | Importe del pago. |
| referencia | VARCHAR(100) | | NULL | Referencia de la operación. |
| estado | VARCHAR(20) | | NOT NULL, DEFAULT 'CONFIRMADO', CHECK | Estado del pago. |

**Estados permitidos:** `PENDIENTE`, `CONFIRMADO` y `ANULADO`.

**Relaciones:**
- `id_factura` referencia a `facturas_encabezado(id_factura)`.
- `id_forma_pago` referencia a `formas_pago(id_forma_pago)`.

---

### 4. Resumen de entidades

| N.º | Tabla | Función principal |
|---:|---|---|
| 1 | categorias | Clasificación de productos. |
| 2 | proveedores | Administración de proveedores. |
| 3 | clientes | Registro de clientes. |
| 4 | roles | Clasificación de roles de usuario. |
| 5 | usuarios | Administración de usuarios. |
| 6 | formas_pago | Catálogo de métodos de pago. |
| 7 | tipos_documento | Catálogo de tipos de documentos. |
| 8 | productos | Administración y control de existencias. |
| 9 | compras_encabezado | Registro general de compras. |
| 10 | detalle_compra | Productos incluidos en las compras. |
| 11 | facturas_encabezado | Registro general de facturas. |
| 12 | detalle_factura | Productos incluidos en las facturas. |
| 13 | movimientos_inventario | Historial de movimientos de existencias. |
| 14 | pagos | Registro de pagos de facturas. |

### 5. Consideraciones finales

La estructura de la base de datos utiliza llaves primarias para identificar de manera única cada registro y llaves foráneas para mantener la integridad referencial entre las entidades.

También incorpora restricciones de unicidad y validaciones para controlar cantidades, precios, existencias y estados de las operaciones.

Los campos `subtotal` de las tablas `detalle_compra` y `detalle_factura` son columnas generadas automáticamente por PostgreSQL, mientras que los identificadores utilizan columnas de identidad.

Este diccionario constituye la referencia de la estructura física de la base de datos del Sistema de Inventario y Facturación.
