-- ============================================================
-- PROYECTO: SISTEMA DE INVENTARIO Y FACTURACION
-- ARCHIVO: 05_extras_opcional.sql
-- MOTOR: PostgreSQL 15
-- ESQUEMA: public
--
-- Contiene funciones, triggers, indices unicos parciales y vistas
-- identificados en el respaldo dump-inventario_bdii-202610311128.sql.
--
-- EJECUCION:
-- Ejecutar conectado a inventario_bdii, despues de:
-- 01_ddl_crear_base_datos.sql
-- 02_ddl_crear_tablas.sql
-- 03_dml_datos_prueba.sql
--
-- ADVERTENCIA:
-- Este script instala la logica automatica. No lo ejecutes sobre
-- una base que ya tenga triggers activos si estas reprocesando
-- compras/facturas historicas. Los triggers se disparan cuando
-- cambia el estado de una compra a RECIBIDA o una factura a PAGADO.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Eliminar la sobrecarga antigua de cinco parametros.
-- Se conserva una sola firma de siete parametros para que las
-- llamadas desde los triggers puedan asociar compra/factura.
-- ------------------------------------------------------------
DROP FUNCTION IF EXISTS public.registrar_movimiento_inventario(
    INTEGER, VARCHAR, INTEGER, INTEGER, VARCHAR
);

