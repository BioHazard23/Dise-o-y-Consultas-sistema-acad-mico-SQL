-- PASO 2

CREATE TABLE estudiantes (
    id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    genero ENUM('Masculino', 'Femenino', 'Otro') NOT NULL,
    identificacion VARCHAR(20) NOT NULL UNIQUE,
    carrera VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    fecha_ingreso DATE NOT NULL
);

CREATE TABLE docentes (
    id_docente INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    correo_institucional VARCHAR(100) NOT NULL UNIQUE,
    departamento_academico VARCHAR(100) NOT NULL,
    anios_experiencia INT NOT NULL CHECK (anios_experiencia >= 0)
);

CREATE TABLE cursos (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    creditos INT NOT NULL CHECK (creditos BETWEEN 1 AND 10),
    semestre INT NOT NULL CHECK (semestre BETWEEN 1 AND 12),
    id_docente INT,
    FOREIGN KEY (id_docente) REFERENCES docentes(id_docente) ON DELETE SET NULL
);

CREATE TABLE inscripciones (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT,
    id_curso INT,
    fecha_inscripcion DATE NOT NULL,
    calificacion_final DECIMAL(4,2) CHECK (calificacion_final BETWEEN 0 AND 5),
    FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    FOREIGN KEY (id_curso) REFERENCES cursos(id_curso) ON DELETE CASCADE
);

-- PASO 3

-- Insertar estudiantes
INSERT INTO estudiantes (nombre_completo, correo_electronico, genero, identificacion, carrera, fecha_nacimiento, fecha_ingreso)
VALUES
('Laura Gómez Pérez', 'laura.gomez@correo.com', 'Femenino', '1001234567', 'Ingeniería de Sistemas', '2002-05-14', '2021-01-20'),
('Carlos Rodríguez López', 'carlos.rodriguez@correo.com', 'Masculino', '1009876543', 'Administración de Empresas', '2001-08-10', '2020-07-15'),
('Sofía Martínez Torres', 'sofia.martinez@correo.com', 'Femenino', '1012345678', 'Psicología', '2003-02-25', '2022-02-01'),
('Juan Manuel Arango', 'juan.arango@correo.com', 'Masculino', '1011121314', 'Ingeniería de Sistemas', '2004-11-12', '2023-02-01'),
('Andrés Pérez Mejía', 'andres.perez@correo.com', 'Masculino', '1098765432', 'Contaduría Pública', '2000-09-05', '2019-08-10');

-- Insertar docentes
INSERT INTO docentes (nombre_completo, correo_institucional, departamento_academico, anios_experiencia)
VALUES
('Marta Fernández Ruiz', 'marta.fernandez@uni.edu', 'Ciencias Computacionales', 8),
('Luis Gómez Herrera', 'luis.gomez@uni.edu', 'Ciencias Económicas', 12),
('Ana Torres Velásquez', 'ana.torres@uni.edu', 'Psicología', 4);

-- Insertar cursos
INSERT INTO cursos (nombre, codigo, creditos, semestre, id_docente)
VALUES
('Programación Avanzada', 'CS101', 4, 4, 1),
('Contabilidad General', 'EC202', 3, 3, 2),
('Psicología Cognitiva', 'PS303', 4, 5, 3),
('Bases de Datos', 'CS202', 4, 5, 1);

-- Generacion de inscripciones
INSERT INTO inscripciones (id_estudiante, id_curso, fecha_inscripcion, calificacion_final)
VALUES
(1, 1, '2023-02-10', 4.5),
(1, 4, '2023-02-12', 4.2),
(2, 2, '2023-02-15', 3.8),
(2, 1, '2023-02-17', 4.0),
(3, 3, '2023-02-20', 4.9),
(4, 4, '2023-02-21', 3.7),
(5, 2, '2023-02-22', 4.1),
(5, 1, '2023-02-25', 3.9);

-- PASO 4

-- Listado de todos los estudientes junto con sus inscripciones y cursos
SELECT e.nombre_completo AS Estudiante,
       c.nombre AS Curso,
       i.fecha_inscripcion,
       i.calificacion_final
FROM estudiantes e
JOIN inscripciones i ON e.id_estudiante = i.id_estudiante
JOIN cursos c ON i.id_curso = c.id_curso;

-- Listado de cursos dictados por profesores con mas de 5 años de experiencia
SELECT c.nombre AS Curso, d.nombre_completo AS Docente, d.anios_experiencia
FROM cursos c
JOIN docentes d ON c.id_docente = d.id_docente
WHERE d.anios_experiencia > 5;

