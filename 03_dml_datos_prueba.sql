-- ============================================================
-- ARCHIVO: 03_dml_datos_prueba.sql
-- PROYECTO: Sistema de Inventario y Facturacion
-- FUENTE: datos existentes en el respaldo PostgreSQL del proyecto.
--
-- CARGA: datos originales + 2 clientes y 10 productos adicionales
-- para alcanzar los minimos del enunciado; 10 detalles adicionales
-- para alcanzar 30 lineas de detalle de factura.
--
-- IMPORTANTE:
-- - Ejecutar una sola vez sobre una base recien creada.
-- - Ejecutar despues de 02_ddl_crear_tablas.sql.
-- - No instalar aun los triggers de automatizacion de estado
--   (se crean en 05_extras_opcional.sql despues de esta carga).
-- - Los estados y existencias iniciales se conservan como en el dump.
-- ============================================================

BEGIN;

-- ============================================================
-- CATALOGOS Y ENTIDADES PRINCIPALES
-- ============================================================

-- Tabla: categorias
INSERT INTO public.categorias OVERRIDING SYSTEM VALUE VALUES (1, 'Herramientas manuales', 'Herramientas de uso manual');
INSERT INTO public.categorias OVERRIDING SYSTEM VALUE VALUES (2, 'Electricidad', 'Materiales y accesorios electricos');
INSERT INTO public.categorias OVERRIDING SYSTEM VALUE VALUES (3, 'Plomeria', 'Productos para instalaciones de agua');
INSERT INTO public.categorias OVERRIDING SYSTEM VALUE VALUES (4, 'Construccion', 'Materiales para construccion');
INSERT INTO public.categorias OVERRIDING SYSTEM VALUE VALUES (5, 'Pinturas', 'Pinturas y accesorios');
INSERT INTO public.categorias OVERRIDING SYSTEM VALUE VALUES (6, 'Tornilleria', 'Tornillos, tuercas y arandelas');

-- Tabla: proveedores
INSERT INTO public.proveedores OVERRIDING SYSTEM VALUE VALUES (1, 'Distribuidora Central', '1234567-1', '55510001', 'ventas@central.com', 'Ciudad de Guatemala', 'Carlos Perez');
INSERT INTO public.proveedores OVERRIDING SYSTEM VALUE VALUES (2, 'Ferreteria Industrial', '1234567-2', '55510002', 'ventas@industrial.com', 'Zona 1', 'Maria Lopez');
INSERT INTO public.proveedores OVERRIDING SYSTEM VALUE VALUES (3, 'Suministros del Norte', '1234567-3', '55510003', 'ventas@norte.com', 'Zona 6', 'Jose Ramirez');
INSERT INTO public.proveedores OVERRIDING SYSTEM VALUE VALUES (4, 'Materiales Guatemala', '1234567-4', '55510004', 'ventas@materiales.com', 'Zona 7', 'Ana Morales');
INSERT INTO public.proveedores OVERRIDING SYSTEM VALUE VALUES (5, 'Comercial El Constructor', '1234567-5', '55510005', 'ventas@constructor.com', 'Zona 11', 'Luis Garcia');
INSERT INTO public.proveedores OVERRIDING SYSTEM VALUE VALUES (6, 'Importadora Tecnica', '1234567-6', '55510006', 'ventas@tecnica.com', 'Zona 12', 'Sofia Castillo');

