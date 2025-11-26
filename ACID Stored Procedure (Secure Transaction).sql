DELIMITER //

CREATE PROCEDURE sp_crear_reserva_segura(
    IN p_huesped_id INT,
    IN p_habitacion_id INT,
    IN p_usuario_id INT,
    IN p_fecha_in DATETIME,
    IN p_fecha_out DATETIME,
    OUT p_mensaje VARCHAR(100)
)
BEGIN
    DECLARE v_disponible INT DEFAULT 0;
    
    -- Manejo de errores SQL: Si ocurre un error, hacemos Rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error Crítico: Transacción abortada.';
    END;

    START TRANSACTION;

    -- 1. Verificar disponibilidad (Bloqueo de lectura para evitar Race Condition)
    SELECT COUNT(*) INTO v_disponible 
    FROM reservas 
    WHERE habitacion_id = p_habitacion_id 
    AND estado NOT IN ('cancelada', 'checkout')
    AND (
        (p_fecha_in BETWEEN fecha_checkin AND fecha_checkout) OR
        (p_fecha_out BETWEEN fecha_checkin AND fecha_checkout)
    )
    FOR UPDATE; -- LOCK ROW: Nadie más puede leer esta fila hasta que terminemos

    IF v_disponible = 0 THEN
        -- 2. Insertar Reserva
        INSERT INTO reservas (codigo_reserva, huesped_id, habitacion_id, usuario_creador_id, fecha_checkin, fecha_checkout, estado)
        VALUES (UUID_SHORT(), p_huesped_id, p_habitacion_id, p_usuario_id, p_fecha_in, p_fecha_out, 'confirmada');
        
        -- 3. Actualizar estado habitación
        UPDATE habitaciones SET estado = 'ocupada' WHERE habitacion_id = p_habitacion_id;
        
        COMMIT;
        SET p_mensaje = 'Éxito: Reserva creada correctamente.';
    ELSE
        ROLLBACK;
        SET p_mensaje = 'Fallo: La habitación no está disponible en esas fechas.';
    END IF;

END //

DELIMITER ;