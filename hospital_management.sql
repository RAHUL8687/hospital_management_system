-- Create Database
CREATE DATABASE EHIAS;
USE EHIAS;

-- CREATING DEPARTMENT TABLE
create table departments
(
  departmentID int auto_increment primary key,
  name varchar(50) not null
);

-- CREATING TABLE DOCTORS
create table doctors
(
  doctorid int auto_increment primary key,
  name varchar(50),
  specialization varchar(100),
  role varchar(50),
  departmentid int,
  foreign key (departmentid) references departments(departmentid)
);

-- CREATE PATIENTS
CREATE TABLE patients (
    patientid INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    dateofbirth DATE,
    gender VARCHAR(1),
    phone VARCHAR(15),
    
    CONSTRAINT chk_gender 
    CHECK (gender IN ('m','f','o'))
);

-- CREATE APPOINTMENT
CREATE TABLE IF NOT EXISTS appointments (
    appointmentid INT AUTO_INCREMENT PRIMARY KEY,
    patientid INT,
    doctorid INT,
    appointmenttime DATETIME,
    status VARCHAR(50),

    FOREIGN KEY (patientid) REFERENCES patients(patientid),
    FOREIGN KEY (doctorid) REFERENCES doctors(doctorid),

    CHECK (status IN ('Scheduled','Completed','Cancelled'))
);

-- PRESCRIPTION TABLE
CREATE TABLE PRESCRIPTIONS
( 
PRECRIPTIONID INT auto_increment primary key,
APPOINTMENTID INT,
MEDICATION VARCHAR(100),
DOSAGE VARCHAR(100),
FOREIGN KEY  (APPOINTMENTID) REFERENCES APPOINTMENTS(appointmentid)
);

-- BILLS TABLE
CREATE TABLE IF NOT EXISTS bills ( 
    billid INT AUTO_INCREMENT PRIMARY KEY,
    appointmentid INT,
    amount DECIMAL(10,2),
    paid TINYINT(1),
    billdate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (appointmentid) REFERENCES appointments(appointmentid)
);

-- LABREPORT TABLES
CREATE TABLE LABREPORTS
( 
 REPORTID INT auto_increment primary key,
 APPOINTMENTID INT,
 REPORTDATA TEXT,
 CREATEDAT DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY  (APPOINTMENTID) REFERENCES APPOINTMENTS(appointmentid)
);

-- INSERTION IN DATABASE

-- INSERTING VALUES INTO DEPARTMENT TABLE
SELECT * FROM HOSPITAL_DATA;

SELECT `Departments.DepartmentID` FROM 
HOSPITAL_DATA;

