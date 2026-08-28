-- ====================================================================
-- DATAMEXT COLLEGE OF SAINT ADELINE (DCSA)
-- SEED DATA SCRIPT: MICROSOFT SQL SERVER (T-SQL / SSMS Compatible)
-- Inserts: Campuses, Admin Accounts, Programs, Subjects, Sample Applicants & Announcements
-- ====================================================================

USE DCSA_DB;
GO

-- 1. INSERT CAMPUS BRANCHES
SET IDENTITY_INSERT dbo.DCSA_CAMPUSES ON;

INSERT INTO dbo.DCSA_CAMPUSES (campus_id, campus_code, campus_name, address, contact_no, email, map_url)
VALUES 
(1, 'FAIR', 'Fairview Campus', 'Fairview Campus, Commonwealth Ave., Quezon City', '0917-111-2233', 'fairview@datamex.edu.ph', 'https://maps.google.com/?q=Datamex+College+of+Saint+Adeline+Fairview+Quezon+City'),
(2, 'CAL', 'Caloocan Campus', '357 J. Teodoro St., Cor 10th Ave., Caloocan City', '0917-222-3344', 'caloocan@datamex.edu.ph', 'https://maps.google.com/?q=357+J.+Teodoro+St+Cor+10th+Ave+Caloocan'),
(3, 'VAL', 'Valenzuela Campus', '2nd Flr. Gotaco Bldg 2, 32 MacArthur Highway, Marulas, Valenzuela City', '0917-333-4455', 'valenzuela@datamex.edu.ph', 'https://maps.google.com/?q=2nd+Flr+Gotaco+Bldg+2+32+MacArthur+Highway+Marulas+Valenzuela'),
(4, 'MEYC', 'Meycauayan Campus', '85 Requino St., Saluysoy, Meycauayan, 3023 Bulacan', '0917-444-5566', 'meycauayan@datamex.edu.ph', 'https://maps.google.com/?q=85+Requino+St+Saluysoy+Meycauayan+Bulacan');

SET IDENTITY_INSERT dbo.DCSA_CAMPUSES OFF;
GO

-- 2. INSERT ADMIN ACCOUNTS
SET IDENTITY_INSERT dbo.DCSA_ADMIN_ACCOUNTS ON;

-- Super Administrator (Central Head - Full Access across all campuses)
INSERT INTO dbo.DCSA_ADMIN_ACCOUNTS (admin_id, username, password_hash, full_name, role, campus_id, email)
VALUES 
(1, 'superadmin', 'password123', 'Central School Administrator', 'SuperAdmin', NULL, 'admin@datamex.edu.ph'),
(2, 'admin', 'password123', 'Head Registrar (Central Admin)', 'SuperAdmin', NULL, 'registrar@datamex.edu.ph');

-- Campus Branch Registrars (Locked per branch)
INSERT INTO dbo.DCSA_ADMIN_ACCOUNTS (admin_id, username, password_hash, full_name, role, campus_id, email)
VALUES 
(3, 'campusadminval', 'password123', 'Valenzuela Campus Registrar', 'BranchAdmin', 3, 'valenzuela.admin@datamex.edu.ph'),
(4, 'campusadmincal', 'password123', 'Caloocan Campus Registrar', 'BranchAdmin', 2, 'caloocan.admin@datamex.edu.ph'),
(5, 'campusadminmeyc', 'password123', 'Meycauayan Campus Registrar', 'BranchAdmin', 4, 'meycauayan.admin@datamex.edu.ph'),
(6, 'campusadminfair', 'password123', 'Fairview Campus Registrar', 'BranchAdmin', 1, 'fairview.admin@datamex.edu.ph');

SET IDENTITY_INSERT dbo.DCSA_ADMIN_ACCOUNTS OFF;
GO

-- 3. INSERT ACADEMIC PROGRAMS
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

-- 4. INSERT CURRICULUM SUBJECTS (BSIT Sample)
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

-- 5. INSERT SAMPLE APPLICANTS (Demonstration Records)
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

-- 6. INSERT ANNOUNCEMENTS
SET IDENTITY_INSERT dbo.DCSA_ANNOUNCEMENTS ON;

INSERT INTO dbo.DCSA_ANNOUNCEMENTS (announcement_id, title, content, campus_id, published_by, published_date)
VALUES 
(1, 'College & SHS Orientation Schedule for A.Y. 2026-2027', 'Welcome incoming Datamext students! The General Student Orientation will be held this coming Monday at the Campus Auditorium. Morning Session: 8:30 AM (College) | Afternoon Session: 1:30 PM (Senior High School).', NULL, 1, CAST(GETDATE() AS DATE)),
(2, 'Distribution of School Uniforms & ID RFID Cards', 'Official school uniforms, PE kits, and digitized student ID cards are now available for claiming at the Campus Bookstore and Registrar Office. Please bring your Certificate of Registration (COR).', NULL, 1, CAST(GETDATE() AS DATE)),
(3, 'DepEd Voucher Validation Notice for SHS Enrollees', 'All Grade 11 entrants with DepEd vouchers or ESC certificates are requested to submit physical photocopies to the Admissions Office before classes commence.', NULL, 1, CAST(GETDATE() AS DATE));

SET IDENTITY_INSERT dbo.DCSA_ANNOUNCEMENTS OFF;
GO

PRINT '>>> DCSA Seed Data Successfully Loaded in SSMS.';
GO
