-- Índices

-- Simples
-- Ideas de negocio
CREATE INDEX idx_ideas_estado ON ideas_negocio(estado);
CREATE INDEX idx_ideas_usuario_id ON ideas_negocio(usuario_id);

-- Avances de fases
CREATE INDEX idx_avance_idea_id ON avance_fases(idea_id);

-- Usuarios
CREATE INDEX idx_usuarios_persona_id ON usuarios(persona_id);

-- Estadísticas
CREATE INDEX idx_estadisticas_avance_fase ON estadisticas_idea(avance_fase_id);

-- Mentorías
CREATE INDEX idx_mentorias_id ON mentorias(id);
CREATE INDEX idx_mentorias_estado ON mentorias(estado);

-- Tipos de estados
CREATE INDEX idx_tipo_estados_id ON tipo_estados(id);

-- Compuestos
-- Ideas de negocio
CREATE INDEX idx_ideas_estado_usuario ON ideas_negocio(estado, usuario_id);

-- Estadísticas
CREATE INDEX idx_estadisticas_compuesto ON estadisticas_idea(avance_fase_id, mentoria_id);

-- Mentorías
CREATE INDEX idx_mentorias_compuesto ON mentorias(id, estado);
CREATE INDEX idx_ideas_negocio_estado_id ON ideas_negocio(estado, id);
CREATE INDEX idx_avance_fases_idea_fase ON avance_fases(idea_id, fase_id);


-- Análisis de rendimiento con EXPLAIN
EXPLAIN ANALYZE
SELECT i.id, i.titulo, p.nombres, p.apellidos, ef.fase_id, ef.porcentaje_avance
FROM ideas_negocio i
JOIN usuarios u ON i.usuario_id = u.id
JOIN personas p ON u.persona_id = p.id
JOIN avance_fases ef ON i.id = ef.idea_id
WHERE i.estado = 2;


-- Ver índices existentes
SELECT schemaname, tablename, indexname 
FROM pg_indexes 
WHERE schemaname = 'public' 
ORDER BY tablename, indexname;

-- Ver tamaño de los índices
SELECT
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY pg_relation_size(indexname::regclass) DESC;