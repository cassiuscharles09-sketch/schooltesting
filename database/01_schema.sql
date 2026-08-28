-- ====================================================================
-- DATAMEXT COLLEGE OF SAINT ADELINE (DCSA)
-- DATABASE SCHEMA: MICROSOFT SQL SERVER (T-SQL / SSMS Compatible)
-- Compatibility: SQL Server 2008 / 2012 / 2014 / 2016 / 2019 / 2022 / Express
-- Description: Multi-Campus Admissions, Enrollment & Student Portal System
-- ====================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'DCSA_DB')
BEGIN
    CREATE DATABASE DCSA_DB;
END
GO

USE DCSA_DB;
GO

-- ====================================================================
-- DROP EXISTING TABLES (In correct dependency order)
-- ====================================================================
IF OBJECT_ID('dbo.DCSA_ENROLLMENTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_ENROLLMENTS;
IF OBJECT_ID('dbo.DCSA_ANNOUNCEMENTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_ANNOUNCEMENTS;
IF OBJECT_ID('dbo.DCSA_APPLICANTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_APPLICANTS;
IF OBJECT_ID('dbo.DCSA_SUBJECTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_SUBJECTS;
IF OBJECT_ID('dbo.DCSA_PROGRAMS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_PROGRAMS;
IF OBJECT_ID('dbo.DCSA_ADMIN_ACCOUNTS', 'U') IS NOT NULL DROP TABLE dbo.DCSA_ADMIN_ACCOUNTS;
IF OBJECT_ID('dbo.DCSA_CAMPUSES', 'U') IS NOT NULL DROP TABLE dbo.DCSA_CAMPUSES;
GO

-- ====================================================================
-- TABLES DEFINITION (DDL)
-- ====================================================================

-- 1. CAMPUS BRANCHES TABLE
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

-- 2. ADMIN ACCOUNTS TABLE
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

-- 3. ACADEMIC PROGRAMS & STRANDS TABLE
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

-- 4. APPLICANTS & ENROLLEES TABLE
CREATE TABLE dbo.DCSA_APPLICANTS (
    applicant_id        INT IDENTITY(100,1) PRIMARY KEY,
    reference_no        VARCHAR(30) NOT NULL UNIQUE,
    student_id          VARCHAR(30) NULL, -- Filtered unique index below to allow multiple NULLs
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

-- Filtered Unique Index for student_id (Enables UNIQUE only when student_id IS NOT NULL)
CREATE UNIQUE NONCLUSTERED INDEX UQ_DCSA_APPLICANTS_STUDENT_ID 
ON dbo.DCSA_APPLICANTS(student_id) 
WHERE student_id IS NOT NULL;
GO

-- 5. SUBJECTS / CURRICULUM TABLE
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

-- 6. OFFICIAL ENROLLMENT RECORDS
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

-- 7. ANNOUNCEMENTS TABLE
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

PRINT '>>> DCSA MS SQL Server Schema Created Successfully in SSMS.';
GO
