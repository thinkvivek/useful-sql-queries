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