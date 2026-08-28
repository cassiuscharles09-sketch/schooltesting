# DATAMEXT COLLEGE OF SAINT ADELINE (DCSA) - SQL SERVER (SSMS) DATABASE

Ang directory na ito ay naglalaman ng kumpletong **Microsoft SQL Server (T-SQL)** database scripts para sa DCSA Multi-Campus Admissions, Enrollment, and Student Portal System, na handang-handang i-run sa **SQL Server Management Studio (SSMS)** o **Azure Data Studio**.

---

## 📁 Manifest ng mga SQL Files

1. **`DCSA_SSMS_FULL_SETUP.sql`** *(Pinakamadaling gamitin - All-in-One script)*
   - Isang file lang na naglalaman ng:
     - `CREATE DATABASE DCSA_DB`
     - Lahat ng Table DDLs (`DCSA_CAMPUSES`, `DCSA_ADMIN_ACCOUNTS`, `DCSA_PROGRAMS`, `DCSA_APPLICANTS`, `DCSA_SUBJECTS`, `DCSA_ENROLLMENTS`, `DCSA_ANNOUNCEMENTS`)
     - Lahat ng Seed Data (mga branch, admin accounts, sample enrollees, subjects)
     - Views (`VW_ALL_CAMPUSES_SUMMARY`, `VW_VALENZUELA_APPLICANTS`, atbp.)
     - Stored Procedures (`SP_AUTHENTICATE_ADMIN`, `SP_ENROLL_STUDENT`)
     - Sample verification queries.

2. **Modular Scripts (Kung nais patakbuhin isa-isa):**
   - **`01_schema.sql`**: Table creation, primary keys, identity auto-increment, and foreign key constraints.
   - **`02_seed_data.sql`**: Initial data insertion na may `IDENTITY_INSERT` settings.
   - **`03_procedures_views.sql`**: T-SQL Stored Procedures at Campus-Scoped Views.

---

## 🚀 Paano Patakbuhin sa SQL Server Management Studio (SSMS)

### Option A: All-In-One Execution (Mabilis at Madali)
1. Buksan ang **SQL Server Management Studio (SSMS)**.
2. Mag-connect sa iyong SQL Server instance (halimbawa: `localhost`, `.\SQLEXPRESS`, o `(localdb)\MSSQLLocalDB`).
3. I-click ang **File -> Open -> File...** (o i-drag and drop) ang file na:
   ```
   d:\schoolweb\database\DCSA_SSMS_FULL_SETUP.sql
   ```
4. I-click ang **Execute** button o pindutin ang **F5**.
5. May lalabas na message: `DATABASE SETUP COMPLETED!` kasama ang mga query verification results.

### Option B: Step-by-Step Execution
1. Buksan at i-execute ang `01_schema.sql` (Gagawa ng database at tables).
2. Buksan at i-execute ang `02_seed_data.sql` (Maglalagay ng default campus, admin, at sample applicants).
3. Buksan at i-execute ang `03_procedures_views.sql` (Gagawa ng mga views at stored procedures).

---

## 🔑 Default Accounts na Naka-seed sa Database:

| Username | Password | Role | Campus / Access |
| :--- | :--- | :--- | :--- |
| `superadmin` | `password123` | SuperAdmin | Lahat ng 4 Campuses (Fairview, Caloocan, Valenzuela, Meycauayan) |
| `admin` | `password123` | SuperAdmin | Lahat ng 4 Campuses (Head Registrar) |
| `campusadminval` | `password123` | BranchAdmin | Valenzuela Campus Registrar |
| `campusadmincal` | `password123` | BranchAdmin | Caloocan Campus Registrar |
| `campusadminmeyc` | `password123` | BranchAdmin | Meycauayan Campus Registrar |
| `campusadminfair` | `password123` | BranchAdmin | Fairview Campus Registrar |
