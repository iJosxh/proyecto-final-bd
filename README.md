# Sistema de Inventario y Facturación

**Proyecto final – Base de Datos I**

**Universidad Mariano Gálvez de Guatemala**  
**Facultad de Ingeniería en Sistemas**

---

## 1. Descripción del proyecto

El Sistema de Inventario y Facturación es una base de datos relacional desarrollada para administrar las operaciones de compra, venta y control de existencias de un negocio comercial.

El sistema permite gestionar productos, categorías, proveedores, clientes, usuarios, compras, facturas, pagos y movimientos de inventario.

La solución incorpora restricciones de integridad, funciones, disparadores y vistas para automatizar operaciones y facilitar la consulta de información.

## 2. Objetivo

Diseñar e implementar una base de datos relacional que permita administrar las operaciones de inventario y facturación, garantizando la integridad de la información y automatizando los procesos principales del negocio.

## 3. Tecnologías utilizadas

| Tecnología | Utilización |
|---|---|
| PostgreSQL | Sistema gestor de base de datos. |
| DBeaver | Administración y ejecución de scripts SQL. |
| SQL | Creación de tablas, relaciones, consultas y vistas. |
| PL/pgSQL | Desarrollo de funciones y lógica de negocio. |
| GitHub | Almacenamiento y documentación del proyecto. |

## 4. Estructura del proyecto

```text
inventario-facturacion-bd/
│
├── README.md
├── .gitignore
│
├── docs/
│   ├── 01_descripcion_sistema.md
│   ├── 02_diccionario_datos.md
│   ├── 03_justificacion_relaciones.md
│   ├── 04_normalizacion.md
│   └── 05_paso_a_paso.md
│
├── diagramas/
│   ├── modelo_er.png
│   ├── modelo_relacional.png
│   └── modelo_er.drawio
│
└── sql/
    ├── 01_ddl_crear_base_datos.sql
    ├── 02_ddl_crear_tablas.sql
    ├── 03_dml_datos_prueba.sql
    ├── 04_consultas_reportes.sql
    └── 05_extras_opcional.sql
```

## 5. Modelo entidad-relación

El modelo relacional está compuesto por 14 entidades relacionadas mediante llaves primarias y foráneas.

El diseño contempla relaciones de uno a muchos y relaciones de muchos a muchos resueltas mediante tablas de detalle.

![Modelo entidad-relación](diagramas/modelo_er.png)

## 6. Módulos principales

- **Catálogos:** administración de categorías, proveedores, clientes, usuarios, roles, formas de pago y tipos de documentos.
- **Productos:** registro de productos, precios y existencias.
- **Compras:** registro de adquisiciones y sus respectivos detalles.
- **Facturación:** emisión y administración de facturas y detalles de venta.
- **Inventario:** control de entradas, salidas y ajustes de existencias.
- **Pagos:** registro de pagos asociados a facturas.
- **Reportes:** consultas para analizar existencias, compras, facturación y movimientos.

## 7. Funcionalidades implementadas

- Creación de una base de datos relacional de 14 tablas.
- Definición de llaves primarias y foráneas.
- Restricciones `CHECK`, `UNIQUE`, `NOT NULL` y `DEFAULT`.
- Cálculo automático de subtotales y totales.
- Registro de movimientos de inventario.
- Automatización de entradas por compras recibidas.
- Automatización de salidas por facturas pagadas.
- Validación de existencias para evitar stock negativo.
- Vistas para consultar el estado del inventario y los reportes de compras y facturación.

## 8. Documentación

| Documento | Descripción |
|---|---|
| [Descripción del sistema](docs/01_descripcion_sistema.md) | Objetivos, alcance y funcionalidades. |
| [Diccionario de datos](docs/02_diccionario_datos.md) | Tablas, campos, tipos de datos y restricciones. |
| [Justificación de relaciones](docs/03_justificacion_relaciones.md) | Cardinalidades y reglas de negocio. |
| [Normalización](docs/04_normalizacion.md) | Análisis de 1FN, 2FN y 3FN. |
| [Guía paso a paso](docs/05_paso_a_paso.md) | Instalación, ejecución y verificación. |

## 9. Orden de ejecución de scripts

Para reproducir el proyecto, los scripts SQL deben ejecutarse en el siguiente orden:

| Orden | Archivo | Función |
|---:|---|---|
| 1 | `01_ddl_crear_base_datos.sql` | Crear la base de datos. |
| 2 | `02_ddl_crear_tablas.sql` | Crear las tablas y restricciones. |
| 3 | `03_dml_datos_prueba.sql` | Insertar los datos de prueba. |
| 4 | `04_consultas_reportes.sql` | Ejecutar consultas y reportes. |
| 5 | `05_extras_opcional.sql` | Ejecutar funcionalidades adicionales, si corresponde. |

Para conocer el procedimiento detallado de instalación, consultar [05_paso_a_paso.md](docs/05_paso_a_paso.md).

## 10. Integridad y normalización

El diseño utiliza restricciones de integridad referencial para mantener la consistencia entre las entidades.

Asimismo, se aplican los principios de normalización hasta la Tercera Forma Normal (3FN), mediante la separación de entidades, el uso de tablas de detalle y la eliminación de redundancias innecesarias.

## 11. Evidencias del proyecto

Las evidencias de ejecución se incorporarán al repositorio para demostrar:

- Creación de la base de datos.
- Creación de las tablas.
- Inserción de datos.
- Ejecución de funciones y disparadores.
- Actualización de existencias.
- Resultados de consultas y reportes.

## 12. Integrantes

| Integrante | Carné |
|---|---|
| [Nombre del integrante] | [Carné] |
| [Nombre del integrante] | [Carné] |

**Fecha de entrega:** [Fecha de entrega]

---