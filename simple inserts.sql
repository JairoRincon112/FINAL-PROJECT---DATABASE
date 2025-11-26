
-- 1. INSERTAR ROLES (Fijos)
INSERT INTO roles (nombre_rol, descripcion) VALUES 
('Administrador', 'Acceso total'),
('Recepcionista', 'Gestiona reservas y checkins'),
('Auditor', 'Solo lectura y revisión de logs'),
('Limpieza', 'Gestiona estado de habitaciones');

-- 2. INSERTAR TIPOS DE HABITACIÓN (Fijos)
INSERT INTO tipos_habitacion (nombre, precio_base, capacidad_personas) VALUES
('Standard Simple', 50.00, 1),
('Doble Twin', 80.00, 2),
('Suite Matrimonial', 120.00, 2),
('Suite Presidencial', 300.00, 4);

-- 3. INSERTAR SERVICIOS (Fijos)
INSERT INTO servicios (nombre, precio_unitario) VALUES
('Desayuno Buffet', 15.00),
('Spa Completo', 50.00),
('Lavandería', 10.00),
('Mini Bar', 25.00),
('Transporte Aeropuerto', 30.00);

-- 4. INSERTAR USUARIOS (Staff Base)
-- Insertamos unos pocos usuarios base para asignar las reservas
INSERT INTO usuarios (nombre_completo, email, password_hash, rol_id) VALUES
('Admin Sistema', 'admin@elbosque.com', 'hash_secreto', 1),
('Juan Recepcion', 'juan@elbosque.com', 'hash_secreto', 2),
('Maria Auditora', 'maria@elbosque.com', 'hash_secreto', 3);