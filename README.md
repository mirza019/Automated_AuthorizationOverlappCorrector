
# Authorization and Overlap Management System

This project automates the identification and correction of unauthorized access and overlapping roles in SharePoint.

## Features
1. Detect unauthorized access to files and folders.
2. Identify overlapping permissions.
3. Automatically correct permissions in SharePoint.
4. Generate and email daily correction reports.

## Setup Instructions
1. Deploy the SQL script provided in 'sql_script.sql' to Azure SQL.
2. Set up SharePoint as documented in 'sharepoint_setup.md'.
3. Configure Power Automate using the steps in 'power_automate.md'.

## Future Enhancements
- Add Power BI dashboards for real-time monitoring.
- Maintain detailed audit logs in SQL.
