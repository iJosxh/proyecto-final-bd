-- ============================================================
-- PROYECTO: SISTEMA DE INVENTARIO Y FACTURACION
-- BASE DE DATOS: inventario_bdii
-- MOTOR: POSTGRESQL 18
-- ARCHIVO: 09_transacciones_completas.sql
--
-- 6 COMPRAS RECIBIDAS
-- 6 FACTURAS PAGADAS
-- 12 DETALLES DE COMPRA
-- 12 DETALLES DE FACTURA
-- 6 PAGOS CONFIRMADOS
--
-- UTILIZA LOS TRIGGERS EXISTENTES.
-- NO CREA NI ELIMINA TABLAS.
-- ============================================================

BEGIN;

DO $fase2$

DECLARE
    i INTEGER;

    v_id_compra INTEGER;
    v_id_factura INTEGER;

    v_id_proveedor INTEGER;
    v_id_cliente INTEGER;
    v_id_usuario INTEGER := 2;
    v_id_tipo_documento INTEGER;
    v_id_forma_pago INTEGER;

    v_producto1 INTEGER;
    v_producto2 INTEGER;

    v_costo1 NUMERIC(12,2);
    v_costo2 NUMERIC(12,2);

    v_precio1 NUMERIC(12,2);
    v_precio2 NUMERIC(12,2);

    v_total NUMERIC(12,2);

    v_compras INTEGER := 0;
    v_ventas INTEGER := 0;

BEGIN

    -- ========================================================
    -- VALIDACIONES INICIALES
    -- ========================================================

    SELECT MIN(id_tipo_documento)
    INTO v_id_tipo_documento
    FROM public.tipos_documento;

    SELECT MIN(id_forma_pago)
    INTO v_id_forma_pago
    FROM public.formas_pago;

    IF v_id_tipo_documento IS NULL THEN
        RAISE EXCEPTION 'No existen tipos de documento registrados';
    END IF;

    IF v_id_forma_pago IS NULL THEN
        RAISE EXCEPTION 'No existen formas de pago registradas';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM public.usuarios
        WHERE id_usuario = v_id_usuario
    ) THEN
        RAISE EXCEPTION 'No existe el usuario %', v_id_usuario;
    END IF;


    -- ========================================================
    -- 1. GENERAR 6 COMPRAS
    -- ========================================================

    FOR i IN 1..6 LOOP

        IF EXISTS (
            SELECT 1
            FROM public.compras_encabezado
            WHERE numero_compra =
                'COMP-F2-' || LPAD(i::TEXT, 3, '0')
        ) THEN
            CONTINUE;
        END IF;

        v_producto1 := i;
        v_producto2 := i + 1;

        -- Obtener proveedor y costos
        SELECT id_proveedor, precio_compra
        INTO v_id_proveedor, v_costo1
        FROM public.productos
        WHERE id_producto = v_producto1;

        SELECT precio_compra
        INTO v_costo2
        FROM public.productos
        WHERE id_producto = v_producto2;

        IF v_id_proveedor IS NULL
           OR v_costo1 IS NULL
           OR v_costo2 IS NULL THEN

            RAISE EXCEPTION
                'Faltan productos o precios para la compra %', i;

        END IF;

        -- Crear encabezado de compra
        INSERT INTO public.compras_encabezado (
            numero_compra,
            fecha_compra,
            id_proveedor,
            id_usuario,
            id_tipo_documento,
            estado,
            total
        )
        VALUES (
            'COMP-F2-' || LPAD(i::TEXT, 3, '0'),
            CURRENT_DATE,
            v_id_proveedor,
            v_id_usuario,
            v_id_tipo_documento,
            'PENDIENTE',
            0
        )
        RETURNING id_compra INTO v_id_compra;

        -- Insertar dos productos
        INSERT INTO public.detalle_compra (
            id_compra,
            id_producto,
            cantidad,
            precio_unitario
        )
        VALUES
            (v_id_compra, v_producto1, 10, v_costo1),
            (v_id_compra, v_producto2, 8, v_costo2);

        -- Activar trigger de compra recibida
        UPDATE public.compras_encabezado
        SET estado = 'RECIBIDA'
        WHERE id_compra = v_id_compra;

        v_compras := v_compras + 1;

    END LOOP;


    -- ========================================================
    -- 2. GENERAR 6 FACTURAS
    -- ========================================================

    FOR i IN 1..6 LOOP

        IF EXISTS (
            SELECT 1
            FROM public.facturas_encabezado
            WHERE numero_factura =
                'FAC-F2-' || LPAD(i::TEXT, 3, '0')
        ) THEN
            CONTINUE;
        END IF;

        v_producto1 := i;
        v_producto2 := i + 1;
        v_id_cliente := i;

        -- Validar cliente
        IF NOT EXISTS (
            SELECT 1
            FROM public.clientes
            WHERE id_cliente = v_id_cliente
        ) THEN
            RAISE EXCEPTION
                'No existe el cliente %', v_id_cliente;
        END IF;

        -- Obtener precios de venta
        SELECT precio_venta
        INTO v_precio1
        FROM public.productos
        WHERE id_producto = v_producto1;

        SELECT precio_venta
        INTO v_precio2
        FROM public.productos
        WHERE id_producto = v_producto2;

        IF v_precio1 IS NULL OR v_precio2 IS NULL THEN
            RAISE EXCEPTION
                'No existen precios de venta para la factura %', i;
        END IF;

        -- Crear encabezado de factura
        INSERT INTO public.facturas_encabezado (
            numero_factura,
            fecha_emision,
            id_cliente,
            id_usuario,
            id_tipo_documento,
            estado,
            subtotal,
            impuesto,
            total
        )
        VALUES (
            'FAC-F2-' || LPAD(i::TEXT, 3, '0'),
            CURRENT_DATE,
            v_id_cliente,
            v_id_usuario,
            v_id_tipo_documento,
            'PENDIENTE',
            0,
            0,
            0
        )
        RETURNING id_factura INTO v_id_factura;

        -- Insertar dos productos
        INSERT INTO public.detalle_factura (
            id_factura,
            id_producto,
            cantidad,
            precio_unitario
        )
        VALUES
            (v_id_factura, v_producto1, 2, v_precio1),
            (v_id_factura, v_producto2, 1, v_precio2);

        -- Obtener total actualizado por el trigger
        SELECT total
        INTO v_total
        FROM public.facturas_encabezado
        WHERE id_factura = v_id_factura;

        -- Registrar pago completo
        INSERT INTO public.pagos (
            id_factura,
            id_forma_pago,
            fecha_pago,
            monto,
            referencia,
            estado
        )
        VALUES (
            v_id_factura,
            v_id_forma_pago,
            CURRENT_DATE,
            v_total,
            'PAGO-F2-' || LPAD(i::TEXT, 3, '0'),
            'CONFIRMADO'
        );

        -- Activar trigger de factura pagada
        UPDATE public.facturas_encabezado
        SET estado = 'PAGADO'
        WHERE id_factura = v_id_factura;

        v_ventas := v_ventas + 1;

    END LOOP;


    -- ========================================================
    -- 3. RESULTADO DE LAS OPERACIONES
    -- ========================================================

    RAISE NOTICE 'Compras nuevas: %', v_compras;
    RAISE NOTICE 'Ventas nuevas: %', v_ventas;
    RAISE NOTICE 'Total de transacciones nuevas: %',
        v_compras + v_ventas;

