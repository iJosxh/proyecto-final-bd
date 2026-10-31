# 03. Justificación de relaciones
## Sistema de Inventario y Facturación

### 1. Introducción

El modelo relacional del Sistema de Inventario y Facturación está compuesto por 14 entidades relacionadas mediante llaves primarias y foráneas.

Las relaciones fueron diseñadas para mantener la integridad referencial, evitar la duplicidad de información y representar correctamente las operaciones de compras, ventas, pagos y control de inventario.

El modelo utiliza principalmente relaciones de uno a muchos (1:N). También implementa relaciones de muchos a muchos (N:M) mediante tablas intermedias, especialmente en el proceso de facturación y compras.

### 2. Justificación de las relaciones

#### 2.1. Categorías y productos

**Relación:** `categorias` → `productos`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `productos.id_categoria`.

Una categoría puede estar asociada con varios productos, mientras que cada producto pertenece a una categoría.

Esta relación permite clasificar los productos y facilita su búsqueda y organización dentro del inventario.

**Regla de negocio:** todo producto debe estar asociado a una categoría existente.

#### 2.2. Proveedores y productos

**Relación:** `proveedores` → `productos`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `productos.id_proveedor`.

Un proveedor puede suministrar diferentes productos, mientras que cada producto tiene asociado un proveedor en el catálogo.

Esta relación permite identificar el proveedor responsable del suministro de cada producto.

**Regla de negocio:** cada producto debe tener un proveedor registrado.

#### 2.3. Roles y usuarios

**Relación:** `roles` → `usuarios`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `usuarios.id_rol`.

Un rol puede asignarse a varios usuarios, mientras que cada usuario tiene asignado un único rol.

Esta relación permite organizar los usuarios según sus responsabilidades dentro del sistema.

**Regla de negocio:** todo usuario debe tener un rol previamente registrado.

#### 2.4. Proveedores y compras

**Relación:** `proveedores` → `compras_encabezado`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `compras_encabezado.id_proveedor`.

Un proveedor puede participar en múltiples compras, mientras que cada compra se registra asociada a un único proveedor.

Esta relación permite consultar el historial de adquisiciones realizadas a cada proveedor.

**Regla de negocio:** toda compra debe identificar al proveedor al que se realizó la adquisición.

#### 2.5. Usuarios y compras

**Relación:** `usuarios` → `compras_encabezado`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `compras_encabezado.id_usuario`.

Un usuario puede registrar diferentes compras, pero cada compra tiene asociado un único usuario responsable.

Esta relación permite identificar quién realizó o registró cada operación de compra.

#### 2.6. Tipos de documento y compras

**Relación:** `tipos_documento` → `compras_encabezado`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `compras_encabezado.id_tipo_documento`.

Un tipo de documento puede utilizarse en múltiples compras, mientras que cada compra tiene asociado un tipo de documento.

Esta relación permite clasificar los documentos utilizados en las operaciones de adquisición.

#### 2.7. Compras y detalle de compra

**Relación:** `compras_encabezado` → `detalle_compra`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `detalle_compra.id_compra`.

Una compra puede contener diferentes productos y cantidades, mientras que cada registro de detalle pertenece a una sola compra.

Esta relación separa la información general de la compra de los productos adquiridos.

**Regla de negocio:** los productos y sus cantidades se almacenan en el detalle, mientras que la información general y el total se almacenan en el encabezado.

#### 2.8. Productos y detalle de compra

**Relación:** `productos` → `detalle_compra`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `detalle_compra.id_producto`.

Un producto puede aparecer en diferentes compras, mientras que cada línea de detalle corresponde a un único producto.

Esta relación permite identificar qué productos fueron adquiridos y en qué cantidades.

**Restricción adicional:** la combinación `id_compra` e `id_producto` es única, evitando registrar dos líneas del mismo producto dentro de una misma compra.

#### 2.9. Clientes y facturas

**Relación:** `clientes` → `facturas_encabezado`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `facturas_encabezado.id_cliente`.

Un cliente puede tener diferentes facturas registradas, mientras que cada factura corresponde a un único cliente.

Esta relación permite consultar el historial de compras y los importes facturados a cada cliente.

#### 2.10. Usuarios y facturas

**Relación:** `usuarios` → `facturas_encabezado`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `facturas_encabezado.id_usuario`.

Un usuario puede registrar múltiples facturas, mientras que cada factura tiene asociado un único usuario responsable.

Esta relación permite mantener la trazabilidad de las operaciones de facturación.

#### 2.11. Tipos de documento y facturas

**Relación:** `tipos_documento` → `facturas_encabezado`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `facturas_encabezado.id_tipo_documento`.

Un tipo de documento puede utilizarse en diferentes facturas, mientras que cada factura tiene asociado un tipo de documento.

Esta relación permite identificar y clasificar el documento utilizado en cada operación de venta.

### 3. Justificación de las tablas puente

#### 3.1. Relación entre facturas y productos

Las entidades `facturas_encabezado` y `productos` mantienen una relación de muchos a muchos (N:M).

Esto ocurre porque:

- Una factura puede incluir varios productos.
- Un mismo producto puede aparecer en diferentes facturas.

Para representar correctamente esta relación se utiliza la tabla intermedia `detalle_factura`.

**Llaves foráneas:**
- `detalle_factura.id_factura` → `facturas_encabezado.id_factura`.
- `detalle_factura.id_producto` → `productos.id_producto`.

