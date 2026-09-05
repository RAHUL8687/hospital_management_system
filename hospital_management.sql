/* =========================================================
   HOSPITAL MANAGEMENT SYSTEM
   DATABASE: EHIAS
   ========================================================= */


/* =========================================================
   1. CREATE DATABASE
   ========================================================= */

CREATE DATABASE IF NOT EXISTS EHIAS;

USE EHIAS;


/* =========================================================
   2. DEPARTMENTS TABLE
   ========================================================= */

CREATE TABLE IF NOT EXISTS departments
(
    departmentID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);


/* =========================================================
   3. DOCTORS TABLE
   ========================================================= */

CREATE TABLE IF NOT EXISTS doctors
(
    doctorid INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    specialization VARCHAR(100),
    role VARCHAR(50),
    departmentid INT,

    FOREIGN KEY (departmentid)
        REFERENCES departments(departmentID)
);


/* =========================================================
   4. PATIENTS TABLE
   ========================================================= */

CREATE TABLE IF NOT EXISTS patients
(
    patientid INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    dateofbirth DATE,
    gender VARCHAR(1),
    phone VARCHAR(15),

    CONSTRAINT chk_gender
    CHECK (gender IN ('m','f','o'))
);


/* =========================================================
   5. APPOINTMENTS TABLE
   ========================================================= */

CREATE TABLE IF NOT EXISTS appointments
(
    appointmentid INT AUTO_INCREMENT PRIMARY KEY,
    patientid INT,
    doctorid INT,
    appointmenttime DATETIME,
    status VARCHAR(50),

    FOREIGN KEY (patientid)
        REFERENCES patients(patientid),

    FOREIGN KEY (doctorid)
        REFERENCES doctors(doctorid),

    CHECK (status IN ('Scheduled','Completed','Cancelled'))
);


/* =========================================================
   6. PRESCRIPTIONS TABLE
   ========================================================= */

CREATE TABLE IF NOT EXISTS prescriptions
(
    prescriptionid INT AUTO_INCREMENT PRIMARY KEY,
    appointmentid INT,
    medication VARCHAR(100),
    dosage VARCHAR(100),

    FOREIGN KEY (appointmentid)
        REFERENCES appointments(appointmentid)
);


/* =========================================================
   7. BILLS TABLE
   ========================================================= */

CREATE TABLE IF NOT EXISTS bills
(
    billid INT AUTO_INCREMENT PRIMARY KEY,
    appointmentid INT,
    amount DECIMAL(10,2),
    paid TINYINT(1) DEFAULT 0,
    billdate DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (appointmentid)
        REFERENCES appointments(appointmentid)
);


/* =========================================================
   8. LAB REPORTS TABLE
   ========================================================= */

CREATE TABLE IF NOT EXISTS labreports
(
    reportid INT AUTO_INCREMENT PRIMARY KEY,
    appointmentid INT,
    reportdata TEXT,
    createdat DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (appointmentid)
        REFERENCES appointments(appointmentid)
);


/* =========================================================
   9. DOCTOR CREDENTIALS TABLE
   =========================================================
   
   This table was missing from your original SQL.
   It is required by VIEW_DOCTOR_DATA procedure.
   ========================================================= */

CREATE TABLE IF NOT EXISTS doctor_credentials
(
    credentialid INT AUTO_INCREMENT PRIMARY KEY,
    doctorid INT NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,

    FOREIGN KEY (doctorid)
        REFERENCES doctors(doctorid)
);


/* =========================================================
   10. INSERT DEPARTMENTS FROM HOSPITAL_DATA
   ========================================================= */

INSERT INTO departments (departmentID, name)
SELECT
    `Departments.DepartmentID`,
    `Departments.Name`
FROM hospital_data
WHERE `Departments.DepartmentID` <> '';


SELECT * FROM departments;


/* =========================================================
   11. INSERT DOCTORS FROM HOSPITAL_DATA
   ========================================================= */

