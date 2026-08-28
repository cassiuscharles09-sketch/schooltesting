-- ==================================================================================
-- DATAMEXT COLLEGE OF SAINT ADELINE (DCSA)
-- ALL-IN-ONE COMPLETE SETUP SCRIPT FOR SQL SERVER MANAGEMENT STUDIO (SSMS)
-- Database: DCSA_DB
-- Modules: Multi-Campus Admissions, Enrollment, Admin Security, Student Portal
-- Compatible: SQL Server 2008 / 2012 / 2014 / 2016 / 2019 / 2022 / Express / Azure SQL
-- Instructions: Open this file in SSMS and click [Execute] (F5).
-- ==================================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ----------------------------------------------------------------------------------
-- STEP 1: CREATE DATABASE
-- ----------------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DCSA_DB')
BEGIN
    CREATE DATABASE DCSA_DB;
    PRINT '>>> Database [DCSA_DB] created.';
END
ELSE
BEGIN
    PRINT '>>> Database [DCSA_DB] already exists.';
END
GO

USE DCSA_DB;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ----------------------------------------------------------------------------------
-- STEP 2: DROP EXISTING OBJECTS (FOR CLEAN RE-INSTALL)
-- ----------------------------------------------------------------------------------
-- Drop Views
IF OBJECT_ID('dbo.VW_OFFICIAL_ENROLLEES', 'V') IS NOT NULL DROP VIEW dbo.VW_OFFICIAL_ENROLLEES;
IF OBJECT_ID('dbo.VW_MEYCAUAYAN_APPLICANTS', 'V') IS NOT NULL DROP VIEW dbo.VW_MEYCAUAYAN_APPLICANTS;
IF OBJECT_ID('dbo.VW_FAIRVIEW_APPLICANTS', 'V') IS NOT NULL DROP VIEW dbo.VW_FAIRVIEW_APPLICANTS;
IF OBJECT_ID('dbo.VW_CALOOCAN_APPLICANTS', 'V') IS NOT NULL DROP VIEW dbo.VW_CALOOCAN_APPLICANTS;
IF OBJECT_ID('dbo.VW_VALENZUELA_APPLICANTS', 'V') IS NOT NULL DROP VIEW dbo.VW_VALENZUELA_APPLICANTS;
IF OBJECT_ID('dbo.VW_ALL_CAMPUSES_SUMMARY', 'V') IS NOT NULL DROP VIEW dbo.VW_ALL_CAMPUSES_SUMMARY;