END;
$fase2$;

COMMIT;


-- ============================================================
-- 4. REPORTE DE LAS 12 TRANSACCIONES
-- ============================================================

SELECT
    'COMPRA' AS operacion,
    numero_compra AS documento,
    estado,
    total
FROM public.compras_encabezado
WHERE numero_compra LIKE 'COMP-F2-%'

UNION ALL

SELECT
    'VENTA',
    numero_factura,
    estado,
    total
FROM public.facturas_encabezado
WHERE numero_factura LIKE 'FAC-F2-%'

ORDER BY operacion, documento;


-- ============================================================
-- 5. REPORTE DE PAGOS Y SALDOS
-- ============================================================

SELECT
    f.numero_factura,
    f.estado,
    f.total,
    COALESCE(SUM(p.monto), 0) AS monto_pagado,
    f.total - COALESCE(SUM(p.monto), 0) AS saldo
FROM public.facturas_encabezado f
LEFT JOIN public.pagos p
    ON p.id_factura = f.id_factura
   AND p.estado = 'CONFIRMADO'
WHERE f.numero_factura LIKE 'FAC-F2-%'
GROUP BY
    f.id_factura,
    f.numero_factura,
    f.estado,
    f.total
ORDER BY f.numero_factura;


-- ============================================================
-- 6. REPORTE DE MOVIMIENTOS DE INVENTARIO
-- ============================================================

SELECT
    m.id_movimiento,
    m.fecha_movimiento,
    p.nombre_producto,
    m.tipo_movimiento,
    m.cantidad,
    m.existencia_anterior,
    m.existencia_nueva,
    m.observacion
FROM public.movimientos_inventario m
INNER JOIN public.productos p
    ON m.id_producto = p.id_producto
ORDER BY m.id_movimiento DESC;


-- ============================================================
-- 7. REPORTE DE EXISTENCIAS
-- ============================================================

SELECT
    id_producto,
    nombre_producto,
    stock_actual,
    stock_minimo,
    CASE
        WHEN stock_actual = 0 THEN 'AGOTADO'
        WHEN stock_actual <= stock_minimo THEN 'STOCK BAJO'
        ELSE 'DISPONIBLE'
    END AS estado_inventario
FROM public.productos
ORDER BY id_producto;


-- ============================================================
-- 8. RESUMEN DE COMPRAS
-- ============================================================

SELECT
    COUNT(*) AS cantidad_compras,
    COALESCE(SUM(total), 0) AS total_comprado
FROM public.compras_encabezado
WHERE numero_compra LIKE 'COMP-F2-%';


-- ============================================================
-- 9. RESUMEN DE VENTAS
-- ============================================================

SELECT
    COUNT(*) AS cantidad_facturas,
    COALESCE(SUM(total), 0) AS total_vendido
FROM public.facturas_encabezado
WHERE numero_factura LIKE 'FAC-F2-%'
  AND estado = 'PAGADO';


-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================