INSERT INTO doctors
(
    DepartmentID,
    DoctorID,
    Name,
    Role,
    Specialization
)
SELECT
    `Doctors.DepartmentID`,
    `Doctors.DoctorID`,
    `Doctors.Name`,
    `Doctors.Role`,
    `Doctors.Specialization`
FROM hospital_data
WHERE `Doctors.DepartmentID` <> '';


SELECT * FROM doctors;


/* =========================================================
   12. INSERT PATIENTS FROM HOSPITAL_DATA
   ========================================================= */

INSERT INTO patients
(
    PatientID,
    Name,
    DateOfBirth,
    Gender,
    Phone
)
SELECT
    `Patients.PatientID`,
    `Patients.Name`,
    STR_TO_DATE(
        NULLIF(`Patients.DateOfBirth`, ''),
        '%d-%m-%Y'
    ),
    LOWER(`Patients.Gender`),
    `Patients.Phone`
FROM hospital_data
WHERE `Patients.PatientID` <> '';


SELECT * FROM patients;


/* =========================================================
   13. INSERT APPOINTMENTS FROM HOSPITAL_DATA
   ========================================================= */

INSERT INTO appointments
(
    AppointmentID,
    PatientID,
    DoctorID,
    AppointmentTime,
    Status
)
SELECT
    h.`Appointments.AppointmentID`,
    h.`Appointments.PatientID`,
    h.`Appointments.DoctorID`,
    STR_TO_DATE(
        h.`Appointments.AppointmentTime`,
        '%d-%m-%Y %H:%i'
    ),
    h.`Appointments.Status`
FROM hospital_data h

JOIN patients p
    ON p.PatientID = h.`Appointments.PatientID`

JOIN doctors d
    ON d.DoctorID = h.`Appointments.DoctorID`

WHERE h.`Appointments.AppointmentID` <> '';


SELECT * FROM appointments;


/* =========================================================
   14. INSERT PRESCRIPTIONS FROM HOSPITAL_DATA
   ========================================================= */

INSERT INTO prescriptions
(
    prescriptionid,
    appointmentid,
    medication,
    dosage
)
SELECT
    h.`Prescriptions.PrescriptionID`,
    h.`Prescriptions.AppointmentID`,
    h.`Prescriptions.Medication`,
    h.`Prescriptions.Dosage`
FROM hospital_data h

JOIN appointments a
    ON a.AppointmentID =
       h.`Prescriptions.AppointmentID`

WHERE h.`Prescriptions.PrescriptionID` <> '';


SELECT * FROM prescriptions;


/* =========================================================
   15. INSERT LAB REPORTS FROM HOSPITAL_DATA
   ========================================================= */

INSERT INTO labreports
(
    reportid,
    appointmentid,
    reportdata,
    createdat
)
SELECT
    h.`LabReports.ReportID`,
    h.`LabReports.AppointmentID`,
    h.`LabReports.ReportData`,
    h.`LabReports.CreatedAt`
FROM hospital_data h

JOIN appointments a
    ON a.AppointmentID =
       h.`LabReports.AppointmentID`

WHERE h.`LabReports.ReportID` <> '';


SELECT * FROM labreports;


/* =========================================================
   16. INSERT BILLS FROM HOSPITAL_DATA
   ========================================================= */

INSERT INTO bills
(
    billid,
    appointmentid,
    amount,
    paid,
    billdate
)
SELECT
    h.`Bills.BillID`,
    h.`Bills.AppointmentID`,
    h.`Bills.Amount`,
    h.`Bills.Paid`,
    h.`Bills.BillDate`
FROM hospital_data h

JOIN appointments a
    ON a.AppointmentID =
       h.`Bills.AppointmentID`

WHERE h.`Bills.BillID` <> '';


SELECT * FROM bills;