La tabla `detalle_factura` almacena información propia de cada línea de venta:

- Cantidad vendida.
- Precio unitario.
- Subtotal calculado.

El campo `subtotal` se genera automáticamente mediante la multiplicación de la cantidad por el precio unitario.

La tabla también posee una restricción UNIQUE sobre la combinación de `id_factura` e `id_producto`, evitando duplicar el mismo producto dentro de una factura.

**Justificación del diseño:**

Se utiliza esta tabla puente para resolver la relación N:M sin almacenar listas de productos dentro de una sola columna de la factura ni duplicar información del encabezado.

Además, permite consultar las ventas por producto, calcular subtotales y generar reportes detallados.

#### 3.2. Relación entre compras y productos

Las entidades `compras_encabezado` y `productos` también mantienen una relación de muchos a muchos (N:M).

Esto se debe a que:

- Una compra puede incluir diferentes productos.
- Un producto puede adquirirse en diferentes compras.

La relación se resuelve mediante la tabla `detalle_compra`.

**Llaves foráneas:**
- `detalle_compra.id_compra` → `compras_encabezado.id_compra`.
- `detalle_compra.id_producto` → `productos.id_producto`.

Esta tabla almacena la cantidad adquirida, el precio unitario y el subtotal calculado.

La restricción UNIQUE sobre `id_compra` e `id_producto` evita repetir un mismo producto dentro de una compra.

### 4. Relaciones de movimientos de inventario

La tabla `movimientos_inventario` permite registrar las operaciones que modifican las existencias de los productos.

Mantiene las siguientes relaciones:

| Tabla relacionada | Llave foránea | Cardinalidad |
|---|---|---|
| productos | id_producto | 1:N |
| usuarios | id_usuario | 1:N |
| compras_encabezado | id_compra | 1:N |
| facturas_encabezado | id_factura | 1:N |

Cada movimiento identifica el producto afectado y el usuario responsable.

Además, puede asociarse con una compra o una factura, según el origen de la operación.

Los campos `id_compra` e `id_factura` permiten mantener la trazabilidad de los movimientos automáticos.

Se incorpora una restricción que impide asociar simultáneamente una compra y una factura al mismo movimiento.

También se utilizan índices únicos parciales para impedir que un mismo producto genere movimientos duplicados dentro de una misma compra o factura.

### 5. Relaciones de pagos

#### 5.1. Facturas y pagos

**Relación:** `facturas_encabezado` → `pagos`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `pagos.id_factura`.

Una factura puede tener uno o varios registros de pago, mientras que cada pago corresponde a una única factura.

Esta relación permite registrar los pagos realizados y consultar cuánto se ha abonado a cada factura.

#### 5.2. Formas de pago y pagos

**Relación:** `formas_pago` → `pagos`

**Cardinalidad:** Uno a muchos (1:N).

**Llave foránea:** `pagos.id_forma_pago`.

Una forma de pago puede utilizarse en diferentes transacciones, mientras que cada registro de pago tiene asociada una única forma de pago.

Esta relación permite identificar los métodos utilizados para cancelar las facturas y elaborar reportes de cobros.

### 6. Resumen general de cardinalidades

| Entidad principal | Entidad relacionada | Cardinalidad |
|---|---|---|
| categorias | productos | 1:N |
| proveedores | productos | 1:N |
| roles | usuarios | 1:N |
| proveedores | compras_encabezado | 1:N |
| usuarios | compras_encabezado | 1:N |
| tipos_documento | compras_encabezado | 1:N |
| compras_encabezado | detalle_compra | 1:N |
| productos | detalle_compra | 1:N |
| clientes | facturas_encabezado | 1:N |
| usuarios | facturas_encabezado | 1:N |
| tipos_documento | facturas_encabezado | 1:N |
| facturas_encabezado | detalle_factura | 1:N |
| productos | detalle_factura | 1:N |
| productos | movimientos_inventario | 1:N |
| usuarios | movimientos_inventario | 1:N |
| compras_encabezado | movimientos_inventario | 1:N |
| facturas_encabezado | movimientos_inventario | 1:N |
| facturas_encabezado | pagos | 1:N |
| formas_pago | pagos | 1:N |

### 7. Integridad referencial

Las relaciones del modelo utilizan restricciones FOREIGN KEY para garantizar que los registros relacionados existan previamente en sus respectivas tablas.

En las relaciones principales se utiliza `ON UPDATE CASCADE` y `ON DELETE RESTRICT`, evitando eliminar registros principales que estén siendo utilizados por otras entidades y permitiendo mantener la integridad de la información.

Las relaciones de movimientos con compras y facturas utilizan sus respectivas llaves foráneas para conservar la referencia a los documentos de origen.

### 8. Conclusión

El diseño relacional permite representar las operaciones principales de un sistema de inventario y facturación mediante entidades independientes y relacionadas.

Las relaciones de uno a muchos permiten organizar la información de catálogos, usuarios, compras, facturas y pagos.

Las tablas `detalle_compra` y `detalle_factura` resuelven las relaciones de muchos a muchos entre documentos y productos, permitiendo registrar cantidades, precios y subtotales por cada línea.

Finalmente, la tabla `movimientos_inventario` proporciona trazabilidad de las modificaciones realizadas sobre las existencias, contribuyendo al control y seguimiento de las operaciones del sistema.