-- Obtener el promedio de calificaciones por cursos
SELECT c.nombre AS Curso,
	   ROUND(AVG(i.calificacion_final), 2) AS Promedio_Calificaciones
FROM cursos c
JOIN inscripciones i ON c.id_curso = i.id_curso 
GROUP BY c.nombre;

-- Mostrar estudiantes inscritos en mas de un curso
SELECT e.nombre_completo AS Estudiante, COUNT(i.id_curso) AS Cantidad_Cursos
FROM estudiantes e
JOIN inscripciones i ON e.id_estudiante = i.id_estudiante
GROUP BY e.nombre_completo
HAVING COUNT(i.id_curso) > 1;

-- Agregar nueva columna estado_academico a la tabla estudiantes
ALTER TABLE estudiantes ADD estado_academico VARCHAR(20) DEFAULT 'Activo';

-- Eliminar un docente y observar el efecto en la tabla cursos
DELETE FROM docentes WHERE id_docente = 2;

-- Consultar los cursos en los que se han inscrito más de 2 estudiantes
SELECT c.nombre AS Curso, COUNT(i.id_estudiante) AS Total_Inscritos
FROM cursos c 
JOIN inscripciones i ON c.id_curso = i.id_curso 
GROUP BY c.nombre 
HAVING COUNT(i.id_estudiante) > 2;

-- PASO 5

-- Estudiantes con promedio superior al promedio general
SELECT e.nombre_completo AS Estudiante,
       ROUND(AVG(i.calificacion_final), 2) AS Promedio
FROM estudiantes e
JOIN inscripciones i ON e.id_estudiante = i.id_estudiante
GROUP BY e.nombre_completo
HAVING Promedio > (
    SELECT AVG(calificacion_final)
    FROM inscripciones
);

-- Carreras con estudiantes inscritos en cursos del semestre 2 o posterior usando IN
SELECT DISTINCT e.carrera
FROM estudiantes e 
WHERE e.id_estudiante IN (
	SELECT i.id_estudiante
	FROM inscripciones i 
	JOIN cursos c ON i.id_curso = c.id_curso 
	WHERE c.semestre >= 2
);

-- Funciones para indicadores generales
SELECT 
    ROUND(AVG(calificacion_final), 2) AS Promedio_General,
    MAX(calificacion_final) AS Calificacion_Maxima,
    MIN(calificacion_final) AS Calificacion_Minima,
    COUNT(*) AS Total_Inscripciones,
    SUM(c.creditos) AS Total_Creditos
FROM inscripciones i
JOIN cursos c ON i.id_curso = c.id_curso;

-- PASO 6

-- Crear vista
CREATE VIEW vista_historial_academico AS
SELECT 
	e.nombre_completo AS Estudiante,
	c.nombre AS Curso,
	d.nombre_completo AS Docente,
	c.semestre,
	i.calificacion_final
FROM estudiantes e 
JOIN inscripciones i ON e.id_estudiante = i.id_estudiante
JOIN cursos c ON i.id_curso = c.id_curso
LEFT JOIN docentes d ON c.id_docente = d.id_docente;

SELECT * FROM vista_historial_academico; 

-- Paso 7

-- Crear el rol
CREATE ROLE revisor_academico;

-- Asignar perimisos de solo lectura
GRANT SELECT ON gestion_academica_universidad.vista_historial_academico TO revisor_academico;
GRANT SELECT, INSERT, UPDATE, DELETE ON gestion_academica_universidad.inscripciones TO revisor_academico;

-- Revocar permisos de modificacion de la tabla "inscripciones"
REVOKE INSERT, UPDATE, DELETE ON gestion_academica_universidad.inscripciones FROM revisor_academico;


-- Iniciar simulacion
BEGIN;

-- Crear un punto de guardado
SAVEPOINT antes_actualizar;

-- Primera actualización 
UPDATE inscripciones
SET calificacion_final = 4.6
WHERE id_estudiante = 1 AND id_curso = 1;

-- Segunda actualización 
UPDATE inscripciones
SET calificacion_final = 4.0
WHERE id_estudiante = 2 AND id_curso = 2;

-- Revertir cambios hasta el SAVEPOINT
ROLLBACK TO antes_actualizar;

-- Confirmar si se guardan los datos previos al SAVEPOINT
COMMIT;