-- Tabla: clientes
INSERT INTO public.clientes OVERRIDING SYSTEM VALUE VALUES (1, 'CF', 'Consumidor Final', 'Ciudad de Guatemala', '55520001', 'consumidor@example.com');
INSERT INTO public.clientes OVERRIDING SYSTEM VALUE VALUES (2, '2345678-1', 'Juan Perez', 'Zona 1', '55520002', 'juan@example.com');
INSERT INTO public.clientes OVERRIDING SYSTEM VALUE VALUES (3, '2345678-2', 'Maria Gonzalez', 'Zona 2', '55520003', 'maria@example.com');
INSERT INTO public.clientes OVERRIDING SYSTEM VALUE VALUES (4, '2345678-3', 'Carlos Ramirez', 'Zona 3', '55520004', 'carlos@example.com');
INSERT INTO public.clientes OVERRIDING SYSTEM VALUE VALUES (5, '2345678-4', 'Ana Lopez', 'Zona 4', '55520005', 'ana@example.com');
INSERT INTO public.clientes OVERRIDING SYSTEM VALUE VALUES (6, '2345678-5', 'Pedro Morales', 'Zona 5', '55520006', 'pedro@example.com');
INSERT INTO public.clientes OVERRIDING SYSTEM VALUE VALUES (7, '2345678-6', 'Sofia Castillo', 'Zona 6', '55520007', 'sofia@example.com');
INSERT INTO public.clientes OVERRIDING SYSTEM VALUE VALUES (8, '2345678-7', 'Luis Hernandez', 'Zona 7', '55520008', 'luis@example.com');

-- Registros adicionales para cumplir el minimo de 10 clientes.
INSERT INTO public.clientes (id_cliente, nit, nombre_completo, direccion, telefono, correo_electronico)
OVERRIDING SYSTEM VALUE VALUES
(9, '2345678-8', 'Elena Fuentes', 'Zona 8', '55520009', 'elena@example.com'),
(10, '2345678-9', 'Roberto Diaz', 'Zona 10', '55520010', 'roberto@example.com');

-- Tabla: roles
INSERT INTO public.roles OVERRIDING SYSTEM VALUE VALUES (1, 'ADMINISTRADOR', 'Control total del sistema');
INSERT INTO public.roles OVERRIDING SYSTEM VALUE VALUES (2, 'VENDEDOR', 'Registro de ventas y facturas');
INSERT INTO public.roles OVERRIDING SYSTEM VALUE VALUES (3, 'BODEGUERO', 'Control de existencias');
INSERT INTO public.roles OVERRIDING SYSTEM VALUE VALUES (4, 'COMPRAS', 'Gestion de compras');
INSERT INTO public.roles OVERRIDING SYSTEM VALUE VALUES (5, 'SUPERVISOR', 'Supervision de operaciones');

-- Tabla: formas_pago
INSERT INTO public.formas_pago OVERRIDING SYSTEM VALUE VALUES (1, 'EFECTIVO', 'Pago en efectivo', true);
INSERT INTO public.formas_pago OVERRIDING SYSTEM VALUE VALUES (2, 'TARJETA', 'Pago con tarjeta', true);
INSERT INTO public.formas_pago OVERRIDING SYSTEM VALUE VALUES (3, 'TRANSFERENCIA', 'Transferencia bancaria', true);
INSERT INTO public.formas_pago OVERRIDING SYSTEM VALUE VALUES (4, 'DEPOSITO', 'Deposito bancario', true);
INSERT INTO public.formas_pago OVERRIDING SYSTEM VALUE VALUES (5, 'CHEQUE', 'Pago mediante cheque', true);

-- Tabla: tipos_documento
INSERT INTO public.tipos_documento OVERRIDING SYSTEM VALUE VALUES (1, 'FACTURA', 'Documento de venta');
INSERT INTO public.tipos_documento OVERRIDING SYSTEM VALUE VALUES (2, 'FACTURA CAMBIARIA', 'Documento de venta cambiario');
INSERT INTO public.tipos_documento OVERRIDING SYSTEM VALUE VALUES (3, 'RECIBO', 'Comprobante de pago');
INSERT INTO public.tipos_documento OVERRIDING SYSTEM VALUE VALUES (4, 'NOTA DE CREDITO', 'Documento para ajustes o anulaciones');
INSERT INTO public.tipos_documento OVERRIDING SYSTEM VALUE VALUES (5, 'FACTURA DE COMPRA', 'Documento de compra a proveedor');

