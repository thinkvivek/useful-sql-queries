--1. Finding Text in Stored Procedures

SELECT OBJECT_NAME(id)
FROM syscomments
WHERE [text] LIKE '%Text%'
GROUP BY OBJECT_NAME(id)

--2. Finding Tables with Specific Column Name

SELECT COLUMN_NAME, TABLE_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%Column Name%'

--3. To search a string within procedures, views, and functions

SELECT DISTINCT sch.name + '.' + obj.name AS Object_Name, obj.type_desc
FROM sys.sql_modules modl
INNER JOIN sys.objects  obj ON modl.object_id = obj.object_id
INNER JOIN sys.schemas  sch ON obj.schema_id = sch.schema_id
WHERE modl.definition Like '%Text%'
--AND obj.Type='P'  --<uncomment if you only want to search procedures>
ORDER BY 1

--4. Check for Running Jobs

SELECT sj.name, sja.*
FROM msdb.dbo.sysjobactivity AS sja
INNER JOIN msdb.dbo.sysjobs AS sj ON sja.job_id = sj.job_id
WHERE sja.start_execution_date IS NOT NULL
AND sja.stop_execution_date IS NULL

--5. Check execute permissions on procedures

SELECT s.name AS SchemaName,
o.name AS ObjectName,
dp.name AS PrincipalName,
dperm.type AS PermissionType,
dperm.permission_name AS PermissionName,
dperm.state AS PermissionState,
dperm.state_desc AS PermissionStateDescription
FROM sys.objects o
INNER JOIN sys.schemas s on o.schema_id = s.schema_id
INNER JOIN sys.database_permissions dperm ON o.object_id = dperm.major_id
INNER JOIN sys.database_principals dp 
ON dperm.grantee_principal_id = dp.principal_id
WHERE dperm.class = 1 --object or column
AND dperm.type = 'EX'
AND dp.name = 'username'
AND o.name = 'object_name'

--6. To check the blocking sessions

SELECT 
    r.session_id AS blocked_session_id,
    r.blocking_session_id,
    s.login_name,
    s.host_name,
    r.status,
    r.wait_type,
    r.wait_time,
    r.wait_resource,
    r.command,
    st.text AS sql_text
FROM sys.dm_exec_requests r
INNER JOIN sys.dm_exec_sessions s 
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;

SELECT 
    r.session_id,
    r.blocking_session_id,
    s.login_name,
    s.host_name,
    r.status,
    r.command,
    r.wait_type,
    r.wait_time,
    st.text AS sql_text
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s 
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE r.session_id IN (
    SELECT blocking_session_id 
    FROM sys.dm_exec_requests 
    WHERE blocking_session_id <> 0
)
OR r.blocking_session_id <> 0
ORDER BY r.blocking_session_id, r.session_id;

-- ROOT Blockers

WITH blocking_tree AS (
    SELECT 
        session_id,
        blocking_session_id
    FROM sys.dm_exec_requests
)
SELECT DISTINCT session_id
FROM blocking_tree
WHERE session_id NOT IN (
    SELECT session_id 
    FROM blocking_tree 
    WHERE blocking_session_id <> 0
);

-- Blocker + Blocked + SQL Text

SELECT 
    r.session_id AS blocked_session_id,
    r.blocking_session_id AS blocking_session_id,
    blocked_s.login_name AS blocked_login,
    blocked_s.host_name AS blocked_host,
    blocking_s.login_name AS blocking_login,
    blocking_s.host_name AS blocking_host,
    r.status,
    r.wait_type,
    r.wait_time,
    r.wait_resource,
    blocked_txt.text AS blocked_query,
    blocking_txt.text AS blocking_query
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions blocked_s 
    ON r.session_id = blocked_s.session_id
LEFT JOIN sys.dm_exec_sessions blocking_s 
    ON r.blocking_session_id = blocking_s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) blocked_txt
OUTER APPLY sys.dm_exec_sql_text(
    (SELECT sql_handle 
     FROM sys.dm_exec_requests 
     WHERE session_id = r.blocking_session_id)
) blocking_txt
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;
