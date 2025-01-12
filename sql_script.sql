
-- Create the FilePermissions table
CREATE TABLE FilePermissions (
    FileID INT IDENTITY PRIMARY KEY,
    FileName NVARCHAR(255) NOT NULL,
    AuthorizedUser NVARCHAR(255) NOT NULL
);

-- Create the CurrentPermissions table
CREATE TABLE CurrentPermissions (
    FileID INT NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    CurrentUser NVARCHAR(255) NOT NULL
);

-- Create the CorrectionLogs table
CREATE TABLE CorrectionLogs (
    LogID INT IDENTITY PRIMARY KEY,
    FileName NVARCHAR(255) NOT NULL,
    UserName NVARCHAR(255) NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    PreviousState NVARCHAR(255) NOT NULL,
    CurrentState NVARCHAR(255) NOT NULL,
    Timestamp DATETIME DEFAULT GETDATE()
);

-- Insert initial data into FilePermissions
INSERT INTO FilePermissions (FileName, AuthorizedUser) VALUES 
('ProjectPlan.docx', 'admin@example.com'),
('Budget.xlsx', 'manager@example.com');

-- Insert current permissions for testing
INSERT INTO CurrentPermissions (FileName, CurrentUser) VALUES 
('ProjectPlan.docx', 'admin@example.com'),
('Budget.xlsx', 'user@example.com'); -- Unauthorized

-- Example query to detect unauthorized access
SELECT cp.FileName, cp.CurrentUser
FROM CurrentPermissions cp
LEFT JOIN FilePermissions fp ON cp.FileName = fp.FileName AND cp.CurrentUser = fp.AuthorizedUser
WHERE fp.AuthorizedUser IS NULL;

-- Example query to detect overlapping permissions
SELECT FileName, CurrentUser
FROM CurrentPermissions
GROUP BY FileName, CurrentUser
HAVING COUNT(*) > 1;