-- Tabla: usuarios
INSERT INTO public.usuarios OVERRIDING SYSTEM VALUE VALUES (1, 'Administrador General', 'admin', 'admin@inventario.com', 'HASH_DE_PRUEBA_ADMIN', 1, true);
INSERT INTO public.usuarios OVERRIDING SYSTEM VALUE VALUES (2, 'Vendedor Uno', 'vendedor1', 'vendedor1@inventario.com', 'HASH_DE_PRUEBA_V1', 2, true);
INSERT INTO public.usuarios OVERRIDING SYSTEM VALUE VALUES (3, 'Vendedor Dos', 'vendedor2', 'vendedor2@inventario.com', 'HASH_DE_PRUEBA_V2', 2, true);
INSERT INTO public.usuarios OVERRIDING SYSTEM VALUE VALUES (4, 'Encargado de Bodega', 'bodega1', 'bodega@inventario.com', 'HASH_DE_PRUEBA_B1', 3, true);
INSERT INTO public.usuarios OVERRIDING SYSTEM VALUE VALUES (5, 'Encargado de Compras', 'compras1', 'compras@inventario.com', 'HASH_DE_PRUEBA_C1', 4, true);

-- Tabla: productos
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (1, '750100000001', 'Martillo de acero', 'Martillo de uso general', 35.00, 55.00, 30, 10, 1, 1, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (2, '750100000002', 'Destornillador plano', 'Destornillador de punta plana', 12.00, 22.00, 25, 8, 1, 2, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (3, '750100000003', 'Destornillador Phillips', 'Destornillador de cruz', 14.00, 25.00, 18, 8, 1, 2, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (4, '750100000004', 'Alicate universal', 'Alicate para trabajos generales', 28.00, 45.00, 15, 5, 1, 3, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (5, '750100000005', 'Llave inglesa', 'Llave ajustable de acero', 40.00, 65.00, 12, 5, 1, 3, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (6, '750100000006', 'Cable electrico 12 AWG', 'Cable electrico por metro', 4.50, 7.00, 100, 25, 2, 4, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (7, '750100000007', 'Interruptor sencillo', 'Interruptor electrico de pared', 8.00, 15.00, 20, 8, 2, 4, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (8, '750100000008', 'Tomacorriente doble', 'Tomacorriente para interiores', 10.00, 18.00, 16, 5, 2, 5, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (9, '750100000009', 'Bombilla LED', 'Bombilla LED de bajo consumo', 15.00, 25.00, 4, 10, 2, 5, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (10, '750100000010', 'Tubo PVC 1/2 pulgada', 'Tubo PVC para agua', 18.00, 30.00, 35, 10, 3, 1, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (11, '750100000011', 'Codo PVC 1/2 pulgada', 'Accesorio para tuberia PVC', 2.50, 5.00, 50, 15, 3, 1, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (12, '750100000012', 'Valvula de paso', 'Valvula para instalaciones de agua', 25.00, 42.00, 3, 8, 3, 2, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (13, '750100000013', 'Grifo metalico', 'Grifo para lavamanos', 45.00, 75.00, 10, 4, 3, 6, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (14, '750100000014', 'Cemento gris', 'Bolsa de cemento', 65.00, 85.00, 40, 15, 4, 4, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (15, '750100000015', 'Arena de construccion', 'Saco de arena', 20.00, 32.00, 25, 10, 4, 5, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (16, '750100000016', 'Brocha de 3 pulgadas', 'Brocha para pintar', 10.00, 18.00, 18, 5, 5, 3, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (17, '750100000017', 'Pintura blanca', 'Galon de pintura blanca', 90.00, 130.00, 12, 5, 5, 6, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (18, '750100000018', 'Tornillo para madera', 'Tornillo para madera por unidad', 0.50, 1.00, 200, 50, 6, 2, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (19, '750100000019', 'Tuerca hexagonal', 'Tuerca metalica', 0.75, 1.50, 150, 40, 6, 3, true);
INSERT INTO public.productos OVERRIDING SYSTEM VALUE VALUES (20, '750100000020', 'Arandela metalica', 'Arandela de acero', 0.25, 0.75, 2, 20, 6, 5, true);

-- Productos adicionales para cumplir el minimo de 30 productos.
-- Se reutilizan categorias y proveedores ya existentes.
INSERT INTO public.productos
(id_producto, codigo_barras, nombre_producto, descripcion, precio_compra, precio_venta,
 stock_actual, stock_minimo, id_categoria, id_proveedor, activo)
OVERRIDING SYSTEM VALUE VALUES
(21, '750100000021', 'Llave Allen', 'Juego de llaves Allen', 18.00, 28.00, 24, 8, 1, 1, TRUE),
(22, '750100000022', 'Cinta aislante', 'Cinta aislante electrica', 3.50, 6.00, 40, 15, 2, 4, TRUE),
(23, '750100000023', 'Portalámpara', 'Portalámpara para bombilla', 5.00, 9.00, 18, 6, 2, 5, TRUE),
(24, '750100000024', 'Adaptador PVC', 'Adaptador para tuberia PVC', 2.00, 4.00, 30, 10, 3, 1, TRUE),
(25, '750100000025', 'Cinta teflon', 'Cinta selladora para tuberias', 2.50, 5.00, 22, 8, 3, 2, TRUE),
(26, '750100000026', 'Lija para madera', 'Hoja de lija para madera', 1.50, 3.00, 35, 12, 5, 3, TRUE),
(27, '750100000027', 'Rodillo para pintar', 'Rodillo para aplicacion de pintura', 12.00, 20.00, 14, 5, 5, 6, TRUE),
(28, '750100000028', 'Clavo de acero', 'Clavo de acero por unidad', 0.20, 0.50, 300, 80, 6, 2, TRUE),
(29, '750100000029', 'Perno hexagonal', 'Perno metalico hexagonal', 1.20, 2.00, 90, 30, 6, 3, TRUE),
(30, '750100000030', 'Guantes de trabajo', 'Guantes para proteccion laboral', 8.00, 14.00, 16, 6, 1, 5, TRUE);

-- ============================================================
-- TRANSACCIONES
-- ============================================================

-- Tabla: compras_encabezado
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (1, 'COMP-001', '2026-10-14 16:50:04.86799', 1, 1, 5, 'RECIBIDA', 590.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (2, 'COMP-002', '2026-10-15 16:50:04.86799', 2, 5, 5, 'RECIBIDA', 490.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (3, 'COMP-003', '2026-10-16 16:50:04.86799', 3, 5, 5, 'RECIBIDA', 545.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (4, 'COMP-004', '2026-10-17 16:50:04.86799', 4, 5, 5, 'RECIBIDA', 310.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (5, 'COMP-005', '2026-10-18 16:50:04.86799', 5, 5, 5, 'RECIBIDA', 735.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (6, 'COMP-006', '2026-10-19 16:50:04.86799', 6, 5, 5, 'RECIBIDA', 400.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (7, 'COMP-007', '2026-10-20 16:50:04.86799', 1, 5, 5, 'RECIBIDA', 1425.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (8, 'COMP-008', '2026-10-21 16:50:04.86799', 2, 5, 5, 'RECIBIDA', 800.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (9, 'COMP-009', '2026-10-22 16:50:04.86799', 3, 5, 5, 'RECIBIDA', 1130.00);
INSERT INTO public.compras_encabezado OVERRIDING SYSTEM VALUE VALUES (10, 'COMP-010', '2026-10-23 16:50:04.86799', 4, 5, 5, 'RECIBIDA', 85.00);

-- Tabla: detalle_compra
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (1, 1, 1, 10, 35.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (2, 1, 2, 20, 12.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (3, 2, 3, 15, 14.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (4, 2, 4, 10, 28.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (5, 3, 5, 8, 40.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (6, 3, 6, 50, 4.50, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (7, 4, 7, 20, 8.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (8, 4, 8, 15, 10.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (9, 5, 9, 25, 15.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (10, 5, 10, 20, 18.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (11, 6, 11, 40, 2.50, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (12, 6, 12, 12, 25.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (13, 7, 13, 10, 45.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (14, 7, 14, 15, 65.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (15, 8, 15, 30, 20.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (16, 8, 16, 20, 10.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (17, 9, 17, 12, 90.00, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (18, 9, 18, 100, 0.50, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (19, 10, 19, 80, 0.75, DEFAULT);
INSERT INTO public.detalle_compra OVERRIDING SYSTEM VALUE VALUES (20, 10, 20, 100, 0.25, DEFAULT);

-- Tabla: facturas_encabezado
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (1, 'FAC-001', '2026-10-15 16:51:42.756202', 2, 2, 1, 'PENDIENTE', 176.00, 21.12, 197.12);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (2, 'FAC-002', '2026-10-16 16:51:42.756202', 3, 2, 1, 'PENDIENTE', 95.00, 11.40, 106.40);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (3, 'FAC-003', '2026-10-17 16:51:42.756202', 4, 3, 1, 'PENDIENTE', 135.00, 16.20, 151.20);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (4, 'FAC-004', '2026-10-18 16:51:42.756202', 5, 2, 1, 'PENDIENTE', 66.00, 7.92, 73.92);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (5, 'FAC-005', '2026-10-19 16:51:42.756202', 6, 3, 1, 'PENDIENTE', 140.00, 16.80, 156.80);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (6, 'FAC-006', '2026-10-20 16:51:42.756202', 7, 2, 1, 'PENDIENTE', 92.00, 11.04, 103.04);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (7, 'FAC-007', '2026-10-21 16:51:42.756202', 8, 3, 1, 'PENDIENTE', 245.00, 29.40, 274.40);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (8, 'FAC-008', '2026-10-22 16:51:42.756202', 2, 2, 1, 'PENDIENTE', 118.00, 14.16, 132.16);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (9, 'FAC-009', '2026-10-23 16:51:42.756202', 3, 3, 1, 'PENDIENTE', 150.00, 18.00, 168.00);
INSERT INTO public.facturas_encabezado OVERRIDING SYSTEM VALUE VALUES (10, 'FAC-010', '2026-10-24 16:51:42.756202', 4, 2, 1, 'PENDIENTE', 16.50, 1.98, 18.48);

-- Tabla: detalle_factura
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (1, 1, 1, 2, 55.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (2, 1, 2, 3, 22.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (3, 2, 3, 2, 25.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (4, 2, 4, 1, 45.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (5, 3, 5, 1, 65.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (6, 3, 6, 10, 7.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (7, 4, 7, 2, 15.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (8, 4, 8, 2, 18.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (9, 5, 9, 2, 25.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (10, 5, 10, 3, 30.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (11, 6, 11, 10, 5.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (12, 6, 12, 1, 42.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (13, 7, 13, 1, 75.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (14, 7, 14, 2, 85.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (15, 8, 15, 2, 32.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (16, 8, 16, 3, 18.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (17, 9, 17, 1, 130.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (18, 9, 18, 20, 1.00, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (19, 10, 19, 10, 1.50, DEFAULT);
INSERT INTO public.detalle_factura OVERRIDING SYSTEM VALUE VALUES (20, 10, 20, 2, 0.75, DEFAULT);

-- Diez lineas adicionales para alcanzar 30 detalles de factura.
-- Se agrega un producto diferente a cada una de las diez facturas.
INSERT INTO public.detalle_factura
(id_detalle_factura, id_factura, id_producto, cantidad, precio_unitario)
OVERRIDING SYSTEM VALUE VALUES
(21, 1, 21, 1, 28.00),
(22, 2, 22, 2, 6.00),
(23, 3, 23, 1, 9.00),
(24, 4, 24, 3, 4.00),
(25, 5, 25, 2, 5.00),
(26, 6, 26, 4, 3.00),
(27, 7, 27, 1, 20.00),
(28, 8, 28, 10, 0.50),
(29, 9, 29, 5, 2.00),
(30, 10, 30, 2, 14.00);

-- Recalcular encabezados para incluir las lineas adicionales.
UPDATE public.facturas_encabezado AS f
SET subtotal = d.subtotal,
    impuesto = ROUND(d.subtotal * 0.12, 2),
    total = d.subtotal + ROUND(d.subtotal * 0.12, 2)
FROM (
    SELECT id_factura, SUM(subtotal) AS subtotal
    FROM public.detalle_factura
    GROUP BY id_factura
) AS d
WHERE d.id_factura = f.id_factura;

-- Tabla: pagos
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (1, 1, 1, '2026-10-15 16:55:40.143237', 176.00, 'PAGO-001', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (2, 2, 2, '2026-10-16 16:55:40.143237', 95.00, 'PAGO-002', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (3, 3, 3, '2026-10-17 16:55:40.143237', 135.00, 'PAGO-003', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (4, 4, 1, '2026-10-18 16:55:40.143237', 66.00, 'PAGO-004', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (5, 5, 4, '2026-10-19 16:55:40.143237', 140.00, 'PAGO-005', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (6, 6, 5, '2026-10-20 16:55:40.143237', 92.00, 'PAGO-006', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (7, 7, 1, '2026-10-21 16:55:40.143237', 245.00, 'PAGO-007', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (8, 8, 2, '2026-10-22 16:55:40.143237', 118.00, 'PAGO-008', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (9, 9, 3, '2026-10-23 16:55:40.143237', 150.00, 'PAGO-009', 'CONFIRMADO');
INSERT INTO public.pagos OVERRIDING SYSTEM VALUE VALUES (10, 10, 1, '2026-10-24 16:55:40.143237', 16.50, 'PAGO-010', 'CONFIRMADO');


-- Sincronizar secuencias identity con los identificadores insertados.
SELECT setval(pg_get_serial_sequence('public.categorias','id_categoria'), (SELECT MAX(id_categoria) FROM public.categorias), TRUE);
SELECT setval(pg_get_serial_sequence('public.proveedores','id_proveedor'), (SELECT MAX(id_proveedor) FROM public.proveedores), TRUE);
SELECT setval(pg_get_serial_sequence('public.clientes','id_cliente'), (SELECT MAX(id_cliente) FROM public.clientes), TRUE);
SELECT setval(pg_get_serial_sequence('public.roles','id_rol'), (SELECT MAX(id_rol) FROM public.roles), TRUE);
SELECT setval(pg_get_serial_sequence('public.formas_pago','id_forma_pago'), (SELECT MAX(id_forma_pago) FROM public.formas_pago), TRUE);
SELECT setval(pg_get_serial_sequence('public.tipos_documento','id_tipo_documento'), (SELECT MAX(id_tipo_documento) FROM public.tipos_documento), TRUE);
SELECT setval(pg_get_serial_sequence('public.usuarios','id_usuario'), (SELECT MAX(id_usuario) FROM public.usuarios), TRUE);
SELECT setval(pg_get_serial_sequence('public.productos','id_producto'), (SELECT MAX(id_producto) FROM public.productos), TRUE);
SELECT setval(pg_get_serial_sequence('public.compras_encabezado','id_compra'), (SELECT MAX(id_compra) FROM public.compras_encabezado), TRUE);
SELECT setval(pg_get_serial_sequence('public.detalle_compra','id_detalle_compra'), (SELECT MAX(id_detalle_compra) FROM public.detalle_compra), TRUE);
SELECT setval(pg_get_serial_sequence('public.facturas_encabezado','id_factura'), (SELECT MAX(id_factura) FROM public.facturas_encabezado), TRUE);
SELECT setval(pg_get_serial_sequence('public.detalle_factura','id_detalle_factura'), (SELECT MAX(id_detalle_factura) FROM public.detalle_factura), TRUE);
SELECT setval(pg_get_serial_sequence('public.pagos','id_pago'), (SELECT MAX(id_pago) FROM public.pagos), TRUE);

COMMIT;

-- Verificacion rapida de volumenes minimos solicitados.
SELECT 'categorias' AS tabla, COUNT(*) AS registros FROM public.categorias
UNION ALL SELECT 'proveedores', COUNT(*) FROM public.proveedores
UNION ALL SELECT 'clientes', COUNT(*) FROM public.clientes
UNION ALL SELECT 'productos', COUNT(*) FROM public.productos
UNION ALL SELECT 'facturas_encabezado', COUNT(*) FROM public.facturas_encabezado
UNION ALL SELECT 'detalle_factura', COUNT(*) FROM public.detalle_factura
ORDER BY tabla;
