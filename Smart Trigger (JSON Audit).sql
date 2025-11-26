DELIMITER //

CREATE TRIGGER trg_audit_reservas_update
AFTER UPDATE ON reservas
FOR EACH ROW
BEGIN
    -- Solo auditar si hubo cambios reales
    IF NOT (OLD.estado <=> NEW.estado AND OLD.fecha_checkin <=> NEW.fecha_checkin AND OLD.habitacion_id <=> NEW.habitacion_id) THEN
        INSERT INTO auditoria_logs (
            tabla_afectada, 
            operacion, 
            usuario_bd, 
            datos_antiguos, 
            datos_nuevos
        ) VALUES (
            'reservas', 
            'UPDATE', 
            USER(), -- Obtiene el usuario actual de MySQL
            JSON_OBJECT(
                'id', OLD.reserva_id, 
                'estado', OLD.estado, 
                'checkin', OLD.fecha_checkin,
                'habitacion', OLD.habitacion_id
            ),
            JSON_OBJECT(
                'id', NEW.reserva_id, 
                'estado', NEW.estado, 
                'checkin', NEW.fecha_checkin,
                'habitacion', NEW.habitacion_id
            )
        );
    END IF;
END //

DELIMITER ;