-- Drop Stored Procedures
IF OBJECT_ID('dbo.SP_ENROLL_STUDENT', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_ENROLL_STUDENT;
IF OBJECT_ID('dbo.SP_AUTHENTICATE_ADMIN', 'P') IS NOT NULL DROP PROCEDURE dbo.SP_AUTHENTICATE_ADMIN;

-- Drop Tables
IF OBJECT_ID('dbo.DCSA_ENROLLMENTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_ENROLLMENTS;
IF OBJECT_ID('dbo.DCSA_ANNOUNCEMENTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_ANNOUNCEMENTS;
IF OBJECT_ID('dbo.DCSA_APPLICANTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_APPLICANTS;
IF OBJECT_ID('dbo.DCSA_SUBJECTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_SUBJECTS;
IF OBJECT_ID('dbo.DCSA_PROGRAMS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_PROGRAMS;
IF OBJECT_ID('dbo.DCSA_ADMIN_ACCOUNTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_ADMIN_ACCOUNTS;
IF OBJECT_ID('dbo.DCSA_CAMPUSES', 'U') IS NOT NULL DROP TABLE dbo.DCSA_CAMPUSES;
GO

PRINT '>>> Previous database objects dropped cleanly.';
GO

-- ----------------------------------------------------------------------------------
-- STEP 3: CREATE SCHEMA TABLES (DDL)
-- ----------------------------------------------------------------------------------

-- 3.1 CAMPUS BRANCHES TABLE
CREATE TABLE dbo.DCSA_CAMPUSES (
    campus_id       INT IDENTITY(1,1) PRIMARY KEY,
    campus_code     VARCHAR(20) NOT NULL UNIQUE,
    campus_name     VARCHAR(100) NOT NULL,
    address         VARCHAR(255) NOT NULL,
    contact_no      VARCHAR(50) NULL,
    email           VARCHAR(100) NULL,
    map_url         VARCHAR(500) NULL,
    status          VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at      DATETIME DEFAULT GETDATE()
);
GO

-- 3.2 ADMIN ACCOUNTS TABLE
CREATE TABLE dbo.DCSA_ADMIN_ACCOUNTS (
    admin_id        INT IDENTITY(1,1) PRIMARY KEY,
    username        VARCHAR(50) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    full_name       VARCHAR(100) NOT NULL,
    role            VARCHAR(30) NOT NULL CHECK (role IN ('SuperAdmin', 'BranchAdmin')),
    campus_id       INT NULL,
    email           VARCHAR(100) NULL,
    is_active       BIT DEFAULT 1 CHECK (is_active IN (0, 1)),
    created_at      DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ADMIN_CAMPUS FOREIGN KEY (campus_id) 
        REFERENCES dbo.DCSA_CAMPUSES (campus_id) ON DELETE SET NULL
);
GO

-- 3.3 ACADEMIC PROGRAMS TABLE
CREATE TABLE dbo.DCSA_PROGRAMS (
    program_id       INT IDENTITY(1,1) PRIMARY KEY,
    academic_level   VARCHAR(20) NOT NULL CHECK (academic_level IN ('College', 'SHS')),
    program_code     VARCHAR(20) NOT NULL UNIQUE,
    program_name     VARCHAR(150) NOT NULL,
    description      VARCHAR(500) NULL,
    total_units      INT DEFAULT 0,
    tuition_per_unit DECIMAL(10,2) DEFAULT 350.00,
    lab_fee          DECIMAL(10,2) DEFAULT 1500.00,
    misc_fee         DECIMAL(10,2) DEFAULT 800.00,
    status           VARCHAR(20) DEFAULT 'ACTIVE'
);
GO

-- 3.4 APPLICANTS & ENROLLEES TABLE
CREATE TABLE dbo.DCSA_APPLICANTS (
    applicant_id        INT IDENTITY(100,1) PRIMARY KEY,
    reference_no        VARCHAR(30) NOT NULL UNIQUE,
    student_id          VARCHAR(30) NULL,
    first_name          VARCHAR(50) NOT NULL,
    middle_name         VARCHAR(50) NULL,
    last_name           VARCHAR(50) NOT NULL,
    suffix              VARCHAR(10) NULL,
    gender              VARCHAR(15) NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    birth_date          DATE NULL,
    age                 INT NULL,
    civil_status        VARCHAR(20) DEFAULT 'Single',
    email               VARCHAR(100) NOT NULL,
    contact_no          VARCHAR(30) NOT NULL,
    address             VARCHAR(300) NOT NULL,
    guardian_name       VARCHAR(100) NULL,
    guardian_contact    VARCHAR(30) NULL,
    guardian_relation   VARCHAR(50) NULL,
    program_id          INT NOT NULL,
    campus_id           INT NOT NULL,
    academic_level      VARCHAR(20) NOT NULL CHECK (academic_level IN ('College', 'SHS')),
    entry_type          VARCHAR(30) DEFAULT 'Freshman' CHECK (entry_type IN ('Freshman', 'Transferee', 'Cross-Enrollee')),
    last_school         VARCHAR(150) NULL,
    voucher_beneficiary VARCHAR(10) DEFAULT 'No' CHECK (voucher_beneficiary IN ('Yes', 'No')),
    status              VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Enrolled', 'Rejected')),
    notes               VARCHAR(1000) NULL,
    date_applied        DATETIME DEFAULT GETDATE(),
    updated_at          DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_APPLICANT_PROGRAM FOREIGN KEY (program_id) REFERENCES dbo.DCSA_PROGRAMS (program_id),
    CONSTRAINT FK_APPLICANT_CAMPUS FOREIGN KEY (campus_id) REFERENCES dbo.DCSA_CAMPUSES (campus_id)
);
GO

-- Filtered Unique Index for student_id (permits multiple NULLs for pending applicants)
CREATE UNIQUE NONCLUSTERED INDEX UQ_DCSA_APPLICANTS_STUDENT_ID 
ON dbo.DCSA_APPLICANTS(student_id) 
WHERE student_id IS NOT NULL;
GO

-- 3.5 SUBJECTS / CURRICULUM TABLE
CREATE TABLE dbo.DCSA_SUBJECTS (
    subject_id      INT IDENTITY(1,1) PRIMARY KEY,
    program_id      INT NOT NULL,
    subject_code    VARCHAR(20) NOT NULL,
    subject_desc    VARCHAR(150) NOT NULL,
    units           INT NOT NULL,
    day_schedule    VARCHAR(50) NULL,
    time_schedule   VARCHAR(50) NULL,
    room_lab        VARCHAR(50) NULL,
    instructor      VARCHAR(100) NULL,
    semester        VARCHAR(20) DEFAULT '1st Semester',
    academic_year   VARCHAR(20) DEFAULT '2026-2027',
    CONSTRAINT FK_SUBJECT_PROGRAM FOREIGN KEY (program_id) REFERENCES dbo.DCSA_PROGRAMS (program_id)
);
GO

-- 3.6 OFFICIAL ENROLLMENTS TABLE
CREATE TABLE dbo.DCSA_ENROLLMENTS (
    enrollment_id    INT IDENTITY(1,1) PRIMARY KEY,
    applicant_id     INT NOT NULL,
    student_id       VARCHAR(30) NOT NULL,
    campus_id        INT NOT NULL,
    program_id       INT NOT NULL,
    semester         VARCHAR(20) DEFAULT '1st Semester',
    academic_year    VARCHAR(20) DEFAULT '2026-2027',
    total_units      INT DEFAULT 0,
    assessment_total DECIMAL(10,2) DEFAULT 0.00,
    voucher_discount DECIMAL(10,2) DEFAULT 0.00,
    balance_due      DECIMAL(10,2) DEFAULT 0.00,
    enrolled_by      INT NULL,
    date_enrolled    DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ENROLL_APPLICANT FOREIGN KEY (applicant_id) 
        REFERENCES dbo.DCSA_APPLICANTS (applicant_id) ON DELETE CASCADE,
    CONSTRAINT FK_ENROLL_CAMPUS FOREIGN KEY (campus_id) 
        REFERENCES dbo.DCSA_CAMPUSES (campus_id),
    CONSTRAINT FK_ENROLL_ADMIN FOREIGN KEY (enrolled_by) 
        REFERENCES dbo.DCSA_ADMIN_ACCOUNTS (admin_id)
);
GO

-- 3.7 ANNOUNCEMENTS TABLE
CREATE TABLE dbo.DCSA_ANNOUNCEMENTS (
    announcement_id INT IDENTITY(1,1) PRIMARY KEY,
    title           VARCHAR(150) NOT NULL,
    content         VARCHAR(MAX) NOT NULL,
    campus_id       INT NULL,
    published_by    INT NOT NULL,
    published_date  DATE DEFAULT CAST(GETDATE() AS DATE),
    is_active       BIT DEFAULT 1 CHECK (is_active IN (0, 1)),
    CONSTRAINT FK_ANN_CAMPUS FOREIGN KEY (campus_id) 
        REFERENCES dbo.DCSA_CAMPUSES (campus_id) ON DELETE CASCADE,
    CONSTRAINT FK_ANN_ADMIN FOREIGN KEY (published_by) 
        REFERENCES dbo.DCSA_ADMIN_ACCOUNTS (admin_id)
);
GO

PRINT '>>> Schema tables created successfully.';
GO

-- ----------------------------------------------------------------------------------
-- STEP 4: INSERT SEED DATA
-- ----------------------------------------------------------------------------------

-- 4.1 CAMPUSES
SET IDENTITY_INSERT dbo.DCSA_CAMPUSES ON;
INSERT INTO dbo.DCSA_CAMPUSES (campus_id, campus_code, campus_name, address, contact_no, email, map_url)
VALUES 
(1, 'FAIR', 'Fairview Campus', 'Fairview Campus, Commonwealth Ave., Quezon City', '0917-111-2233', 'fairview@datamex.edu.ph', 'https://maps.google.com/?q=Datamex+College+of+Saint+Adeline+Fairview+Quezon+City'),
(2, 'CAL', 'Caloocan Campus', '357 J. Teodoro St., Cor 10th Ave., Caloocan City', '0917-222-3344', 'caloocan@datamex.edu.ph', 'https://maps.google.com/?q=357+J.+Teodoro+St+Cor+10th+Ave+Caloocan'),
(3, 'VAL', 'Valenzuela Campus', '2nd Flr. Gotaco Bldg 2, 32 MacArthur Highway, Marulas, Valenzuela City', '0917-333-4455', 'valenzuela@datamex.edu.ph', 'https://maps.google.com/?q=2nd+Flr+Gotaco+Bldg+2+32+MacArthur+Highway+Marulas+Valenzuela'),
(4, 'MEYC', 'Meycauayan Campus', '85 Requino St., Saluysoy, Meycauayan, 3023 Bulacan', '0917-444-5566', 'meycauayan@datamex.edu.ph', 'https://maps.google.com/?q=85+Requino+St+Saluysoy+Meycauayan+Bulacan');
SET IDENTITY_INSERT dbo.DCSA_CAMPUSES OFF;
GO

-- 4.2 ADMIN ACCOUNTS
SET IDENTITY_INSERT dbo.DCSA_ADMIN_ACCOUNTS ON;
INSERT INTO dbo.DCSA_ADMIN_ACCOUNTS (admin_id, username, password_hash, full_name, role, campus_id, email)
VALUES 
(1, 'superadmin', 'password123', 'Central School Administrator', 'SuperAdmin', NULL, 'admin@datamex.edu.ph'),
(2, 'admin', 'password123', 'Head Registrar (Central Admin)', 'SuperAdmin', NULL, 'registrar@datamex.edu.ph'),
(3, 'campusadminval', 'password123', 'Valenzuela Campus Registrar', 'BranchAdmin', 3, 'valenzuela.admin@datamex.edu.ph'),
(4, 'campusadmincal', 'password123', 'Caloocan Campus Registrar', 'BranchAdmin', 2, 'caloocan.admin@datamex.edu.ph'),
(5, 'campusadminmeyc', 'password123', 'Meycauayan Campus Registrar', 'BranchAdmin', 4, 'meycauayan.admin@datamex.edu.ph'),
(6, 'campusadminfair', 'password123', 'Fairview Campus Registrar', 'BranchAdmin', 1, 'fairview.admin@datamex.edu.ph');
SET IDENTITY_INSERT dbo.DCSA_ADMIN_ACCOUNTS OFF;
GO

-- 4.3 ACADEMIC PROGRAMS
SET IDENTITY_INSERT dbo.DCSA_PROGRAMS ON;
INSERT INTO dbo.DCSA_PROGRAMS (program_id, academic_level, program_code, program_name, total_units, tuition_per_unit, lab_fee, misc_fee)
VALUES 
(1, 'College', 'BSIT', 'BSIT - Bachelor of Science in Information Technology', 20, 350.00, 1500.00, 800.00),
(2, 'College', 'BSHM', 'BSHM - Bachelor of Science in Hospitality Management', 21, 350.00, 1800.00, 800.00),
(3, 'College', 'BSBA', 'BSBA - Bachelor of Science in Business Administration', 20, 350.00, 800.00, 800.00),
(4, 'College', 'ACT', 'Associate in Computer Technology (2-Year ACT)', 18, 300.00, 1200.00, 700.00),
(5, 'SHS', 'TVL-ICT', 'TVL-ICT - Information and Communications Technology (DepEd Free Voucher)', 24, 0.00, 0.00, 0.00),
(6, 'SHS', 'ABM', 'ABM - Accountancy, Business, and Management', 22, 0.00, 0.00, 0.00),
(7, 'SHS', 'STEM', 'STEM - Science, Technology, Engineering, and Mathematics', 25, 0.00, 0.00, 0.00),
(8, 'SHS', 'HUMSS', 'HUMSS - Humanities and Social Sciences', 23, 0.00, 0.00, 0.00),
(9, 'SHS', 'GAS', 'GAS - General Academic Strand', 22, 0.00, 0.00, 0.00);
SET IDENTITY_INSERT dbo.DCSA_PROGRAMS OFF;
GO

-- 4.4 CURRICULUM SUBJECTS
SET IDENTITY_INSERT dbo.DCSA_SUBJECTS ON;
INSERT INTO dbo.DCSA_SUBJECTS (subject_id, program_id, subject_code, subject_desc, units, day_schedule, time_schedule, room_lab, instructor)
VALUES 
(1, 1, 'CC101', 'Introduction to Computing', 3, 'Mon / Wed', '08:00 AM - 09:30 AM', 'CL-1 (IT Lab)', 'Prof. A. Santos'),
(2, 1, 'CC102', 'Fundamentals of Programming (C++ / Java)', 3, 'Mon / Wed', '09:30 AM - 11:30 AM', 'CL-2 (Programming Lab)', 'Engr. M. Ramos'),
(3, 1, 'GE01', 'Understanding the Self', 3, 'Tue / Thu', '08:00 AM - 09:30 AM', 'Room 302', 'Dr. C. Mendoza'),
(4, 1, 'GE02', 'Readings in Philippine History', 3, 'Tue / Thu', '09:30 AM - 11:00 AM', 'Room 304', 'Prof. E. Dizon'),
(5, 1, 'MATH01', 'Mathematics in the Modern World', 3, 'Tue / Thu', '01:00 PM - 02:30 PM', 'Room 201', 'Prof. J. Dela Rosa'),
(6, 1, 'PE101', 'Physical Activities Toward Health & Fitness 1', 2, 'Friday', '08:00 AM - 10:00 AM', 'Gymnasium / Quadrangle', 'Coach R. Bautista'),
(7, 1, 'NSTP1', 'National Service Training Program 1 (CWTS)', 3, 'Saturday', '08:00 AM - 11:00 AM', 'AVR / Community Center', 'Col. V. Garcia');
SET IDENTITY_INSERT dbo.DCSA_SUBJECTS OFF;
GO

-- 4.5 APPLICANTS & ENROLLEES
SET IDENTITY_INSERT dbo.DCSA_APPLICANTS ON;
INSERT INTO dbo.DCSA_APPLICANTS (
    applicant_id, reference_no, student_id, first_name, middle_name, last_name, suffix,
    gender, birth_date, age, civil_status, email, contact_no, address,
    guardian_name, guardian_contact, guardian_relation, program_id, campus_id, academic_level,
    entry_type, last_school, voucher_beneficiary, status, notes
) VALUES 
(
    101, 'DCSA-2026-0101', 'DCSA-2026-IT-0042', 'Juan', 'Protacio', 'Dela Cruz', NULL,
    'Male', '2007-06-19', 18, 'Single', 'juan.delacruz@example.com', '09171234567',
    'Block 4 Lot 12, Commonwealth Ave., Quezon City', 'Maria Dela Cruz', '09187654321', 'Mother',
    1, 1, 'College', 'Freshman', 'Commonwealth High School', 'No', 'Approved', 'Submitted Form 138 and PSA Birth Certificate.'
),
(
    102, 'DCSA-2026-0102', 'DCSA-2026-SHS-0118', 'Maria Clara', 'Santos', 'Reyes', NULL,
    'Female', '2009-03-12', 16, 'Single', 'maria.reyes@example.com', '09189876543',
    '152 MacArthur Highway, Marulas, Valenzuela City', 'Roberto Reyes', '09192223344', 'Father',
    5, 3, 'SHS', 'Freshman', 'Valenzuela National High School', 'Yes', 'Enrolled', 'DepEd Voucher Applied. Enrolled via walk-in registrar.'
),
(
    103, 'DCSA-2026-0103', NULL, 'Christian', 'Mendoza', 'Bautista', NULL,
    'Male', '2008-11-25', 17, 'Single', 'christian.bautista@example.com', '09205556677',
    '45 10th Ave., Caloocan City', 'Elena Bautista', '09214443322', 'Mother',
    2, 2, 'College', 'Freshman', 'Caloocan High School', 'No', 'Pending', 'Online applicant awaiting document verification.'
),
(
    104, 'DCSA-2026-0104', NULL, 'Alyssa', 'Joy', 'Gonzales', NULL,
    'Female', '2009-08-05', 16, 'Single', 'alyssa.gonzales@example.com', '09278889900',
    'Saluysoy, Meycauayan, Bulacan', 'Grace Gonzales', '09287776655', 'Mother',
    6, 4, 'SHS', 'Freshman', 'Meycauayan National High School', 'Yes', 'Pending', 'SHS ABM Applicant with complete DepEd ESC voucher.'
);
SET IDENTITY_INSERT dbo.DCSA_APPLICANTS OFF;
GO

-- 4.6 ANNOUNCEMENTS
SET IDENTITY_INSERT dbo.DCSA_ANNOUNCEMENTS ON;
INSERT INTO dbo.DCSA_ANNOUNCEMENTS (announcement_id, title, content, campus_id, published_by, published_date)
VALUES 
(1, 'College & SHS Orientation Schedule for A.Y. 2026-2027', 'Welcome incoming Datamext students! The General Student Orientation will be held this coming Monday at the Campus Auditorium. Morning Session: 8:30 AM (College) | Afternoon Session: 1:30 PM (Senior High School).', NULL, 1, CAST(GETDATE() AS DATE)),
(2, 'Distribution of School Uniforms & ID RFID Cards', 'Official school uniforms, PE kits, and digitized student ID cards are now available for claiming at the Campus Bookstore and Registrar Office. Please bring your Certificate of Registration (COR).', NULL, 1, CAST(GETDATE() AS DATE)),
(3, 'DepEd Voucher Validation Notice for SHS Enrollees', 'All Grade 11 entrants with DepEd vouchers or ESC certificates are requested to submit physical photocopies to the Admissions Office before classes commence.', NULL, 1, CAST(GETDATE() AS DATE));
SET IDENTITY_INSERT dbo.DCSA_ANNOUNCEMENTS OFF;
GO

PRINT '>>> Seed data loaded successfully.';
GO

-- ----------------------------------------------------------------------------------
-- STEP 5: CREATE VIEWS
-- ----------------------------------------------------------------------------------

-- 5.1 Central Summary View
IF OBJECT_ID('dbo.VW_ALL_CAMPUSES_SUMMARY', 'V') IS NOT NULL 
    DROP VIEW dbo.VW_ALL_CAMPUSES_SUMMARY;
GO

CREATE VIEW dbo.VW_ALL_CAMPUSES_SUMMARY AS
SELECT 
    c.campus_code,
    c.campus_name,
    COUNT(a.applicant_id) AS total_applicants,
    SUM(CASE WHEN a.status = 'Pending' THEN 1 ELSE 0 END) AS pending_count,
    SUM(CASE WHEN a.status = 'Approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(CASE WHEN a.status = 'Enrolled' THEN 1 ELSE 0 END) AS enrolled_count
FROM dbo.DCSA_CAMPUSES c
LEFT JOIN dbo.DCSA_APPLICANTS a ON c.campus_id = a.campus_id
GROUP BY c.campus_code, c.campus_name;
GO

-- 5.2 Valenzuela Campus Applicants View
IF OBJECT_ID('dbo.VW_VALENZUELA_APPLICANTS', 'V') IS NOT NULL 
    DROP VIEW dbo.VW_VALENZUELA_APPLICANTS;
GO

CREATE VIEW dbo.VW_VALENZUELA_APPLICANTS AS
SELECT 
    a.applicant_id, 
    a.reference_no, 
    a.student_id,
    (a.first_name + ' ' + a.last_name) AS full_name,
    a.gender, 
    a.email, 
    a.contact_no, 
    a.academic_level,
    p.program_name, 
    a.voucher_beneficiary, 
    a.status,
    a.date_applied, 
    a.notes
FROM dbo.DCSA_APPLICANTS a
INNER JOIN dbo.DCSA_PROGRAMS p ON a.program_id = p.program_id
WHERE a.campus_id = (SELECT campus_id FROM dbo.DCSA_CAMPUSES WHERE campus_code = 'VAL');
GO

-- 5.3 Caloocan Campus Applicants View
IF OBJECT_ID('dbo.VW_CALOOCAN_APPLICANTS', 'V') IS NOT NULL 
    DROP VIEW dbo.VW_CALOOCAN_APPLICANTS;
GO

CREATE VIEW dbo.VW_CALOOCAN_APPLICANTS AS
SELECT 
    a.applicant_id, 
    a.reference_no, 
    a.student_id,
    (a.first_name + ' ' + a.last_name) AS full_name,
    a.gender, 
    a.email, 
    a.contact_no, 
    a.academic_level,
    p.program_name, 
    a.voucher_beneficiary, 
    a.status,
    a.date_applied, 
    a.notes
FROM dbo.DCSA_APPLICANTS a
INNER JOIN dbo.DCSA_PROGRAMS p ON a.program_id = p.program_id
WHERE a.campus_id = (SELECT campus_id FROM dbo.DCSA_CAMPUSES WHERE campus_code = 'CAL');
GO

-- 5.4 Fairview Campus Applicants View
IF OBJECT_ID('dbo.VW_FAIRVIEW_APPLICANTS', 'V') IS NOT NULL 
    DROP VIEW dbo.VW_FAIRVIEW_APPLICANTS;
GO

CREATE VIEW dbo.VW_FAIRVIEW_APPLICANTS AS
SELECT 
    a.applicant_id, 
    a.reference_no, 
    a.student_id,
    (a.first_name + ' ' + a.last_name) AS full_name,
    a.gender, 
    a.email, 
    a.contact_no, 
    a.academic_level,
    p.program_name, 
    a.voucher_beneficiary, 
    a.status,
    a.date_applied, 
    a.notes
FROM dbo.DCSA_APPLICANTS a
INNER JOIN dbo.DCSA_PROGRAMS p ON a.program_id = p.program_id
WHERE a.campus_id = (SELECT campus_id FROM dbo.DCSA_CAMPUSES WHERE campus_code = 'FAIR');
GO

-- 5.5 Meycauayan Campus Applicants View
IF OBJECT_ID('dbo.VW_MEYCAUAYAN_APPLICANTS', 'V') IS NOT NULL 
    DROP VIEW dbo.VW_MEYCAUAYAN_APPLICANTS;
GO

CREATE VIEW dbo.VW_MEYCAUAYAN_APPLICANTS AS
SELECT 
    a.applicant_id, 
    a.reference_no, 
    a.student_id,
    (a.first_name + ' ' + a.last_name) AS full_name,
    a.gender, 
    a.email, 
    a.contact_no, 
    a.academic_level,
    p.program_name, 
    a.voucher_beneficiary, 
    a.status,
    a.date_applied, 
    a.notes
FROM dbo.DCSA_APPLICANTS a
INNER JOIN dbo.DCSA_PROGRAMS p ON a.program_id = p.program_id
WHERE a.campus_id = (SELECT campus_id FROM dbo.DCSA_CAMPUSES WHERE campus_code = 'MEYC');
GO

-- 5.6 Official Enrollees & Billing Summary View
IF OBJECT_ID('dbo.VW_OFFICIAL_ENROLLEES', 'V') IS NOT NULL 
    DROP VIEW dbo.VW_OFFICIAL_ENROLLEES;
GO

CREATE VIEW dbo.VW_OFFICIAL_ENROLLEES AS
SELECT 
    e.enrollment_id,
    e.student_id,
    (a.last_name + ', ' + a.first_name + ISNULL(' ' + a.middle_name, '')) AS student_name,
    c.campus_name,
    p.program_code,
    p.program_name,
    e.academic_year,
    e.semester,
    e.total_units,
    e.assessment_total,
    e.voucher_discount,
    e.balance_due,
    e.date_enrolled,
    adm.full_name AS enrolled_by_admin
FROM dbo.DCSA_ENROLLMENTS e
INNER JOIN dbo.DCSA_APPLICANTS a ON e.applicant_id = a.applicant_id
INNER JOIN dbo.DCSA_CAMPUSES c ON e.campus_id = c.campus_id
INNER JOIN dbo.DCSA_PROGRAMS p ON e.program_id = p.program_id
LEFT JOIN dbo.DCSA_ADMIN_ACCOUNTS adm ON e.enrolled_by = adm.admin_id;
GO

PRINT '>>> Views created successfully.';
GO

-- ----------------------------------------------------------------------------------
-- STEP 6: CREATE STORED PROCEDURES
-- ----------------------------------------------------------------------------------

-- 6.1 SP_AUTHENTICATE_ADMIN
IF OBJECT_ID('dbo.SP_AUTHENTICATE_ADMIN', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.SP_AUTHENTICATE_ADMIN;
GO

CREATE PROCEDURE dbo.SP_AUTHENTICATE_ADMIN
    @Username    VARCHAR(50),
    @Password    VARCHAR(255),
    @Status      VARCHAR(50) OUTPUT,
    @Role        VARCHAR(30) OUTPUT,
    @CampusCode  VARCHAR(20) OUTPUT,
    @FullName    VARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CampusId INT;

    SELECT 
        @FullName = full_name,
        @Role = role,
        @CampusId = campus_id
    FROM dbo.DCSA_ADMIN_ACCOUNTS
    WHERE LOWER(username) = LOWER(@Username)
      AND password_hash = @Password
      AND is_active = 1;

    IF @FullName IS NOT NULL
    BEGIN
        SET @Status = 'SUCCESS';
        IF @Role = 'SuperAdmin' OR @CampusId IS NULL
            SET @CampusCode = 'ALL';
        ELSE
            SELECT @CampusCode = campus_code FROM dbo.DCSA_CAMPUSES WHERE campus_id = @CampusId;
    END
    ELSE
    BEGIN
        SET @Status = 'INVALID';
        SET @Role = NULL;
        SET @CampusCode = NULL;
        SET @FullName = NULL;
    END
END;
GO

-- 6.2 SP_ENROLL_STUDENT
IF OBJECT_ID('dbo.SP_ENROLL_STUDENT', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.SP_ENROLL_STUDENT;
GO

CREATE PROCEDURE dbo.SP_ENROLL_STUDENT
    @ApplicantId INT,
    @AdminId     INT = NULL,
    @StudentId   VARCHAR(30) OUTPUT,
    @Message     VARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Level       VARCHAR(20);
        DECLARE @CampusId    INT;
        DECLARE @ProgramId   INT;
        DECLARE @Prefix      VARCHAR(10);
        DECLARE @NewId       VARCHAR(30);
        DECLARE @TotalUnits  INT;
        DECLARE @Voucher     VARCHAR(10);
        DECLARE @Assessment  DECIMAL(10,2);
        DECLARE @Discount    DECIMAL(10,2);
        DECLARE @Balance     DECIMAL(10,2);

        SET @TotalUnits = 0;
        SET @Assessment = 0.00;
        SET @Discount = 0.00;
        SET @Balance = 0.00;

        SELECT 
            @Level = academic_level,
            @CampusId = campus_id,
            @ProgramId = program_id,
            @Voucher = voucher_beneficiary,
            @NewId = student_id
        FROM dbo.DCSA_APPLICANTS
        WHERE applicant_id = @ApplicantId;

        IF @Level IS NULL
        BEGIN
            SET @Message = 'Applicant ID not found.';
            SET @StudentId = NULL;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF @NewId IS NULL OR LTRIM(RTRIM(@NewId)) = ''
        BEGIN
            IF @Level = 'SHS'
                SET @Prefix = 'SHS';
            ELSE
                SET @Prefix = 'IT';

            SET @NewId = 'DCSA-2026-' + @Prefix + '-' + RIGHT('0000' + CAST(@ApplicantId AS VARCHAR(10)), 4);
        END

        SELECT @TotalUnits = ISNULL(SUM(units), 0)
        FROM dbo.DCSA_SUBJECTS
        WHERE program_id = @ProgramId;

        IF @Level = 'SHS' OR @Voucher = 'Yes'
        BEGIN
            SET @Assessment = 0.00;
            SET @Discount = 9300.00;
            SET @Balance = 0.00;
        END
        ELSE
        BEGIN
            SET @Assessment = (@TotalUnits * 350.00) + 1500.00 + 800.00;
            SET @Discount = 0.00;
            SET @Balance = @Assessment;
        END

        UPDATE dbo.DCSA_APPLICANTS
        SET student_id = @NewId,
            status = 'Enrolled',
            updated_at = GETDATE()
        WHERE applicant_id = @ApplicantId;

        INSERT INTO dbo.DCSA_ENROLLMENTS (
            applicant_id, student_id, campus_id, program_id,
            total_units, assessment_total, voucher_discount, balance_due, enrolled_by
        ) VALUES (
            @ApplicantId, @NewId, @CampusId, @ProgramId,
            @TotalUnits, @Assessment, @Discount, @Balance, @AdminId
        );

        SET @StudentId = @NewId;
        SET @Message = 'Applicant successfully enrolled. Generated Student ID: ' + @NewId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @StudentId = NULL;
        SET @Message = 'Error enrolling student: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

PRINT '>>> Stored procedures created successfully.';
GO

-- ----------------------------------------------------------------------------------
-- STEP 7: VERIFICATION QUERY
-- ----------------------------------------------------------------------------------
PRINT '----------------------------------------------------------------------';
PRINT 'DATABASE SETUP COMPLETED! SAMPLE VERIFICATION:';
PRINT '----------------------------------------------------------------------';

SELECT * FROM dbo.VW_ALL_CAMPUSES_SUMMARY;
SELECT campus_id, campus_code, campus_name, contact_no, email FROM dbo.DCSA_CAMPUSES;
SELECT admin_id, username, full_name, role, campus_id FROM dbo.DCSA_ADMIN_ACCOUNTS;
SELECT applicant_id, reference_no, student_id, first_name, last_name, academic_level, status FROM dbo.DCSA_APPLICANTS;
GO