-- ------------------------------------------------------------
-- 2. Funcion para calcular el total de una compra.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.calcular_total_compra(
    p_id_compra INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(12,2);
BEGIN
    SELECT COALESCE(SUM(subtotal), 0)
    INTO v_total
    FROM public.detalle_compra
    WHERE id_compra = p_id_compra;

    UPDATE public.compras_encabezado
    SET total = v_total
    WHERE id_compra = p_id_compra;
END;
$$;

-- ------------------------------------------------------------
-- 3. Funcion para calcular subtotal, impuesto (12%) y total
--    de una factura.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.calcular_total_factura(
    p_id_factura INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_subtotal NUMERIC(12,2);
    v_impuesto NUMERIC(12,2);
    v_total NUMERIC(12,2);
BEGIN
    SELECT COALESCE(SUM(subtotal), 0)
    INTO v_subtotal
    FROM public.detalle_factura
    WHERE id_factura = p_id_factura;

    v_impuesto := ROUND(v_subtotal * 0.12, 2);
    v_total := v_subtotal + v_impuesto;

    UPDATE public.facturas_encabezado
    SET subtotal = v_subtotal,
        impuesto = v_impuesto,
        total = v_total
    WHERE id_factura = p_id_factura;
END;
$$;

-- ------------------------------------------------------------
-- 4. Funcion central para registrar movimientos de inventario.
-- ENTRADA: suma p_cantidad al stock.
-- SALIDA: resta p_cantidad si existe stock suficiente.
-- AJUSTE: p_cantidad representa la existencia final deseada.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.registrar_movimiento_inventario(
    p_id_producto INTEGER,
    p_tipo_movimiento VARCHAR,
    p_cantidad INTEGER,
    p_id_usuario INTEGER,
    p_observacion VARCHAR DEFAULT NULL,
    p_id_compra INTEGER DEFAULT NULL,
    p_id_factura INTEGER DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock_anterior INTEGER;
    v_stock_nuevo INTEGER;
    v_cantidad_movimiento INTEGER;
    v_id_movimiento INTEGER;
BEGIN
    IF p_tipo_movimiento IS NULL
       OR p_tipo_movimiento NOT IN ('ENTRADA', 'SALIDA', 'AJUSTE') THEN
        RAISE EXCEPTION 'Tipo de movimiento no válido.';
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        RAISE EXCEPTION 'La cantidad debe ser mayor que cero.';
    END IF;

    IF p_id_compra IS NOT NULL AND p_id_factura IS NOT NULL THEN
        RAISE EXCEPTION
            'No se puede asociar un movimiento a ambos documentos.';
    END IF;

    IF p_id_compra IS NOT NULL AND p_tipo_movimiento <> 'ENTRADA' THEN
        RAISE EXCEPTION 'Una compra solamente puede generar entradas.';
    END IF;

    IF p_id_factura IS NOT NULL AND p_tipo_movimiento <> 'SALIDA' THEN
        RAISE EXCEPTION 'Una factura solamente puede generar salidas.';
    END IF;

    SELECT stock_actual
    INTO v_stock_anterior
    FROM public.productos
    WHERE id_producto = p_id_producto
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No existe el producto con ID %.', p_id_producto;
    END IF;

    CASE p_tipo_movimiento
        WHEN 'ENTRADA' THEN
            v_stock_nuevo := v_stock_anterior + p_cantidad;
            v_cantidad_movimiento := p_cantidad;

        WHEN 'SALIDA' THEN
            IF p_cantidad > v_stock_anterior THEN
                RAISE EXCEPTION
                    'Stock insuficiente. Existencia: %, solicitada: %.',
                    v_stock_anterior, p_cantidad;
            END IF;

            v_stock_nuevo := v_stock_anterior - p_cantidad;
            v_cantidad_movimiento := p_cantidad;

        WHEN 'AJUSTE' THEN
            v_stock_nuevo := p_cantidad;
            v_cantidad_movimiento :=
                ABS(v_stock_nuevo - v_stock_anterior);

            IF v_cantidad_movimiento = 0 THEN
                RAISE EXCEPTION 'El ajuste no genera cambios.';
            END IF;
    END CASE;

    INSERT INTO public.movimientos_inventario (
        id_producto,
        tipo_movimiento,
        cantidad,
        existencia_anterior,
        existencia_nueva,
        observacion,
        id_usuario,
        id_compra,
        id_factura
    )
    VALUES (
        p_id_producto,
        p_tipo_movimiento,
        v_cantidad_movimiento,
        v_stock_anterior,
        v_stock_nuevo,
        p_observacion,
        p_id_usuario,
        p_id_compra,
        p_id_factura
    )
    RETURNING id_movimiento INTO v_id_movimiento;

    UPDATE public.productos
    SET stock_actual = v_stock_nuevo
    WHERE id_producto = p_id_producto;

    RETURN v_id_movimiento;
END;
$$;

-- ------------------------------------------------------------
-- 5. Funcion trigger: al pasar una compra a RECIBIDA, registra
--    entradas por cada producto de su detalle.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.procesar_compra_recibida()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_detalle RECORD;
BEGIN
    IF NEW.estado = 'RECIBIDA'
       AND OLD.estado <> 'RECIBIDA' THEN

        FOR v_detalle IN
            SELECT id_producto, cantidad
            FROM public.detalle_compra
            WHERE id_compra = NEW.id_compra
        LOOP
            PERFORM public.registrar_movimiento_inventario(
                v_detalle.id_producto,
                'ENTRADA',
                v_detalle.cantidad,
                NEW.id_usuario,
                'Entrada automática por compra ' || NEW.numero_compra,
                NEW.id_compra,
                NULL
            );
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

-- ------------------------------------------------------------
-- 6. Funcion trigger: al pasar una factura a PAGADO, registra
--    salidas por cada producto de su detalle.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.procesar_factura_pagada()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_detalle RECORD;
BEGIN
    IF NEW.estado = 'PAGADO'
       AND OLD.estado <> 'PAGADO' THEN

        FOR v_detalle IN
            SELECT id_producto, cantidad
            FROM public.detalle_factura
            WHERE id_factura = NEW.id_factura
        LOOP
            PERFORM public.registrar_movimiento_inventario(
                v_detalle.id_producto,
                'SALIDA',
                v_detalle.cantidad,
                NEW.id_usuario,
                'Salida automática por factura ' || NEW.numero_factura,
                NULL,
                NEW.id_factura
            );
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$;

-- ------------------------------------------------------------
-- 7. Funciones trigger para recalcular totales al modificar
--    detalles de compra o factura.
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.trg_actualizar_total_compra()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM public.calcular_total_compra(OLD.id_compra);
        RETURN OLD;

    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM public.calcular_total_compra(OLD.id_compra);

        IF NEW.id_compra <> OLD.id_compra THEN
            PERFORM public.calcular_total_compra(NEW.id_compra);
        END IF;

        RETURN NEW;
    ELSE
        PERFORM public.calcular_total_compra(NEW.id_compra);
        RETURN NEW;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_actualizar_total_factura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        PERFORM public.calcular_total_factura(OLD.id_factura);
        RETURN OLD;

    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM public.calcular_total_factura(OLD.id_factura);

        IF NEW.id_factura <> OLD.id_factura THEN
            PERFORM public.calcular_total_factura(NEW.id_factura);
        END IF;

        RETURN NEW;
    ELSE
        PERFORM public.calcular_total_factura(NEW.id_factura);
        RETURN NEW;
    END IF;
END;
$$;

-- ------------------------------------------------------------
-- 8. Indices unicos parciales para impedir duplicar el movimiento
--    de un producto dentro de una misma compra o factura.
-- ------------------------------------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS uq_movimiento_compra_producto
ON public.movimientos_inventario (id_compra, id_producto)
WHERE id_compra IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_movimiento_factura_producto
ON public.movimientos_inventario (id_factura, id_producto)
WHERE id_factura IS NOT NULL;

-- ------------------------------------------------------------
-- 9. Recrear triggers de totales y automatizacion de inventario.
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS actualizar_total_compra
ON public.detalle_compra;

CREATE TRIGGER actualizar_total_compra
AFTER INSERT OR UPDATE OR DELETE
ON public.detalle_compra
FOR EACH ROW
EXECUTE FUNCTION public.trg_actualizar_total_compra();

DROP TRIGGER IF EXISTS actualizar_total_factura
ON public.detalle_factura;

CREATE TRIGGER actualizar_total_factura
AFTER INSERT OR UPDATE OR DELETE
ON public.detalle_factura
FOR EACH ROW
EXECUTE FUNCTION public.trg_actualizar_total_factura();

DROP TRIGGER IF EXISTS trg_procesar_compra_recibida
ON public.compras_encabezado;

CREATE TRIGGER trg_procesar_compra_recibida
AFTER UPDATE OF estado
ON public.compras_encabezado
FOR EACH ROW
EXECUTE FUNCTION public.procesar_compra_recibida();

DROP TRIGGER IF EXISTS trg_procesar_factura_pagada
ON public.facturas_encabezado;

CREATE TRIGGER trg_procesar_factura_pagada
AFTER UPDATE OF estado
ON public.facturas_encabezado
FOR EACH ROW
EXECUTE FUNCTION public.procesar_factura_pagada();

-- ------------------------------------------------------------
-- 10. Vistas de reportes del sistema.
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW public.vista_estado_inventario AS
SELECT
    p.id_producto,
    p.nombre_producto,
    p.stock_actual,
    p.stock_minimo,
    CASE
        WHEN p.stock_actual = 0 THEN 'AGOTADO'
        WHEN p.stock_actual <= p.stock_minimo THEN 'STOCK BAJO'
        ELSE 'DISPONIBLE'
    END AS estado_inventario
FROM public.productos AS p;

CREATE OR REPLACE VIEW public.vista_movimientos_inventario AS
SELECT
    m.id_movimiento,
    m.fecha_movimiento,
    p.nombre_producto,
    m.tipo_movimiento,
    m.cantidad,
    m.existencia_anterior,
    m.existencia_nueva,
    u.nombre_usuario,
    m.observacion,
    c.numero_compra,
    f.numero_factura
FROM public.movimientos_inventario AS m
INNER JOIN public.productos AS p
    ON p.id_producto = m.id_producto
INNER JOIN public.usuarios AS u
    ON u.id_usuario = m.id_usuario
LEFT JOIN public.compras_encabezado AS c
    ON c.id_compra = m.id_compra
LEFT JOIN public.facturas_encabezado AS f
    ON f.id_factura = m.id_factura;

CREATE OR REPLACE VIEW public.vista_productos_stock_bajo AS
SELECT
    p.id_producto,
    p.nombre_producto,
    p.stock_actual,
    p.stock_minimo,
    p.stock_minimo - p.stock_actual AS unidades_necesarias,
    CASE
        WHEN p.stock_actual = 0 THEN 'AGOTADO'
        ELSE 'STOCK BAJO'
    END AS estado
FROM public.productos AS p
WHERE p.stock_actual <= p.stock_minimo;

CREATE OR REPLACE VIEW public.vista_reporte_compras AS
SELECT
    c.id_compra,
    c.numero_compra,
    c.fecha_compra,
    pr.nombre_empresa,
    u.nombre_usuario,
    c.estado,
    c.total
FROM public.compras_encabezado AS c
INNER JOIN public.proveedores AS pr
    ON pr.id_proveedor = c.id_proveedor
INNER JOIN public.usuarios AS u
    ON u.id_usuario = c.id_usuario;

CREATE OR REPLACE VIEW public.vista_reporte_facturacion AS
SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    c.nombre_completo,
    u.nombre_usuario,
    f.estado,
    f.subtotal,
    f.impuesto,
    f.total
FROM public.facturas_encabezado AS f
INNER JOIN public.clientes AS c
    ON c.id_cliente = f.id_cliente
INNER JOIN public.usuarios AS u
    ON u.id_usuario = f.id_usuario;

CREATE OR REPLACE VIEW public.vista_resumen_sistema AS
SELECT
    (SELECT COUNT(*) FROM public.productos) AS total_productos,
    (SELECT COUNT(*) FROM public.productos
     WHERE stock_actual <= stock_minimo) AS productos_stock_bajo,
    (SELECT COUNT(*) FROM public.compras_encabezado) AS total_compras,
    (SELECT COALESCE(SUM(total), 0)
     FROM public.compras_encabezado
     WHERE estado = 'RECIBIDA') AS total_compras_recibidas,
    (SELECT COUNT(*) FROM public.facturas_encabezado) AS total_facturas,
    (SELECT COALESCE(SUM(total), 0)
     FROM public.facturas_encabezado
     WHERE estado <> 'ANULADO') AS total_facturado,
    (SELECT COUNT(*) FROM public.movimientos_inventario) AS total_movimientos;

-- ------------------------------------------------------------
-- 11. Verificacion rapida de objetos instalados.
-- ------------------------------------------------------------
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY event_object_table, trigger_name;

SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
  AND table_name LIKE 'vista_%'
ORDER BY table_name;

-- ============================================================
-- FIN DEL ARCHIVO 05_extras_opcional.sql
-- ============================================================
