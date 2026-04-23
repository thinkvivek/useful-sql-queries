-- Search keyword across procedures + packages (with object metadata)

SELECT 
    o.owner,
    o.object_name,
    o.object_type,
    o.status,
    o.last_ddl_time,
    s.line,
    s.text
FROM dba_objects o
JOIN dba_source s
    ON o.owner = s.owner
   AND o.object_name = s.name
   AND o.object_type = s.type
WHERE o.owner = 'YOUR_SCHEMA'
  AND o.object_type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
  AND UPPER(s.text) LIKE UPPER('%YOUR_KEYWORD%')
ORDER BY o.object_name, s.line;

-- Searching CLOB column

SELECT *
FROM your_table
WHERE DBMS_LOB.INSTR(UPPER(clob_column), UPPER('keyword')) > 0;

SELECT *
FROM your_table
WHERE REGEXP_LIKE(TO_CHAR(clob_column), 'your_pattern', 'i');

-- Date Comparisons

WHERE date_col = TO_DATE('23-04-2026', 'DD-MM-YYYY')

-- To view Indexes and Constraints

SELECT 
    'INDEX' AS object_type,
    index_name AS name,
    status
FROM dba_indexes
WHERE owner = 'YOUR_SCHEMA'
  AND table_name = 'YOUR_TABLE'

UNION ALL

SELECT 
    constraint_type,
    constraint_name,
    status
FROM dba_constraints
WHERE owner = 'YOUR_SCHEMA'
  AND table_name = 'YOUR_TABLE';

-- Active Sessions

SELECT 
    s.sid,
    s.serial#,
    s.username,
    s.status,
    s.machine,
    q.sql_text
FROM v$session s
LEFT JOIN v$sql q 
    ON s.sql_id = q.sql_id
WHERE s.status = 'ACTIVE';

-- Blocking Sessions

SELECT 
    a.sid AS blocked_sid,
    a.blocking_session,
    a.event,
    a.wait_class,
    q.sql_text
FROM v$session a
LEFT JOIN v$sql q ON a.sql_id = q.sql_id
WHERE a.blocking_session IS NOT NULL;

-- SQL Behind a session

SELECT 
    s.sid,
    s.serial#,
    q.sql_text
FROM v$session s
JOIN v$sql q ON s.sql_id = q.sql_id
WHERE s.sid = :SID;
