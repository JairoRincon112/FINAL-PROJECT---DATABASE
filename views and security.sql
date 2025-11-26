--Vistas y Seguridad

--3.1 Vistas para roles específicos

-- Vista para Recepción: Solo ve lo necesario para hoy
CREATE VIEW vw_recepcion_checkins_hoy AS
SELECT 
    r.codigo_reserva,
    h.nombre_completo AS huesped,
    hab.numero_habitacion,
    r.estado
FROM reservas r
JOIN huespedes h ON r.huesped_id = h.huesped_id
JOIN habitaciones hab ON r.habitacion_id = hab.habitacion_id
WHERE DATE(r.fecha_checkin) = CURDATE()
AND r.deleted_at IS NULL;

--3.2 Seguridad (Roles y Usuarios MySQL)

-- Crear Roles a nivel de la base de datos
CREATE ROLE 'rol_recepcionista', 'rol_auditor';

-- Asignar permisos: El recepcionista puede insertar reservas pero NO borrar logs
GRANT SELECT, INSERT, UPDATE ON hotel_the_forest.reservas TO 'rol_recepcionista';
GRANT SELECT, UPDATE ON hotel_the_forest.huespedes TO 'rol_recepcionista';
GRANT SELECT ON hotel_the_forest.habitaciones TO 'rol_recepcionista';

-- El auditor solo puede VER, pero puede ver todo (incluyendo logs)
GRANT SELECT ON hotel_the_forest.* TO 'rol_auditor';

-- Crear un usuario real y asignarle el rol
CREATE USER 'juan_recepcion'@'localhost' IDENTIFIED BY 'PasswordSeguro123!';
GRANT 'rol_recepcionista' TO 'juan_recepcion'@'localhost';
SET DEFAULT ROLE 'rol_recepcionista' TO 'juan_recepcion'@'localhost';