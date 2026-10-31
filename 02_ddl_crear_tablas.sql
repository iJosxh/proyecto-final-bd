-- ============================================================
-- ARCHIVO: 02_ddl_crear_tablas.sql
-- PROYECTO: Sistema de Inventario y Facturacion
-- FUENTE: respaldo PostgreSQL dump-inventario_bdii-202610311128.sql
-- MOTOR: PostgreSQL 15
--
-- EJECUTAR CONECTADO A inventario_bdii.
-- Este script crea las 14 tablas, identidades, restricciones,
-- indices unicos parciales y llaves foraneas del respaldo.
-- No inserta datos ni crea funciones, triggers o vistas.
-- ============================================================

SET search_path TO public;

-- ------------------------------------------------------------
-- 1. TABLAS DE CATALOGO Y SEGURIDAD
-- ------------------------------------------------------------

CREATE TABLE public.categorias (
    id_categoria INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_categoria VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(250)
);

CREATE TABLE public.proveedores (
    id_proveedor INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_empresa VARCHAR(150) NOT NULL,
    nit VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    correo_electronico VARCHAR(150) UNIQUE,
    direccion VARCHAR(250),
    contacto_principal VARCHAR(100)
);

CREATE TABLE public.clientes (
    id_cliente INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nit VARCHAR(20) NOT NULL UNIQUE,
    nombre_completo VARCHAR(150) NOT NULL,
    direccion VARCHAR(250),
    telefono VARCHAR(20),
    correo_electronico VARCHAR(150) UNIQUE
);

