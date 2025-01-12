-- ==========================================
-- STEP 1: Verify Logins in MASTER Database
-- ==========================================
-- Check if the required logins exist
USE master;
GO

-- Verify logins
SELECT name AS LoginName, type_desc AS LoginType
FROM sys.server_principals
WHERE name IN ('EngineeringLogin', 'HRLogin', 'FinanceLogin', 'ITLogin', 'OperationsLogin');

-- Create missing logins
CREATE LOGIN EngineeringLogin WITH PASSWORD = 'Engineering@2025!' CHECK_POLICY = ON;
CREATE LOGIN HRLogin WITH PASSWORD = 'HR@2025!' CHECK_POLICY = ON;
CREATE LOGIN FinanceLogin WITH PASSWORD = 'Finance@2025!' CHECK_POLICY = ON;
CREATE LOGIN ITLogin WITH PASSWORD = 'IT@2025!' CHECK_POLICY = ON;
CREATE LOGIN OperationsLogin WITH PASSWORD = 'Operations@2025!' CHECK_POLICY = ON;
GO

-- ==========================================
-- STEP 2: Verify and Correct Users in WORFORCDB Database
-- ==========================================
-- Ensure the required users exist and are associated with the correct logins
USE worforcdb;
GO

-- Verify users
SELECT name AS UserName, type_desc AS UserType
FROM sys.database_principals
WHERE name IN ('EngineeringUser', 'HRUser', 'FinanceUser', 'ITUser', 'OperationsUser');

-- Create missing users
CREATE USER EngineeringUser FOR LOGIN EngineeringLogin;
CREATE USER HRUser FOR LOGIN HRLogin;
CREATE USER FinanceUser FOR LOGIN FinanceLogin;
CREATE USER ITUser FOR LOGIN ITLogin;
CREATE USER OperationsUser FOR LOGIN OperationsLogin;
GO

-- ==========================================
-- STEP 3: Grant Permissions (Reapply as Needed)
-- ==========================================
-- Grant appropriate permissions to each user
GRANT SELECT, INSERT, UPDATE, DELETE ON Departments TO EngineeringUser;
GRANT SELECT, INSERT, UPDATE ON Employees TO HRUser;
GRANT SELECT, INSERT ON Projects TO FinanceUser;
GRANT SELECT, UPDATE ON Tasks TO ITUser;
GRANT SELECT ON SCHEMA::dbo TO OperationsUser; -- OperationsUser is read-only
GO

-- ==========================================
-- STEP 4: Insert Extended Test Data
-- ==========================================
-- Add more records to test with larger datasets

-- Insert into Departments
INSERT INTO Departments (DepartmentName) VALUES
('Engineering Dept'), ('HR Dept'), ('Finance Dept'), ('IT Dept'), ('Operations Dept');

-- Insert into Employees
INSERT INTO Employees (EmployeeName, Email, Phone, Salary, DepartmentID) VALUES
('John Doe', 'john.doe@example.com', '1234567890', 3200, 1),
('Jane Smith', 'jane.smith@example.com', '0987654321', 4500, 2),
('Emma Johnson', 'emma.johnson@example.com', '5555555555', 3000, 3),
('Chris Brown', 'chris.brown@example.com', '4444444444', 5000, 4),
('Patricia Miller', 'patricia.miller@example.com', '3333333333', 4000, 5);

-- Insert into Projects
INSERT INTO Projects (ProjectName, DepartmentID) VALUES
('Project A', 1), ('Project B', 2), ('Project C', 3), ('Project D', 4), ('Project E', 5);

-- Insert into Tasks
INSERT INTO Tasks (TaskName, EmployeeID, ProjectID, DueDate, Status) VALUES
('Task 1', 1, 1, '2025-01-15', 'Pending'),
('Task 2', 2, 2, '2025-02-01', 'Completed'),
('Task 3', 3, 3, '2025-03-10', 'Pending'),
('Task 4', 4, 4, '2025-01-20', 'Completed'),
('Task 5', 5, 5, '2025-01-25', 'Pending');
GO

-- ==========================================
-- STEP 5: Test and Validate Permissions
-- ==========================================
-- Test each user's ability to perform the granted actions

-- Test EngineeringUser: Should insert, update, delete, and select from Departments
EXECUTE AS USER = 'EngineeringUser';
INSERT INTO Departments (DepartmentName) VALUES ('Engineering Test Dept');
UPDATE Departments SET DepartmentName = 'Updated Dept' WHERE DepartmentName = 'Engineering Test Dept';
DELETE FROM Departments WHERE DepartmentName = 'Updated Dept';
SELECT * FROM Departments; -- Verify changes
REVERT;

-- Test HRUser: Should update Employees but not delete
EXECUTE AS USER = 'HRUser';
UPDATE Employees SET Phone = '9999999999' WHERE EmployeeName = 'John Doe'; -- Should succeed
DELETE FROM Employees WHERE EmployeeName = 'John Doe'; -- Should fail
SELECT * FROM Employees; -- Verify update
REVERT;

-- Test FinanceUser: Should insert and select Projects
EXECUTE AS USER = 'FinanceUser';
INSERT INTO Projects (ProjectName, DepartmentID) VALUES ('Finance Test Project', 3); -- Should succeed
SELECT * FROM Projects; -- Verify insert
REVERT;

-- Test ITUser: Should update Tasks but not delete
EXECUTE AS USER = 'ITUser';
UPDATE Tasks SET Status = 'Completed' WHERE TaskName = 'Task 3'; -- Should succeed
DELETE FROM Tasks WHERE TaskName = 'Task 3'; -- Should fail
SELECT * FROM Tasks; -- Verify update
REVERT;

-- Test OperationsUser: Should only select data
EXECUTE AS USER = 'OperationsUser';
SELECT * FROM Departments; -- Should succeed
INSERT INTO Departments (DepartmentName) VALUES ('Unauthorized Dept'); -- Should fail
REVERT;

-- ==========================================
-- STEP 6: Advanced Permission Checks
-- ==========================================
-- Check if users have permissions they shouldn't

-- Verify if HRUser has unwanted access to Departments
SELECT HAS_PERMS_BY_NAME('Departments', 'OBJECT', 'INSERT') AS HRUserCanInsert;

-- Verify if OperationsUser can delete from Tasks
SELECT HAS_PERMS_BY_NAME('Tasks', 'OBJECT', 'DELETE') AS OperationsUserCanDelete;

-- Verify if ITUser has read-only access to Employees (Should be false)
SELECT HAS_PERMS_BY_NAME('Employees', 'OBJECT', 'SELECT') AS ITUserCanSelect;
GO

-- ==========================================
-- STEP 7: Final Permissions Audit
-- ==========================================
-- Re-check all granted permissions for audit purposes
SELECT dp.name AS UserName,
       p.permission_name AS PermissionName,
       p.state_desc AS PermissionState,
       o.name AS ObjectName,
       o.type_desc AS ObjectType
FROM sys.database_permissions p
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects o ON p.major_id = o.object_id
WHERE dp.name IN ('EngineeringUser', 'HRUser', 'FinanceUser', 'ITUser', 'OperationsUser');
GO
