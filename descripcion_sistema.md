# 01. Descripción del sistema
## Sistema de Inventario y Facturación

### 1. Información general

| Elemento | Descripción |
|---|---|
| Nombre del proyecto | Sistema de Inventario y Facturación |
| Curso | Base de Datos I |
| Tipo de proyecto | Proyecto de base de datos relacional |
| Motor de base de datos | PostgreSQL |
| Cliente de administración | DBeaver |
| Lenguaje de consultas | SQL |
| Lenguaje de programación de funciones | PL/pgSQL |

### 2. Descripción del proyecto

El Sistema de Inventario y Facturación es una solución orientada a la administración y control de las operaciones de un negocio comercial dedicado a la compra y venta de productos.

El sistema permite organizar la información de productos, categorías, proveedores, clientes y usuarios, así como registrar las operaciones de compra, facturación y pagos.

También incorpora mecanismos para controlar las existencias mediante el registro de movimientos de inventario, permitiendo identificar las entradas, salidas y ajustes realizados sobre los productos.

La base de datos fue desarrollada en PostgreSQL utilizando un modelo relacional compuesto por 14 tablas, relacionadas mediante llaves primarias y foráneas, restricciones de integridad, funciones, disparadores y vistas.

### 3. Objetivo general

Diseñar e implementar una base de datos relacional para administrar las operaciones de inventario y facturación de un negocio comercial, garantizando la integridad de la información y facilitando el control de las existencias, las compras, las ventas y los pagos.

### 4. Objetivos específicos

- Organizar la información de productos, categorías, proveedores y clientes.
- Registrar las compras realizadas a los proveedores y sus respectivos detalles.
- Administrar las facturas emitidas a los clientes.
- Registrar los pagos asociados a las facturas.
- Controlar las existencias disponibles de los productos.
- Registrar los movimientos de entrada, salida y ajuste de inventario.
- Implementar validaciones para evitar operaciones que generen existencias negativas.
- Automatizar el cálculo de subtotales y totales de compras y facturas.
- Facilitar la consulta de información mediante vistas y consultas SQL.

### 5. Alcance del sistema

El proyecto comprende el diseño e implementación de la estructura de una base de datos para administrar los principales procesos de inventario y facturación.

Su alcance incluye los siguientes módulos:

#### 5.1. Administración de catálogos

Permite organizar la información utilizada en las operaciones del sistema.

Incluye:

- Categorías de productos.
- Proveedores.
- Clientes.
- Roles de usuarios.
- Formas de pago.
- Tipos de documentos.
- Usuarios del sistema.

#### 5.2. Administración de productos

Permite almacenar la información de los productos comercializados, incluyendo:

- Código de identificación.
- Nombre y descripción.
- Precio de compra.
- Precio de venta.
- Existencia actual.
- Existencia mínima.
- Categoría.
- Proveedor asociado.

También permite identificar productos que necesitan reposición mediante la comparación entre las existencias actuales y el stock mínimo configurado.

#### 5.3. Gestión de compras

Permite registrar las adquisiciones realizadas a los proveedores mediante un encabezado y sus respectivos detalles.

El encabezado almacena los datos generales de la compra, mientras que el detalle registra los productos, cantidades y precios unitarios.

El sistema calcula automáticamente los subtotales y actualiza el total de la compra mediante funciones y disparadores.

Cuando una compra pasa al estado `RECIBIDA`, se ejecuta el proceso automatizado de ingreso de existencias y registro del movimiento correspondiente.

#### 5.4. Gestión de facturación

Permite registrar las facturas emitidas a los clientes.

Cada factura contiene información general del cliente, usuario responsable, fecha de emisión, tipo de documento, subtotal, impuesto y total.

Los productos vendidos se almacenan en la tabla `detalle_factura`, donde se registra la cantidad, el precio unitario y el subtotal de cada línea.

El sistema utiliza funciones y disparadores para recalcular los importes de las facturas cuando se modifican sus detalles.

Cuando una factura cambia al estado `PAGADO`, se ejecuta el proceso automatizado de salida de inventario.

#### 5.5. Control de inventario

Permite mantener un historial de las modificaciones realizadas sobre las existencias de los productos.

Se contemplan tres tipos de movimientos:

- **ENTRADA:** incrementa las existencias disponibles.
- **SALIDA:** disminuye las existencias disponibles.
- **AJUSTE:** establece una nueva existencia para corregir diferencias en el inventario.

La función `registrar_movimiento_inventario` realiza las validaciones correspondientes, actualiza el stock y registra la información del movimiento.

Entre las validaciones implementadas se encuentra la prevención de salidas que superen las existencias disponibles.

#### 5.6. Gestión de pagos

Permite registrar los pagos asociados a las facturas, identificando la forma de pago, fecha, monto, referencia y estado de cada operación.

Esta información facilita el seguimiento de los cobros realizados y la elaboración de reportes financieros.

#### 5.7. Reportes y consultas

El sistema incorpora vistas para facilitar la consulta de información y el seguimiento de las operaciones.

Las vistas desarrolladas son:

| Vista | Funcionalidad |
|---|---|
| vista_estado_inventario | Muestra las existencias y el estado de los productos. |
| vista_movimientos_inventario | Presenta el historial de movimientos de inventario. |
| vista_productos_stock_bajo | Identifica productos que requieren reposición. |
| vista_reporte_compras | Presenta información general de las compras. |
| vista_reporte_facturacion | Presenta información general de las facturas. |
| vista_resumen_sistema | Muestra indicadores generales del sistema. |

### 6. Reglas de negocio principales

El funcionamiento de la base de datos contempla las siguientes reglas:

1. Cada producto debe estar asociado a una categoría y a un proveedor.
2. Cada compra debe identificar al proveedor y al usuario responsable.
3. Cada factura debe estar asociada a un cliente y a un usuario responsable.
4. Los detalles de compra y facturación deben identificar los productos correspondientes.
5. Las cantidades y precios unitarios deben cumplir las restricciones definidas en la base de datos.
6. Las existencias de los productos no pueden ser negativas.
7. Los estados de compras, facturas y pagos deben pertenecer a los valores permitidos.
8. Los movimientos de inventario deben registrar el producto, la cantidad, las existencias anteriores y nuevas, y el usuario responsable.
9. Una salida de inventario no puede superar las existencias disponibles.
10. Los pagos deben