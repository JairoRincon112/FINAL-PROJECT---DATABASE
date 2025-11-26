# FINAL PROJECT - DATABASE

# Database Management System - Hotel "The Forest"

### Authors: Jairo Andres Rincon Blanco and Andres Camilo Cuvides Ortega

### Instructor: Hely Suarez Marin

---

## 1. Introduction

The **Hotel "The Forest"** project consists of the design and implementation of a robust relational database, geared towards the efficient management of hotel reservations, room inventory control, and service billing.

This system has been designed under professional software engineering standards, prioritizing **data integrity (ACID)**, **transactional security**, and **detailed forensic auditing**.

---

## 2. Design Objectives

The system addresses the following critical problems:

- **Concurrency:** Prevents overbooking of rooms through transactional locks.

- **Traceability:** Implements a "Black Box" audit system that records the previous and new state of the data in JSON format.

- **Integrity:** Ensures financial and operational consistency through constraints and foreign keys.

- **Scalability:** Supports high data volumes (tested with a bulk load of over 1,000 records).

---

## 3. Data Architecture

### 3.1 Entity-Relationship Model (Normalization)

The database strictly complies with **3rd Normal Form (3NF)**:

- **Atomicity:** All fields are indivisible.

- **Functional Dependency:** Non-key attributes depend exclusively on the primary key.

- **Non-Transitivity:** Transitive dependencies were eliminated by creating catalog tables (`room_types`, `roles`).

### 3.2 Data Dictionary (Main Entities)

| Entity               | Description                                                           | Type          |
|----------------------|-----------------------------------------------------------------------|---------------|
| **reservations**     | Central transactional table. Handles dates, statuses, and costs.      | Transactional |
| **guests**           | Customer information. Unique data per document.                       | Master        |
| **rooms**            | Hotel's physical inventory. Tracks status (clean/occupied).           | Master        |
| **audit_logs**       | Security log with JSON storage (Old vs. New).                         | System        |
| **service_consumption** | Pivot table (N:M) that records extra expenses per reservation.   | Detail        |
| **users**            | Hotel staff with assigned credentials and roles.                      | Security      |

---


## 4. Advanced Technical Implementation

### 4.1 ACID Transactions and Concurrency Management

The stored procedure `sp_crear_reserva_segura` was implemented to guarantee atomicity.

**Logic:**
Check availability → Lock the record (**FOR UPDATE**) → Insert Reservation → Update Room.

**Security:**
If any step fails, the system executes an automatic ROLLBACK, leaving the database intact.

```
-- ACID Logic Fragment
START TRANSACTION;

SELECT count(*) ... FOR UPDATE; -- Row Lock

IF available THEN
INSERT INTO reservas ...;

COMMIT; -- Commit
ELSE
ROLLBACK; -- Undo changes
END IF;

SQL
```
4.2 Intelligent Audit (JSON)
The system uses MySQL's native JSON data type to store snapshots of modified records.

Trigger: ```trg_audit_reservas_update```

Functionality: Detects changes in critical tables and saves a JSON object with the following format:
```
json
Copy code
{
"previous_state": "X",
"new_state": "Y"
}
```
4.3 Soft Delete (Logical Deletion)
To preserve operational history, physical DELETE operations are not used on the main tables.

The deleted_at (TIMESTAMP) column was implemented.

Rule:
```
sql
Copy code
WHERE deleted_at IS NULL
```
in all operational views.

## 5. Security and Roles
The system implements the Principle of Least Privilege using native MySQL roles:

Receptionist Role
Permissions: ```INSERT```, ```SELECT``` on Reservations/Guests.

Restriction: Cannot delete logs or modify configurations.

Auditor Role
Permissions: Global ```SELECT (including audit_logs)```.

Restriction: Read Only.

## 6. Stress and Performance Testing
To validate robustness, the `sp_generar_data_masiva` algorithm was developed.

Results:
Guests generated: 1,200 unique profiles.
Reservations processed: 1,000 transactions with date validation.

Integrity: 0 orphaned foreign key errors detected.

Execution time: < 5 seconds (optimized using indexes).

## 7. Conclusions
The Hotel El Bosque system exceeds the requirements of a conventional academic system, integrating technologies used in real-world business environments such as:
- JSON Logging
- Complex ACID transactions
- Disaster recovery strategies

The structure is scalable and secure, ready for future expansions such as electronic invoicing or web integration.
