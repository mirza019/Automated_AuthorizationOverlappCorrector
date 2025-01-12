
### Power Automate Flow: Authorization and Overlap Management

#### Steps:
1. **Trigger**:
   - Use a Recurrence trigger to run the flow daily at 9:00 AM.

2. **Get Files**:
   - Use the 'Get files (properties only)' action to fetch files from the SharePoint library.

3. **Retrieve Permissions**:
   - Use the 'Send an HTTP request to SharePoint' action to get file permissions.

4. **Compare Permissions**:
   - Query Azure SQL to fetch authorized users for each file.
   - Log unauthorized access in the CorrectionLogs table.

5. **Correct Permissions**:
   - Use 'Stop sharing an item or folder' to revoke unauthorized access.
   - Use 'Grant access to an item or folder' to add missing access.

6. **Generate Report**:
   - Query the CorrectionLogs table to fetch corrections for the day.
   - Format the report and send it via email.
