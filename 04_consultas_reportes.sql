-- ============================================================
-- PROYECTO: SISTEMA DE INVENTARIO Y FACTURACION
-- ARCHIVO: 04_consultas_reportes.sql
-- MOTOR: PostgreSQL 15
--
-- Fuente de estructura: respaldo dump-inventario_bdii-202610311128.sql
-- Esquema: public
--
-- IMPORTANTE:
-- 1. Este archivo contiene consultas SELECT; no modifica datos.
-- 2. Ejecutar conectado a la base de datos inventario_bdii.
-- 3. Las fechas de ejemplo se pueden cambiar en las consultas 8 y 10.
-- 4. Los importes de ventas se calculan desde facturas y detalles.
--    Para ventas cobradas, consultar pagos confirmados (consulta 12).
-- ============================================================


-- ============================================================
-- CONSULTA 1. PRODUCTOS CON BAJO STOCK
-- Lista productos cuya existencia actual es menor o igual
-- al mínimo configurado.
-- ============================================================
SELECT
    p.id_producto,
    p.codigo_barras,
    p.nombre_producto,
    p.stock_actual,
    p.stock_minimo,
    CASE
        WHEN p.stock_actual = 0 THEN 'AGOTADO'
        ELSE 'STOCK BAJO'
    END AS estado_inventario
FROM public.productos AS p
WHERE p.stock_actual <= p.stock_minimo
ORDER BY p.stock_actual ASC, p.nombre_producto;


-- ============================================================
-- CONSULTA 2. PRODUCTOS CON SU CATEGORIA Y PROVEEDOR
-- Demuestra INNER JOIN entre productos, categorias y proveedores.
-- ============================================================
SELECT
    p.id_producto,
    p.codigo_barras,
    p.nombre_producto,
    c.nombre_categoria,
    pr.nombre_empresa AS nombre_proveedor,
    p.precio_compra,
    p.precio_venta,
    p.stock_actual
FROM public.productos AS p
INNER JOIN public.categorias AS c
    ON c.id_categoria = p.id_categoria
INNER JOIN public.proveedores AS pr
    ON pr.id_proveedor = p.id_proveedor
ORDER BY c.nombre_categoria, p.nombre_producto;


-- ============================================================
-- CONSULTA 3. FACTURA COMPLETA
-- Presenta encabezado, cliente y cada linea de detalle.
-- Se utiliza LEFT JOIN para mostrar tambien facturas sin detalle.
-- Cambiar el numero de factura del filtro si se desea consultar otra.
-- ============================================================
SELECT
    f.id_factura,
    f.numero_factura,
    f.fecha_emision,
    f.estado AS estado_factura,
    c.nit,
    c.nombre_completo AS cliente,
    u.nombre_completo AS usuario_responsable,
    p.nombre_producto,
    df.cantidad,
    df.precio_unitario,
    df.subtotal AS subtotal_linea,
    f.subtotal AS subtotal_factura,
    f.impuesto,
    f.total
FROM public.facturas_encabezado AS f
INNER JOIN public.clientes AS c
    ON c.id_cliente = f.id_cliente
INNER JOIN public.usuarios AS u
    ON u.id_usuario = f.id_usuario
LEFT JOIN public.detalle_factura AS df
    ON df.id_factura = f.id_factura
LEFT JOIN public.productos AS p
    ON p.id_producto = df.id_producto
WHERE f.numero_factura = 'FAC-001'
ORDER BY df.id_detalle_factura;


-- ============================================================
-- CONSULTA 4. VENTAS TOTALES POR CLIENTE
-- Resume cantidad de facturas, importe facturado y promedio.
-- Se excluyen facturas anuladas. Se incluyen clientes sin ventas.
-- ============================================================
SELECT
    c.id_cliente,
    c.nombre_completo AS cliente,
    COUNT(f.id_factura) FILTER (WHERE f.estado <> 'ANULADO')
        AS cantidad_facturas,
    COALESCE(
        SUM(f.total) FILTER (WHERE f.estado <> 'ANULADO'),
        0
    ) AS total_facturado,
    COALESCE(
        AVG(f.total) FILTER (WHERE f.estado <> 'ANULADO'),
        0
    ) AS promedio_por_factura
FROM public.clientes AS c
LEFT JOIN public.facturas_encabezado AS f
    ON f.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_completo
ORDER BY total_facturado DESC, c.nombre_completo;


