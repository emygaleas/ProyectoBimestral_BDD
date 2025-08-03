insert into categorias(nombre,descripcion) values
('Tecnología','Proyectos relacionados con software, hardware e innovación digital.'),
('Educación','Iniciativas que mejoran el aprendizaje y el acceso a la educación.'),
('Salud','Ideas que promueven el bienestar físico y mental.'),
('Alimentos','Propuestas sobre producción, distribución y consumo de alimentos.'),
('Moda','Proyectos en diseño, sostenibilidad y comercio de moda.'),
('Turismo','Iniciativas que fomentan el turismo y experiencias culturales.'),
('Finanzas','Ideas sobre gestión financiera y servicios bancarios.');

insert into fases_proyecto(fase,descripcion)values
('Ideación','Proceso de generación y desarrollo de ideas creativas para resolver un problema o satisfacer una necesidad.'),
('Planificación','Definición de objetivos, recursos y cronograma necesarios para llevar a cabo el proyecto.'),
('Desarrollo','Implementación de las ideas y planes establecidos, donde se crean y construyen los productos o servicios.'),
('Validación','Evaluación de los resultados obtenidos para asegurar que cumplen con los requisitos y expectativas del proyecto.'),
('Lanzamiento','Presentación oficial del producto o servicio al mercado o a los usuarios finales.'),
('Seguimiento','Monitoreo continuo del desempeño del proyecto y de los resultados obtenidos, así como la identificación de mejoras.');

insert into tipo_estados(tipo)values
('pendiente'),
('aprobado'),
('rechazado'),
('en proceso'),
('finalizado');

ALTER TYPE tipo_usuario_enum ADD VALUE 'mentor';



