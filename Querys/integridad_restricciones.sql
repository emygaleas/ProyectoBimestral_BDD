ALTER TABLE "avance_fases" ADD CONSTRAINT "fk_avance_fase" FOREIGN KEY ("fase_id") REFERENCES "fases_proyecto" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "estadisticas_idea" ADD CONSTRAINT "fk_avance_fase" FOREIGN KEY ("avance_fase_id") REFERENCES "avance_fases" ("id");

ALTER TABLE "avance_fases" ADD CONSTRAINT "fk_avance_idea" FOREIGN KEY ("idea_id") REFERENCES "ideas_negocio" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "resultados" ADD CONSTRAINT "fk_estadisticas_id" FOREIGN KEY ("estadisticas_id") REFERENCES "estadisticas_idea" ("id") ON DELETE CASCADE;

ALTER TABLE "mentorias" ADD CONSTRAINT "fk_estado" FOREIGN KEY ("estado") REFERENCES "tipo_estados" ("id");

ALTER TABLE "ideas_negocio" ADD CONSTRAINT "fk_idea_categoria" FOREIGN KEY ("categoria_id") REFERENCES "categorias" ("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "ideas_negocio" ADD CONSTRAINT "fk_idea_usuario" FOREIGN KEY ("usuario_id") REFERENCES "usuarios" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "logs_sistema" ADD CONSTRAINT "fk_log_usuario" FOREIGN KEY ("usuario_id") REFERENCES "usuarios" ("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "mentores" ADD CONSTRAINT "fk_mentor_persona" FOREIGN KEY ("persona_id") REFERENCES "personas" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "estadisticas_idea" ADD CONSTRAINT "fk_mentoria_id" FOREIGN KEY ("mentoria_id") REFERENCES "mentorias" ("id");

ALTER TABLE "mentorias" ADD CONSTRAINT "fk_mentoria_idea" FOREIGN KEY ("idea_id") REFERENCES "ideas_negocio" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "mentorias" ADD CONSTRAINT "fk_mentoria_mentor" FOREIGN KEY ("mentor_id") REFERENCES "mentores" ("id");

ALTER TABLE "observaciones" ADD CONSTRAINT "fk_observacion_mentoria" FOREIGN KEY ("mentoria_id") REFERENCES "mentorias" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "reportes" ADD CONSTRAINT "fk_resultado_id" FOREIGN KEY ("resultado_id") REFERENCES "resultados" ("id") ON DELETE CASCADE;

ALTER TABLE "resultados" ADD CONSTRAINT "fk_usuario_id" FOREIGN KEY ("usuario_id") REFERENCES "usuarios" ("id") ON DELETE CASCADE;

ALTER TABLE "usuarios" ADD CONSTRAINT "fk_usuario_persona" FOREIGN KEY ("persona_id") REFERENCES "personas" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ideas_negocio" ADD CONSTRAINT "ideas_negocio_estado_fkey" FOREIGN KEY ("estado") REFERENCES "tipo_estados" ("id");
