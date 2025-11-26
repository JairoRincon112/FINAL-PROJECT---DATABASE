--Generador Masivo

USE hotel_the_forest;

DELIMITER //

DROP PROCEDURE IF EXISTS sp_generar_data_masiva //

CREATE PROCEDURE sp_generar_data_masiva()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_apellido VARCHAR(100);
    DECLARE v_huesped_id INT;
    DECLARE v_reserva_id BIGINT;
    DECLARE v_fecha_in DATETIME;
    
    -- GENERAR HABITACIONES
    SET i = 1;
    WHILE i <= 100 DO
        INSERT INTO habitaciones (numero_habitacion, tipo_id, piso, estado)
        VALUES (CONCAT('HAB-', i), FLOOR(1 + (RAND() * 4)), FLOOR(1 + (RAND() * 5)), 'disponible');
        SET i = i + 1;
    END WHILE;

    -- GENERAR HUÉSPEDES
    SET i = 1;
    WHILE i <= 1200 DO
        SET v_nombre = ELT(FLOOR(1 + (RAND() * 10)), 'Carlos', 'Ana', 'Luis', 'Sofia', 'Jorge', 'Maria', 'Pedro', 'Lucia', 'Miguel', 'Elena');
        SET v_apellido = ELT(FLOOR(1 + (RAND() * 10)), 'Perez', 'Gomez', 'Lopez', 'Rodriguez', 'Fernandez', 'Martinez', 'Sanchez', 'Diaz', 'Torres', 'Ramirez');
        
        INSERT INTO huespedes (documento_identidad, nombre_completo, email, telefono, nacionalidad)
        VALUES (
            CONCAT('DOC-', FLOOR(RAND() * 10000000)), 
            CONCAT(v_nombre, ' ', v_apellido, ' ', i), 
            CONCAT(LOWER(v_nombre), '.', LOWER(v_apellido), i, '@mail.com'), 
            CONCAT('555-', FLOOR(1000 + (RAND() * 9000))),
            ELT(FLOOR(1 + (RAND() * 5)), 'Colombia', 'Mexico', 'Argentina', 'España', 'USA')
        );
        SET i = i + 1;
    END WHILE;

    -- GENERAR RESERVAS
    SET i = 1;
    WHILE i <= 1000 DO
        SET v_huesped_id = FLOOR(1 + (RAND() * 1200));
        SET v_fecha_in = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY);
        
        INSERT INTO reservas (codigo_reserva, huesped_id, habitacion_id, usuario_creador_id, fecha_checkin, fecha_checkout, costo_total, estado)
        VALUES (
            UUID_SHORT(), 
            v_huesped_id,
            FLOOR(1 + (RAND() * 100)), 
            FLOOR(1 + (RAND() * 2)),   
            v_fecha_in,
            DATE_ADD(v_fecha_in, INTERVAL FLOOR(1 + (RAND() * 7)) DAY), 
            FLOOR(100 + (RAND() * 500)), 
            ELT(FLOOR(1 + (RAND() * 4)), 'confirmada', 'checkin', 'checkout', 'cancelada')
        );
        
        SET v_reserva_id = LAST_INSERT_ID();

        IF (RAND() > 0.2) THEN
            INSERT INTO pagos (reserva_id, metodo_pago, monto)
            VALUES (v_reserva_id, ELT(FLOOR(1 + (RAND() * 4)), 'efectivo', 'tarjeta_credito', 'transferencia', 'paypal'), FLOOR(50 + (RAND() * 200)));
        END IF;

        IF (RAND() > 0.5) THEN
            INSERT INTO consumos_servicios (reserva_id, servicio_id, cantidad, subtotal)
            VALUES (v_reserva_id, FLOOR(1 + (RAND() * 5)), FLOOR(1 + (RAND() * 3)), FLOOR(10 + (RAND() * 50)));
        END IF;

        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;

-------------------------------
-- Ejecutar el generador masivo
CALL hotel_the_forest.sp_generar_data_masiva();

-------------------------------
-- Verificación de inserts del generador masivo
SELECT '--- CONTEO FINAL ---' as Resumen;
SELECT 'Huespedes' AS Tabla, COUNT(*) AS Total FROM huespedes
UNION ALL
SELECT 'Reservas', COUNT(*) FROM reservas
UNION ALL
SELECT 'Pagos', COUNT(*) FROM pagos;