/* =========================================================
   17. CREATE DOCTOR LOGIN CREDENTIALS
   =========================================================

   Demo credentials:

   doctor1
   Doctor@123

   doctor2
   Doctor@123

   doctor3
   Doctor@123

   etc.

   One credential is automatically created for
   every doctor already present in the doctors table.
   ========================================================= */

INSERT INTO doctor_credentials
(
    doctorid,
    username,
    password
)
SELECT
    doctorid,
    CONCAT('doctor', doctorid),
    'Doctor@123'
FROM doctors
WHERE NOT EXISTS
(
    SELECT 1
    FROM doctor_credentials dc
    WHERE dc.doctorid = doctors.doctorid
);


SELECT
    credentialid,
    doctorid,
    username
FROM doctor_credentials;


/* =========================================================
   18. INDEXES
   ========================================================= */

CREATE INDEX idx_doctors_department
ON doctors(departmentid);

CREATE INDEX idx_appointments_patient
ON appointments(patientid);

CREATE INDEX idx_appointments_doctor
ON appointments(doctorid);

CREATE INDEX idx_appointments_time
ON appointments(appointmenttime);

CREATE INDEX idx_prescriptions_appointment
ON prescriptions(appointmentid);

CREATE INDEX idx_bills_appointment
ON bills(appointmentid);

CREATE INDEX idx_labreports_appointment
ON labreports(appointmentid);


/* =========================================================
   19. APPOINTMENT VALIDATION TRIGGER
   ========================================================= */

DROP TRIGGER IF EXISTS CHECK_NEW_APPOINTMENT;

DELIMITER $$

CREATE TRIGGER CHECK_NEW_APPOINTMENT
BEFORE INSERT ON appointments
FOR EACH ROW
BEGIN

    /* Appointment cannot be in the past */

    IF NEW.appointmenttime < NOW() THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Error: Appointment cannot be in the past.';

    END IF;


    /* Doctor cannot have two scheduled appointments
       at exactly the same time */

    IF EXISTS
    (
        SELECT 1
        FROM appointments
        WHERE doctorid = NEW.doctorid
        AND appointmenttime = NEW.appointmenttime
        AND status = 'Scheduled'
    )
    THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Error: Doctor already has an appointment at this time.';

    END IF;

END$$

DELIMITER ;


/* =========================================================
   20. DOCTOR DATA PROCEDURE
   ========================================================= */

DROP PROCEDURE IF EXISTS VIEW_DOCTOR_DATA;

DELIMITER $$

