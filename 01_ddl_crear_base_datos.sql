-- ============================================================
-- ARCHIVO: 01_ddl_crear_base_datos.sql
-- PROYECTO: Sistema de Inventario y Facturacion
-- PostgreSQL 15
--
-- EJECUCION:
-- 1. Conectarse a la base de datos postgres (o una base administrativa).
-- 2. Ejecutar este archivo fuera de un bloque BEGIN/COMMIT.
-- 3. En DBeaver, crear/abrir una conexion a inventario_bdii.
--    CREATE DATABASE no cambia automaticamente la conexion actual.
-- ============================================================

CREATE DATABASE inventario_bdii
    WITH
    OWNER = CURRENT_USER
    ENCODING = 'UTF8'
    TEMPLATE = template0;
