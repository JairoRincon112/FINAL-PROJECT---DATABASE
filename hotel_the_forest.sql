
-- 1. TABLA DE AUDITORÍA (Debe existir antes que los triggers)
CREATE TABLE auditoria_logs (
    log_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada VARCHAR(50) NOT NULL,
    operacion ENUM('INSERT', 'UPDATE', 'DELETE', 'SOFT_DELETE') NOT NULL,
    usuario_bd VARCHAR(50) NOT NULL,
    fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    datos_antiguos JSON NULL, -- Aquí guardamos el estado previo
    datos_nuevos JSON NULL,   -- Aquí guardamos el nuevo estado
    ip_origen VARCHAR(45) NULL
) ENGINE=InnoDB COMMENT='Bitácora forense con soporte JSON';

-- 2. TABLA ROLES (Catálogo)
CREATE TABLE roles (
    rol_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255)
) ENGINE=InnoDB;

-- 3. TABLA USUARIOS (Staff - Datos Sensibles)
CREATE TABLE usuarios (
    usuario_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL COMMENT 'Almacenar Bcrypt/Argon2, nunca texto plano',
    rol_id INT UNSIGNED NOT NULL,
    estado ENUM('activo', 'inactivo') DEFAULT 'activo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL COMMENT 'Para Soft Delete',
    CONSTRAINT fk_usuarios_roles FOREIGN KEY (rol_id) REFERENCES roles(rol_id)
) ENGINE=InnoDB;

-- 4. TABLA HUESPEDES (Clientes)
CREATE TABLE huespedes (
    huesped_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    documento_identidad VARCHAR(20) NOT NULL UNIQUE,
    nombre_completo VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    nacionalidad VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5. TABLA TIPOS DE HABITACION
CREATE TABLE tipos_habitacion (
    tipo_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL, -- Ej: Suite Presidencial, Doble
    precio_base DECIMAL(10, 2) NOT NULL CHECK (precio_base > 0),
    capacidad_personas TINYINT UNSIGNED NOT NULL CHECK (capacidad_personas > 0)
) ENGINE=InnoDB;

-- 6. TABLA HABITACIONES (Inventario)
CREATE TABLE habitaciones (
    habitacion_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero_habitacion VARCHAR(10) NOT NULL UNIQUE,
    tipo_id INT UNSIGNED NOT NULL,
    piso TINYINT NOT NULL,
    estado ENUM('disponible', 'ocupada', 'mantenimiento', 'limpieza') DEFAULT 'disponible',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_hab_tipo FOREIGN KEY (tipo_id) REFERENCES tipos_habitacion(tipo_id)
) ENGINE=InnoDB;

-- 7. TABLA RESERVAS (Transaccional - Corazón del sistema)
CREATE TABLE reservas (
    reserva_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo_reserva VARCHAR(20) NOT NULL UNIQUE COMMENT 'UUID o Codigo generado',
    huesped_id INT UNSIGNED NOT NULL,
    habitacion_id INT UNSIGNED NOT NULL,
    usuario_creador_id INT UNSIGNED NOT NULL COMMENT 'Empleado que registró',
    fecha_checkin DATETIME NOT NULL,
    fecha_checkout DATETIME NOT NULL,
    costo_total DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    estado ENUM('pendiente', 'confirmada', 'checkin', 'checkout', 'cancelada') DEFAULT 'pendiente',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL, -- Soft Delete
    
    CONSTRAINT fk_res_huesped FOREIGN KEY (huesped_id) REFERENCES huespedes(huesped_id),
    CONSTRAINT fk_res_hab FOREIGN KEY (habitacion_id) REFERENCES habitaciones(habitacion_id),
    CONSTRAINT fk_res_user FOREIGN KEY (usuario_creador_id) REFERENCES usuarios(usuario_id),
    
    -- VALIDACIÓN IMPORTANTE: CheckOut debe ser posterior a CheckIn
    CONSTRAINT chk_fechas_validas CHECK (fecha_checkout > fecha_checkin)
) ENGINE=InnoDB;

-- 8. TABLA SERVICIOS (Catálogo Extra)
CREATE TABLE servicios (
    servicio_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario >= 0)
) ENGINE=InnoDB;

-- 9. TABLA CONSUMOS (Relación Muchos a Muchos: Reserva <-> Servicios)
CREATE TABLE consumos_servicios (
    consumo_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reserva_id BIGINT UNSIGNED NOT NULL,
    servicio_id INT UNSIGNED NOT NULL,
    cantidad INT UNSIGNED NOT NULL DEFAULT 1,
    subtotal DECIMAL(10,2) NOT NULL,
    fecha_consumo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_con_res FOREIGN KEY (reserva_id) REFERENCES reservas(reserva_id),
    CONSTRAINT fk_con_ser FOREIGN KEY (servicio_id) REFERENCES servicios(servicio_id)
) ENGINE=InnoDB;

-- 10. TABLA PAGOS
CREATE TABLE pagos (
    pago_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reserva_id BIGINT UNSIGNED NOT NULL,
    metodo_pago ENUM('efectivo', 'tarjeta_credito', 'transferencia', 'paypal') NOT NULL,
    monto DECIMAL(10, 2) NOT NULL CHECK (monto > 0),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pagos_reserva FOREIGN KEY (reserva_id) REFERENCES reservas(reserva_id)
) ENGINE=InnoDB;