-- ============================================================
-- CONSULTA 5. VENTAS POR PRODUCTO
-- Muestra unidades vendidas e ingreso generado por producto.
-- Se excluyen facturas anuladas.
-- ============================================================
SELECT
    p.id_producto,
    p.nombre_producto,
    COALESCE(
        SUM(df.cantidad) FILTER (WHERE f.estado <> 'ANULADO'),
        0
    ) AS cantidad_vendida,
    COALESCE(
        SUM(df.subtotal) FILTER (WHERE f.estado <> 'ANULADO'),
        0
    ) AS ingreso_generado
FROM public.productos AS p
LEFT JOIN public.detalle_factura AS df
    ON df.id_producto = p.id_producto
LEFT JOIN public.facturas_encabezado AS f
    ON f.id_factura = df.id_factura
GROUP BY p.id_producto, p.nombre_producto
ORDER BY cantidad_vendida DESC, ingreso_generado DESC;


-- ============================================================
-- CONSULTA 6. COMPRAS VALORIZADAS POR PROVEEDOR Y CATEGORIA
-- Resume unidades adquiridas e importe de compra por proveedor
-- y categoria. Solo considera compras RECIBIDAS.
-- ============================================================
SELECT
    pr.id_proveedor,
    pr.nombre_empresa AS proveedor,
    c.nombre_categoria,
    COUNT(DISTINCT ce.id_compra) AS cantidad_compras,
    COALESCE(SUM(dc.cantidad), 0) AS unidades_compradas,
    COALESCE(SUM(dc.subtotal), 0) AS importe_comprado
FROM public.proveedores AS pr
LEFT JOIN public.compras_encabezado AS ce
    ON ce.id_proveedor = pr.id_proveedor
   AND ce.estado = 'RECIBIDA'
LEFT JOIN public.detalle_compra AS dc
    ON dc.id_compra = ce.id_compra
LEFT JOIN public.productos AS p
    ON p.id_producto = dc.id_producto
LEFT JOIN public.categorias AS c
    ON c.id_categoria = p.id_categoria
GROUP BY pr.id_proveedor, pr.nombre_empresa, c.id_categoria, c.nombre_categoria
ORDER BY pr.nombre_empresa, importe_comprado DESC;


-- ============================================================
-- CONSULTA 7. PRODUCTOS NUNCA VENDIDOS
-- Identifica productos que no aparecen en ningun detalle de factura.
-- Se usa NOT EXISTS como subconsulta correlacionada.
-- ============================================================
SELECT
    p.id_producto,
    p.codigo_barras,
    p.nombre_producto,
    p.stock_actual,
    p.precio_venta
FROM public.productos AS p
WHERE NOT EXISTS (
    SELECT 1
    FROM public.detalle_factura AS df
    INNER JOIN public.facturas_encabezado AS f
        ON f.id_factura = df.id_factura
    WHERE df.id_producto = p.id_producto
      AND f.estado <> 'ANULADO'
)
ORDER BY p.nombre_producto;


-- ============================================================
-- CONSULTA 8. VENTAS POR RANGO DE FECHAS
-- Agrupa facturacion por dia dentro del periodo indicado.
-- Cambiar las dos fechas para consultar otro periodo.
-- El limite superior es exclusivo para incluir todo el dia final.
-- ============================================================
SELECT
    f.fecha_emision::date AS fecha,
    COUNT(f.id_factura) AS cantidad_facturas,
    SUM(f.subtotal) AS subtotal_vendido,
    SUM(f.impuesto) AS impuesto_calculado,
    SUM(f.total) AS total_facturado
FROM public.facturas_encabezado AS f
WHERE f.fecha_emision >= TIMESTAMP '2026-01-01 00:00:00'
  AND f.fecha_emision <  TIMESTAMP '2027-01-01 00:00:00'
  AND f.estado <> 'ANULADO'
GROUP BY f.fecha_emision::date
ORDER BY fecha;


-- ============================================================
-- CONSULTA 9. AGREGACION CON HAVING Y SUBCONSULTA
-- Muestra clientes cuyo total facturado supera el promedio
-- de los totales de factura no anulados.
-- Incluye GROUP BY, HAVING, SUM y una subconsulta.
-- ============================================================
SELECT
    c.id_cliente,
    c.nombre_completo AS cliente,
    COUNT(f.id_factura) AS cantidad_facturas,
    SUM(f.total) AS total_facturado
FROM public.clientes AS c
INNER JOIN public.facturas_encabezado AS f
    ON f.id_cliente = c.id_cliente
