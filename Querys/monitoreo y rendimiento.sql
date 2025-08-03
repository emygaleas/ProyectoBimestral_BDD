-- Consulta de tamaño de tablas
SELECT
    tablename,
    pg_size_pretty(pg_total_relation_size(tablename::regclass)) AS tamaño_total
FROM
    pg_tables
WHERE
    schemaname = 'public'
ORDER BY
    pg_total_relation_size(tablename::regclass) DESC;

-- Consulta de tamaño de índices
SELECT
    indexname,
    tablename,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as tamaño
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexname::regclass) DESC;

-- Consulta de uso de disco
SELECT
    pg_size_pretty(pg_database_size(current_database())) AS tamaño_base_de_datos;


-- Evaluación de consultas más lentas
-- Activar la extensión
CREATE EXTENSION pg_stat_statements;

-- Consulta
SELECT
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    rows
FROM pg_stat_statements
ORDER BY mean_exec_time DESC;

-- Registro del uso de funciones, procedimientos y recursos.
SELECT
    funcid::regprocedure AS funcion,
    calls,
    total_time,
    self_time
FROM pg_stat_user_functions
ORDER BY total_time DESC;