SELECT CONCAT(
    'SELECT ',
    GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')),
    ' FROM hospital_data'
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'EHIAS'
AND TABLE_NAME = 'HOSPITAL_DATA'
AND COLUMN_NAME LIKE 'Departments.%';

INSERT INTO departments (departmentID, name)
SELECT 
    `Departments.DepartmentID`,
    `Departments.Name`
FROM hospital_data
WHERE `Departments.DepartmentID` <> '';

SELECT * FROM departments;


-- INSERTING VALUES INTO DOCTORS TABLE
SELECT CONCAT(
    'SELECT ',
    GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')),
    ' FROM hospital_data'
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='EHIAS'
AND TABLE_NAME='HOSPITAL_DATA'
AND COLUMN_NAME LIKE 'Doctors.%';

INSERT INTO DOCTORS (DepartmentID, DoctorID, Name, Role, Specialization)
SELECT 
    `Doctors.DepartmentID`,
    `Doctors.DoctorID`,
    `Doctors.Name`,
    `Doctors.Role`,
    `Doctors.Specialization`
FROM hospital_data
WHERE `Doctors.DepartmentID` <> '';

SELECT * FROM DOCTORS;


-- PATIENT
SELECT CONCAT(
    'SELECT ',
    GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')),
    ' FROM hospital_data'
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='EHIAS'
AND TABLE_NAME='HOSPITAL_DATA'
AND COLUMN_NAME LIKE 'Patients.%';

INSERT INTO PATIENTS (PatientID, Name, DateOfBirth, Gender, Phone)
SELECT 
    `Patients.PatientID`,
    `Patients.Name`,
    STR_TO_DATE(NULLIF(`Patients.DateOfBirth`, ''), '%d-%m-%Y'),
    `Patients.Gender`,
    `Patients.Phone`
FROM hospital_data
WHERE `Patients.PatientID` <> '';

SELECT * FROM PATIENTS;


SELECT CONCAT(
'SELECT ',
GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')),
' FROM HOSPITAL_DATA'
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = 'EHIAS'  
AND TABLE_NAME = 'hospital_data'
AND COLUMN_NAME LIKE 'Appointments.%';

INSERT INTO APPOINTMENTS
(AppointmentID, PatientID, DoctorID, AppointmentTime, Status)
SELECT
    h.`Appointments.AppointmentID`,
    h.`Appointments.PatientID`,
    h.`Appointments.DoctorID`,
    STR_TO_DATE(h.`Appointments.AppointmentTime`, '%d-%m-%Y %H:%i'),
    h.`Appointments.Status`

FROM HOSPITAL_DATA h
JOIN PATIENTS p 
ON p.PatientID = h.`Appointments.PatientID`

JOIN DOCTORS d 
ON d.DoctorID = h.`Appointments.DoctorID`

WHERE h.`Appointments.AppointmentID` <> '';

SELECT * FROM APPOINTMENTS;



-- INSERTING VALUE INTO PRESCRIPTIONS
SELECT CONCAT(
'SELECT ',
GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')),
' FROM HOSPITAL_DATA'
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = 'EHIAS'
AND TABLE_NAME = 'hospital_data'
AND COLUMN_NAME LIKE 'Prescriptions.%';

INSERT INTO PRESCRIPTIONS 
(PRECRIPTIONID, AppointmentID, Medication, Dosage)

SELECT
    h.`Prescriptions.PrescriptionID`,
    h.`Prescriptions.AppointmentID`,
    h.`Prescriptions.Medication`,
    h.`Prescriptions.Dosage`

FROM HOSPITAL_DATA h
JOIN APPOINTMENTS a
ON a.AppointmentID = h.`Prescriptions.AppointmentID`

WHERE h.`Prescriptions.PrescriptionID` <> '';

SHOW COLUMNS FROM PRESCRIPTIONS;



SELECT CONCAT(
'SELECT ',
GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')),
' FROM HOSPITAL_DATA'
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = 'EHIAS'
AND TABLE_NAME = 'hospital_data'
AND COLUMN_NAME LIKE 'LabReports.%';

INSERT INTO LABREPORTS
(ReportID, AppointmentID, ReportData, CreatedAt)

SELECT
    h.`LabReports.ReportID`,
    h.`LabReports.AppointmentID`,
    h.`LabReports.ReportData`,
    h.`LabReports.CreatedAt`

FROM HOSPITAL_DATA h
JOIN APPOINTMENTS a
ON a.AppointmentID = h.`LabReports.AppointmentID`

WHERE h.`LabReports.ReportID` <> '';

SELECT * FROM LABREPORTS;



SELECT CONCAT(
'SELECT ',
GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`')),
' FROM HOSPITAL_DATA'
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
TABLE_SCHEMA = 'EHIAS'
AND TABLE_NAME = 'hospital_data'
AND COLUMN_NAME LIKE 'Bills.%';

INSERT INTO BILLS
(BillID, AppointmentID, Amount, Paid, BillDate)

SELECT
    h.`Bills.BillID`,
    h.`Bills.AppointmentID`,
    h.`Bills.Amount`,
    h.`Bills.Paid`,
    h.`Bills.BillDate`

FROM HOSPITAL_DATA h
JOIN APPOINTMENTS a
ON a.AppointmentID = h.`Bills.AppointmentID`

WHERE h.`Bills.BillID` <> '';

SELECT * FROM BILLS;



-- POINT 4
DROP TRIGGER IF EXISTS CHECK_NEW_APPOINMENT;

DELIMITER $$

CREATE TRIGGER CHECK_NEW_APPOINMENT
BEFORE INSERT ON APPOINTMENTS
FOR EACH ROW
BEGIN 

   IF NEW.AppointmentTime < NOW() THEN 
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: Appointment cannot be in the past.';
   END IF;
   
   IF EXISTS
   (
      SELECT 1 FROM APPOINTMENTS
      WHERE DoctorID = NEW.DoctorID 
      AND AppointmentTime = NEW.AppointmentTime
      AND Status = 'Scheduled'
   ) 
   THEN 
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Error: Doctor already has an appointment at this time';
   END IF;

END $$

DELIMITER ;


-- POINT 5
DROP PROCEDURE IF EXISTS VIEW_DOCTOR_DATA;

DELIMITER $$

CREATE PROCEDURE VIEW_DOCTOR_DATA
(IN INPUT_USERNAME VARCHAR(100), IN INPUT_PASSWORD VARCHAR(100))
BEGIN 
  DECLARE DOC_ROLE VARCHAR(100);
  DECLARE DOC_DEPT INT;
  DECLARE DOC_ID INT;
  
  -- CHECK CREDENTIALS OF THE DOCTOR
  SELECT DOCTOR_ID INTO DOC_ID
  FROM DOCTOR_CREDENTIALS 
  WHERE USER_NAME = INPUT_USERNAME 
  AND PASSWORD = INPUT_PASSWORD;
  
  -- GET ROLE AND DEPARTMENT FROM DOCTORS TABLE
  SELECT ROLE, DEPARTMENTID
  INTO DOC_ROLE, DOC_DEPT
  FROM DOCTORS 
  WHERE DOCTORID = DOC_ID;
  
  -- SHOW APPROPRIATE PATIENTS DATA
  IF DOC_ROLE = 'senior' THEN
    
     SELECT 
        D.DOCTORID,
        P.PatientID,
        P.Name,
        P.Gender, 
        A.AppointmentTime,
        PR.Medication,
        LR.ReportData
     FROM PATIENTS P
     JOIN APPOINTMENTS A ON A.PatientID = P.PatientID
     JOIN DOCTORS D ON D.DoctorID = A.DoctorID
     LEFT JOIN PRESCRIPTIONS PR ON A.AppointmentID = PR.AppointmentID
     LEFT JOIN LABREPORTS LR ON A.AppointmentID = LR.AppointmentID
     WHERE D.DepartmentID = DOC_DEPT;

  ELSE

     SELECT 
        A.DoctorID,
        P.PatientID,
        P.Name,
        P.Gender, 
        A.AppointmentTime,
        PR.Medication,
        LR.ReportData
     FROM PATIENTS P
     JOIN APPOINTMENTS A ON A.PatientID = P.PatientID
     LEFT JOIN PRESCRIPTIONS PR ON A.AppointmentID = PR.AppointmentID
     LEFT JOIN LABREPORTS LR ON A.AppointmentID = LR.AppointmentID
     WHERE A.DoctorID = DOC_ID;

   END IF;

END $$

DELIMITER ;


-- POINT 6
DROP PROCEDURE IF EXISTS SP_MONTHLYREVENUE;

DELIMITER //

CREATE PROCEDURE SP_MONTHLYREVENUE(IN P_YEAR INT , IN P_MONTH INT)
BEGIN

 SELECT 
    D1.Name AS Department,
    SUM(B.Amount) AS Total_Revenue 

 FROM BILLS B
 JOIN APPOINTMENTS A ON A.AppointmentID = B.AppointmentID
 JOIN DOCTORS D ON A.DoctorID = D.DoctorID
 JOIN DEPARTMENTS D1 ON D1.DepartmentID = D.DepartmentID

 WHERE MONTH(B.BillDate) = P_MONTH 
 AND YEAR(B.BillDate) = P_YEAR

 GROUP BY D1.Name;

END//

DELIMITER ;