CREATE PROCEDURE VIEW_DOCTOR_DATA
(
    IN INPUT_USERNAME VARCHAR(100),
    IN INPUT_PASSWORD VARCHAR(100)
)
BEGIN

    DECLARE DOC_ROLE VARCHAR(100);
    DECLARE DOC_DEPT INT;
    DECLARE DOC_ID INT;


    /* =====================================================
       CHECK DOCTOR LOGIN
       ===================================================== */

    SELECT dc.doctorid
    INTO DOC_ID

    FROM doctor_credentials dc

    WHERE dc.username = INPUT_USERNAME
    AND dc.password = INPUT_PASSWORD

    LIMIT 1;


    /* =====================================================
       INVALID LOGIN
       ===================================================== */

    IF DOC_ID IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Error: Invalid username or password.';

    END IF;


    /* =====================================================
       GET DOCTOR ROLE AND DEPARTMENT
       ===================================================== */

    SELECT
        role,
        departmentid

    INTO
        DOC_ROLE,
        DOC_DEPT

    FROM doctors

    WHERE doctorid = DOC_ID;


    /* =====================================================
       SENIOR DOCTOR
       CAN VIEW PATIENTS FROM ENTIRE DEPARTMENT
       ===================================================== */

    IF LOWER(DOC_ROLE) = 'senior' THEN

        SELECT
            D.doctorid,
            D.name AS DoctorName,
            P.patientid,
            P.name AS PatientName,
            P.gender,
            A.appointmentid,
            A.appointmenttime,
            A.status,
            PR.medication,
            PR.dosage,
            LR.reportdata,
            LR.createdat AS ReportCreatedAt

        FROM patients P

        JOIN appointments A
            ON A.patientid = P.patientid

        JOIN doctors D
            ON D.doctorid = A.doctorid

        LEFT JOIN prescriptions PR
            ON A.appointmentid = PR.appointmentid

        LEFT JOIN labreports LR
            ON A.appointmentid = LR.appointmentid

        WHERE D.departmentid = DOC_DEPT

        ORDER BY A.appointmenttime DESC;


    /* =====================================================
       NORMAL DOCTOR
       CAN VIEW ONLY THEIR OWN PATIENTS
       ===================================================== */

    ELSE

        SELECT
            A.doctorid,
            D.name AS DoctorName,
            P.patientid,
            P.name AS PatientName,
            P.gender,
            A.appointmentid,
            A.appointmenttime,
            A.status,
            PR.medication,
            PR.dosage,
            LR.reportdata,
            LR.createdat AS ReportCreatedAt

        FROM patients P

        JOIN appointments A
            ON A.patientid = P.patientid

        JOIN doctors D
            ON D.doctorid = A.doctorid

        LEFT JOIN prescriptions PR
            ON A.appointmentid = PR.appointmentid

        LEFT JOIN labreports LR
            ON A.appointmentid = LR.appointmentid

        WHERE A.doctorid = DOC_ID

        ORDER BY A.appointmenttime DESC;

    END IF;

END$$

DELIMITER ;


/* =========================================================
   21. MONTHLY REVENUE PROCEDURE
   ========================================================= */

DROP PROCEDURE IF EXISTS SP_MONTHLYREVENUE;

DELIMITER //

CREATE PROCEDURE SP_MONTHLYREVENUE
(
    IN P_YEAR INT,
    IN P_MONTH INT
)
BEGIN

    SELECT

        D1.name AS Department,

        SUM(B.amount) AS Total_Revenue

    FROM bills B

    JOIN appointments A
        ON A.appointmentid = B.appointmentid

    JOIN doctors D
        ON A.doctorid = D.doctorid

    JOIN departments D1
        ON D1.departmentid = D.departmentid

    WHERE MONTH(B.billdate) = P_MONTH

    AND YEAR(B.billdate) = P_YEAR

    GROUP BY D1.departmentid, D1.name

    ORDER BY Total_Revenue DESC;

END//

DELIMITER ;


/* =========================================================
   22. FINAL VERIFICATION
   ========================================================= */

SELECT 'DEPARTMENTS' AS TABLE_NAME;
SELECT * FROM departments;

SELECT 'DOCTORS' AS TABLE_NAME;
SELECT * FROM doctors;

SELECT 'PATIENTS' AS TABLE_NAME;
SELECT * FROM patients;

SELECT 'APPOINTMENTS' AS TABLE_NAME;
SELECT * FROM appointments;

SELECT 'PRESCRIPTIONS' AS TABLE_NAME;
SELECT * FROM prescriptions;

SELECT 'LABREPORTS' AS TABLE_NAME;
SELECT * FROM labreports;

SELECT 'BILLS' AS TABLE_NAME;
SELECT * FROM bills;

SELECT 'DOCTOR CREDENTIALS' AS TABLE_NAME;
SELECT credentialid, doctorid, username
FROM doctor_credentials;


/* =========================================================
   23. TEST PROCEDURES
   ========================================================= */

/* Example monthly revenue:
   Change year/month according to your data.
*/

/*
CALL SP_MONTHLYREVENUE(2025, 1);
*/


/* Example doctor login:
   Use doctor1 / Doctor@123
*/

/*
CALL VIEW_DOCTOR_DATA('doctor1', 'Doctor@123');
*/


SELECT * FROM appointments
WHERE appointmenttime > NOW()