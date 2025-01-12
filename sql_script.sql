-- File: testing_and_corrections.sql
-- This script tests for unauthorized access, overlapping permissions, and logs corrections for data inconsistencies.

-- Detect unauthorized access
-- Files accessed by users who are not authorized
SELECT cp.FileName, cp.CurrentUser
FROM CurrentPermissions cp
LEFT JOIN FilePermissions fp 
    ON cp.FileName = fp.FileName AND cp.CurrentUser = fp.AuthorizedUser
WHERE fp.AuthorizedUser IS NULL;

-- Detect overlapping permissions
-- Files with more than one user assigned
SELECT FileName, COUNT(CurrentUser) AS OverlapCount
FROM CurrentPermissions
GROUP BY FileName
HAVING COUNT(CurrentUser) > 1;

-- View overlapping users for each file
SELECT FileName, CurrentUser
FROM CurrentPermissions
WHERE FileName IN (
    SELECT FileName
    FROM CurrentPermissions
    GROUP BY FileName
    HAVING COUNT(CurrentUser) > 1
);

-- Log corrections
-- Example: Correct unauthorized access and log the action
INSERT INTO CorrectionLogs (FileName, UserName, Action, PreviousState, CurrentState)
SELECT cp.FileName, cp.CurrentUser, 'Revoke Access', 'Unauthorized', 'Access Revoked'
FROM CurrentPermissions cp
LEFT JOIN FilePermissions fp 
    ON cp.FileName = fp.FileName AND cp.CurrentUser = fp.AuthorizedUser
WHERE fp.AuthorizedUser IS NULL;

-- Remove unauthorized users from CurrentPermissions
DELETE FROM CurrentPermissions
WHERE FileName IN (
    SELECT cp.FileName
    FROM CurrentPermissions cp
    LEFT JOIN FilePermissions fp 
        ON cp.FileName = fp.FileName AND cp.CurrentUser = fp.AuthorizedUser
    WHERE fp.AuthorizedUser IS NULL
);

-- Test corrections
-- View logs of all corrections made
SELECT * FROM CorrectionLogs;

-- Add unique constraint to prevent overlapping permissions in the future
ALTER TABLE CurrentPermissions
ADD CONSTRAINT UniqueFileUser UNIQUE (FileName, CurrentUser);
