# FINAL PROJECT - DATABASE

# Sistema de Gestión de Base de Datos - Hotel "El Bosque"

### Autores: Jairo Andres Rincon Blanco y Andres Camilo Cuvides Ortega

### Docente: Hely Suarez Marin

---

## 1. Introducción

El proyecto **Hotel "El Bosque"** consiste en el diseño e implementación de una base de datos relacional robusta, orientada a la gestión eficiente de reservas hoteleras, control de inventario de habitaciones y facturación de servicios.

Este sistema ha sido diseñado bajo estándares profesionales de ingeniería de software, priorizando la **integridad de los datos (ACID)**, la **seguridad transaccional** y la **auditoría forense detallada**.

---

## 2. Objetivos del Diseño

El sistema resuelve las siguientes problemáticas críticas:

- **Concurrencia:** Evita la sobreventa de habitaciones mediante bloqueos transaccionales (Locks).  
- **Trazabilidad:** Implementa un sistema de auditoría tipo "Caja Negra" que registra el estado anterior y nuevo de los datos en formato JSON.  
- **Integridad:** Garantiza la consistencia financiera y operativa mediante restricciones (Constraints) y llaves foráneas.  
- **Escalabilidad:** Soporta alto volumen de datos (probado con carga masiva de +1.000 registros).  

---

## 3. Arquitectura de Datos

### 3.1 Modelo Entidad-Relación (Normalización)

La base de datos cumple estrictamente con la **3ra Forma Normal (3FN)**:

- **Atomicidad:** Todos los campos son indivisibles.  
- **Dependencia Funcional:** Los atributos no clave dependen exclusivamente de la llave primaria.  
- **No Transitividad:** Se eliminaron dependencias transitivas mediante la creación de tablas catálogo (`tipos_habitacion`, `roles`).  

### 3.2 Diccionario de Datos (Entidades Principales)

| Entidad              | Descripción                                                                  | Tipo         |
|----------------------|------------------------------------------------------------------------------|--------------|
| **reservas**         | Tabla transaccional central. Maneja fechas, estados y costos.               | Transaccional |
| **huespedes**        | Información de clientes. Datos únicos por documento.                        | Maestro      |
| **habitaciones**     | Inventario físico del hotel. Controla estado (limpieza/ocupada).            | Maestro      |
| **auditoria_logs**   | Bitácora de seguridad con almacenamiento JSON (Old vs New).                 | Sistema      |
| **consumos_servicios** | Tabla pivote (N:M) que registra gastos extra por reserva.               | Detalle      |
| **usuarios**         | Personal del hotel con credenciales y roles asignados.                      | Seguridad    |

---

## 4. Implementación Técnica Avanzada

### 4.1 Transacciones ACID y Manejo de Concurrencia

Se implementó el procedimiento almacenado `sp_crear_reserva_segura` para garantizar la atomicidad.

**Lógica:**  
Verifica disponibilidad → Bloquea el registro (**FOR UPDATE**) → Inserta Reserva → Actualiza Habitación.

**Seguridad:**  
Si algún paso falla, el sistema ejecuta un **ROLLBACK automático**, dejando la base de datos intacta.
```
-- Fragmento de lógica ACID
START TRANSACTION;

SELECT count(*) ... FOR UPDATE; -- Bloqueo de fila

IF disponible THEN
    INSERT INTO reservas ...;
    COMMIT; -- Confirmación
ELSE
    ROLLBACK; -- Deshacer cambios
END IF;
sql
```
4.2 Auditoría Inteligente (JSON)
El sistema utiliza el tipo de dato JSON nativo de MySQL para almacenar snapshots de los registros modificados.

Trigger: ```trg_audit_reservas_update```

Funcionalidad: Detecta cambios en tablas críticas y guarda un objeto JSON con formato:
```
json
Copiar código
{
  "estado_anterior": "X",
  "estado_nuevo": "Y"
}
```
4.3 Soft Delete (Eliminado Lógico)
Para preservar la historia operativa, no se utiliza DELETE físico en las tablas principales.

Se implementó la columna deleted_at (TIMESTAMP).

Regla:
```
sql
Copiar código
WHERE deleted_at IS NULL
```
en todas las vistas operativas.

## 5. Seguridad y Roles
El sistema implementa el principio de Menor Privilegio mediante roles nativos de MySQL:

Rol recepcionista
Permisos: ```INSERT```, ```SELECT``` en Reservas/Huéspedes.
Restricción: No puede borrar logs ni modificar configuraciones.

Rol auditor
Permisos: ```SELECT``` global (incluyendo ```auditoria_logs```).
Restricción: Solo lectura (Read Only).

## 6. Pruebas de Estrés y Rendimiento
Para validar la robustez, se desarrolló el algoritmo ```sp_generar_data_masiva```.
Resultados:
Huéspedes generados: 1.200 perfiles únicos.
Reservas procesadas: 1.000 transacciones con validación de fechas.
Integridad: 0 errores de llaves foráneas huérfanas detectados.
Tiempo de ejecución: < 5 segundos (optimizado mediante índices).

## 7. Conclusiones
El sistema Hotel El Bosque supera los requisitos de un sistema académico convencional, integrando tecnologías utilizadas en entornos empresariales reales como:
- JSON Logging
- Transacciones ACID complejas
- Estrategias de recuperación ante desastres

La estructura es escalable y segura, lista para futuras expansiones como facturación electrónica o integración web.