CREATE TABLE public.roles (
    id_rol INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

CREATE TABLE public.formas_pago (
    id_forma_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_forma_pago VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE public.tipos_documento (
    id_tipo_documento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_tipo_documento VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(200)
);

CREATE TABLE public.usuarios (
    id_usuario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_completo VARCHAR(150) NOT NULL,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    correo_electronico VARCHAR(150) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    id_rol INTEGER NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- ------------------------------------------------------------
-- 2. PRODUCTOS
-- ------------------------------------------------------------

CREATE TABLE public.productos (
    id_producto INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_barras VARCHAR(50) NOT NULL UNIQUE,
    nombre_producto VARCHAR(150) NOT NULL,
    descripcion VARCHAR(250),
    precio_compra NUMERIC(12,2) NOT NULL,
    precio_venta NUMERIC(12,2) NOT NULL,
    stock_actual INTEGER NOT NULL DEFAULT 0,
    stock_minimo INTEGER NOT NULL DEFAULT 0,
    id_categoria INTEGER NOT NULL,
    id_proveedor INTEGER NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_productos_precio_compra CHECK (precio_compra > 0),
    CONSTRAINT chk_productos_precio_venta CHECK (precio_venta > 0),
    CONSTRAINT chk_productos_stock CHECK (stock_actual >= 0),
    CONSTRAINT chk_productos_stock_minimo CHECK (stock_minimo >= 0)
);

-- ------------------------------------------------------------
-- 3. COMPRAS Y DETALLES
-- ------------------------------------------------------------

CREATE TABLE public.compras_encabezado (
    id_compra INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_compra VARCHAR(30) NOT NULL UNIQUE,
    fecha_compra TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_proveedor INTEGER NOT NULL,
    id_usuario INTEGER NOT NULL,
    id_tipo_documento INTEGER NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    total NUMERIC(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_compras_estado
        CHECK (estado IN ('PENDIENTE', 'RECIBIDA', 'ANULADA')),
    CONSTRAINT chk_compras_total CHECK (total >= 0)
);

CREATE TABLE public.detalle_compra (
    id_detalle_compra INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_compra INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(12,2) NOT NULL,
    subtotal NUMERIC(12,2)
        GENERATED ALWAYS AS (cantidad::NUMERIC * precio_unitario) STORED,
    CONSTRAINT chk_detalle_compra_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_compra_precio CHECK (precio_unitario > 0),
    CONSTRAINT uq_detalle_compra_producto UNIQUE (id_compra, id_producto)
);

-- ------------------------------------------------------------
-- 4. FACTURAS Y DETALLES
-- ------------------------------------------------------------

CREATE TABLE public.facturas_encabezado (
    id_factura INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    numero_factura VARCHAR(30) NOT NULL UNIQUE,
    fecha_emision TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente INTEGER NOT NULL,
    id_usuario INTEGER NOT NULL,
    id_tipo_documento INTEGER NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE',
    subtotal NUMERIC(12,2) NOT NULL DEFAULT 0,
    impuesto NUMERIC(12,2) NOT NULL DEFAULT 0,
    total NUMERIC(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT chk_facturas_estado
        CHECK (estado IN ('PENDIENTE', 'PAGADO', 'ANULADO')),
    CONSTRAINT chk_facturas_impuesto CHECK (impuesto >= 0),
    CONSTRAINT chk_facturas_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_facturas_total CHECK (total >= 0)
);

CREATE TABLE public.detalle_factura (
    id_detalle_factura INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(12,2) NOT NULL,
    subtotal NUMERIC(12,2)
        GENERATED ALWAYS AS (cantidad::NUMERIC * precio_unitario) STORED,
    CONSTRAINT chk_detalle_factura_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_factura_precio CHECK (precio_unitario > 0),
    CONSTRAINT uq_detalle_factura_producto UNIQUE (id_factura, id_producto)
);

-- ------------------------------------------------------------
-- 5. MOVIMIENTOS DE INVENTARIO Y PAGOS
-- ------------------------------------------------------------

CREATE TABLE public.movimientos_inventario (
    id_movimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_producto INTEGER NOT NULL,
    fecha_movimiento TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tipo_movimiento VARCHAR(20) NOT NULL,
    cantidad INTEGER NOT NULL,
    existencia_anterior INTEGER NOT NULL,
    existencia_nueva INTEGER NOT NULL,
    observacion VARCHAR(250),
    id_usuario INTEGER NOT NULL,
    id_compra INTEGER,
    id_factura INTEGER,
    CONSTRAINT chk_movimiento_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_movimiento_documento CHECK (id_compra IS NULL OR id_factura IS NULL),
    CONSTRAINT chk_movimiento_existencias
        CHECK (existencia_anterior >= 0 AND existencia_nueva >= 0),
    CONSTRAINT chk_movimiento_tipo
        CHECK (tipo_movimiento IN ('ENTRADA', 'SALIDA', 'AJUSTE'))
);

CREATE TABLE public.pagos (
    id_pago INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_factura INTEGER NOT NULL,
    id_forma_pago INTEGER NOT NULL,
    fecha_pago TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto NUMERIC(12,2) NOT NULL,
    referencia VARCHAR(100),
    estado VARCHAR(20) NOT NULL DEFAULT 'CONFIRMADO',
    CONSTRAINT chk_pagos_estado
        CHECK (estado IN ('PENDIENTE', 'CONFIRMADO', 'ANULADO')),
    CONSTRAINT chk_pagos_monto CHECK (monto > 0)
);

-- ------------------------------------------------------------
-- 6. LLAVES FORANEAS
-- ------------------------------------------------------------

ALTER TABLE public.usuarios
    ADD CONSTRAINT fk_usuarios_roles
    FOREIGN KEY (id_rol) REFERENCES public.roles(id_rol)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.productos
    ADD CONSTRAINT fk_productos_categorias
    FOREIGN KEY (id_categoria) REFERENCES public.categorias(id_categoria)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.productos
    ADD CONSTRAINT fk_productos_proveedores
    FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.compras_encabezado
    ADD CONSTRAINT fk_compras_proveedores
    FOREIGN KEY (id_proveedor) REFERENCES public.proveedores(id_proveedor)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.compras_encabezado
    ADD CONSTRAINT fk_compras_usuarios
    FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.compras_encabezado
    ADD CONSTRAINT fk_compras_tipos_documento
    FOREIGN KEY (id_tipo_documento) REFERENCES public.tipos_documento(id_tipo_documento)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.detalle_compra
    ADD CONSTRAINT fk_detalle_compra_encabezado
    FOREIGN KEY (id_compra) REFERENCES public.compras_encabezado(id_compra)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.detalle_compra
    ADD CONSTRAINT fk_detalle_compra_productos
    FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.facturas_encabezado
    ADD CONSTRAINT fk_facturas_clientes
    FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.facturas_encabezado
    ADD CONSTRAINT fk_facturas_tipos_documento
    FOREIGN KEY (id_tipo_documento) REFERENCES public.tipos_documento(id_tipo_documento)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.facturas_encabezado
    ADD CONSTRAINT fk_facturas_usuarios
    FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.detalle_factura
    ADD CONSTRAINT fk_detalle_factura_encabezado
    FOREIGN KEY (id_factura) REFERENCES public.facturas_encabezado(id_factura)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.detalle_factura
    ADD CONSTRAINT fk_detalle_factura_productos
    FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.movimientos_inventario
    ADD CONSTRAINT fk_movimientos_compra
    FOREIGN KEY (id_compra) REFERENCES public.compras_encabezado(id_compra);

ALTER TABLE public.movimientos_inventario
    ADD CONSTRAINT fk_movimientos_factura
    FOREIGN KEY (id_factura) REFERENCES public.facturas_encabezado(id_factura);

ALTER TABLE public.movimientos_inventario
    ADD CONSTRAINT fk_movimientos_productos
    FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.movimientos_inventario
    ADD CONSTRAINT fk_movimientos_usuarios
    FOREIGN KEY (id_usuario) REFERENCES public.usuarios(id_usuario)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.pagos
    ADD CONSTRAINT fk_pagos_facturas
    FOREIGN KEY (id_factura) REFERENCES public.facturas_encabezado(id_factura)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE public.pagos
    ADD CONSTRAINT fk_pagos_formas_pago
    FOREIGN KEY (id_forma_pago) REFERENCES public.formas_pago(id_forma_pago)
    ON UPDATE CASCADE ON DELETE RESTRICT;

-- ------------------------------------------------------------
-- 7. INDICES UNICOS PARCIALES PARA EVITAR DUPLICAR MOVIMIENTOS
-- ------------------------------------------------------------

CREATE UNIQUE INDEX uq_movimiento_compra_producto
    ON public.movimientos_inventario (id_compra, id_producto)
    WHERE id_compra IS NOT NULL;

CREATE UNIQUE INDEX uq_movimiento_factura_producto
    ON public.movimientos_inventario (id_factura, id_producto)
    WHERE id_factura IS NOT NULL;

-- Fin del DDL de tablas.
