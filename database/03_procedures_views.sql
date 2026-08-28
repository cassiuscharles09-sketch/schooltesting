-- ====================================================================
-- DATAMEXT COLLEGE OF SAINT ADELINE (DCSA)
-- STORED PROCEDURES & ROLE-BASED VIEWS: MICROSOFT SQL SERVER (T-SQL)
-- Fully compatible with all SQL Server / SSMS versions (2008 to 2022+)
-- ====================================================================

USE DCSA_DB;
GO

-- ====================================================================
-- 1. ROLE-BASED CAMPUS SCOPED VIEWS
-- ====================================================================

-- 1.1 Central Summary View (Super Admin)
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

-- 1.2 Valenzuela Campus Applicants View
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

-- 1.3 Caloocan Campus Applicants View
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

-- 1.4 Fairview Campus Applicants View
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

-- 1.5 Meycauayan Campus Applicants View
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

-- 1.6 Official Enrollees & Billing Summary View
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

-- ====================================================================
-- 2. T-SQL STORED PROCEDURES
-- ====================================================================

-- 2.1 Authenticate Admin with Role and Campus Scope Check
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
        BEGIN
            SET @CampusCode = 'ALL';
        END
        ELSE
        BEGIN
            SELECT @CampusCode = campus_code
            FROM dbo.DCSA_CAMPUSES
            WHERE campus_id = @CampusId;
        END
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

-- 2.2 Officially Enroll Applicant & Generate Student ID
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

        -- Check applicant
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

        -- Generate student ID if not yet generated
        IF @NewId IS NULL OR LTRIM(RTRIM(@NewId)) = ''
        BEGIN
            IF @Level = 'SHS'
                SET @Prefix = 'SHS';
            ELSE
                SET @Prefix = 'IT';

            SET @NewId = 'DCSA-2026-' + @Prefix + '-' + RIGHT('0000' + CAST(@ApplicantId AS VARCHAR(10)), 4);
        END

        -- Calculate units
        SELECT @TotalUnits = ISNULL(SUM(units), 0)
        FROM dbo.DCSA_SUBJECTS
        WHERE program_id = @ProgramId;

        -- Calculate assessment & voucher discount
        IF @Level = 'SHS' OR @Voucher = 'Yes'
        BEGIN
            SET @Assessment = 0.00;
            SET @Discount = 9300.00; -- Covered by DepEd Senior High Voucher
            SET @Balance = 0.00;
        END
        ELSE
        BEGIN
            SET @Assessment = (@TotalUnits * 350.00) + 1500.00 + 800.00;
            SET @Discount = 0.00;
            SET @Balance = @Assessment;
        END

        -- Update applicant status
        UPDATE dbo.DCSA_APPLICANTS
        SET student_id = @NewId,
            status = 'Enrolled',
            updated_at = GETDATE()
        WHERE applicant_id = @ApplicantId;

        -- Insert official enrollment
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

PRINT '>>> DCSA Views & Stored Procedures Created Successfully in SSMS.';
GO