WHERE f.estado <> 'ANULADO'
GROUP BY c.id_cliente, c.nombre_completo
HAVING SUM(f.total) > (
    SELECT AVG(x.total)
    FROM public.facturas_encabezado AS x
    WHERE x.estado <> 'ANULADO'
)
ORDER BY total_facturado DESC;


-- ============================================================
-- CONSULTA 10. KARDEX / HISTORIAL DE MOVIMIENTOS
-- Presenta cronologicamente entradas, salidas y ajustes,
-- con existencia anterior y nueva.
-- ============================================================
SELECT
    m.fecha_movimiento,
    p.id_producto,
    p.nombre_producto,
    m.tipo_movimiento,
    m.cantidad,
    m.existencia_anterior,
    m.existencia_nueva,
    u.nombre_completo AS usuario_responsable,
    m.id_compra,
    m.id_factura,
    m.observacion
FROM public.movimientos_inventario AS m
INNER JOIN public.productos AS p
    ON p.id_producto = m.id_producto
INNER JOIN public.usuarios AS u
    ON u.id_usuario = m.id_usuario
ORDER BY p.nombre_producto, m.fecha_movimiento, m.id_movimiento;


-- ============================================================
-- CONSULTA 11. TOP DE PRODUCTOS MAS VENDIDOS POR PERIODO
-- Resume unidades e ingreso por producto entre dos fechas.
-- Cambiar las fechas para analizar otro periodo.
-- ============================================================
SELECT
    p.id_producto,
    p.nombre_producto,
    SUM(df.cantidad) AS unidades_vendidas,
    SUM(df.subtotal) AS ingreso_generado
FROM public.detalle_factura AS df
INNER JOIN public.facturas_encabezado AS f
    ON f.id_factura = df.id_factura
INNER JOIN public.productos AS p
    ON p.id_producto = df.id_producto
WHERE f.fecha_emision >= TIMESTAMP '2026-01-01 00:00:00'
  AND f.fecha_emision <  TIMESTAMP '2027-01-01 00:00:00'
  AND f.estado <> 'ANULADO'
GROUP BY p.id_producto, p.nombre_producto
ORDER BY unidades_vendidas DESC, ingreso_generado DESC
LIMIT 10;


-- ============================================================
-- CONSULTA 12. CIERRE DE CAJA POR FORMA DE PAGO
-- Resume pagos confirmados por forma de pago en un periodo.
-- Se utiliza la fecha de pago y no la fecha de factura.
-- Cambiar las fechas para consultar otro periodo.
-- ============================================================
SELECT
    fp.id_forma_pago,
    fp.nombre_forma_pago,
    COUNT(pg.id_pago) AS cantidad_pagos,
    COALESCE(SUM(pg.monto), 0) AS total_cobrado,
    COALESCE(AVG(pg.monto), 0) AS promedio_pago,
    COALESCE(MAX(pg.monto), 0) AS pago_maximo,
    COALESCE(MIN(pg.monto), 0) AS pago_minimo
FROM public.formas_pago AS fp
LEFT JOIN public.pagos AS pg
    ON pg.id_forma_pago = fp.id_forma_pago
   AND pg.estado = 'CONFIRMADO'
   AND pg.fecha_pago >= TIMESTAMP '2026-01-01 00:00:00'
   AND pg.fecha_pago <  TIMESTAMP '2027-01-01 00:00:00'
GROUP BY fp.id_forma_pago, fp.nombre_forma_pago
ORDER BY total_cobrado DESC;


-- ============================================================
-- CONSULTA 13. REPORTE CONSOLIDADO POR CLIENTE
-- Muestra frecuencia, gasto acumulado y promedio por factura.
-- Incluye clientes sin facturas mediante LEFT JOIN.
-- ============================================================
SELECT
    c.id_cliente,
    c.nombre_completo AS cliente,
    COUNT(f.id_factura) FILTER (WHERE f.estado <> 'ANULADO')
        AS frecuencia_compra,
    COALESCE(
        SUM(f.total) FILTER (WHERE f.estado <> 'ANULADO'),
        0
    ) AS gasto_acumulado,
    COALESCE(
        AVG(f.total) FILTER (WHERE f.estado <> 'ANULADO'),
        0
    ) AS promedio_compra,
    MAX(f.fecha_emision) AS ultima_factura
FROM public.clientes AS c
LEFT JOIN public.facturas_encabezado AS f
    ON f.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nombre_completo
ORDER BY gasto_acumulado DESC;


-- ============================================================
-- FIN DEL ARCHIVO
-- ============================================================
