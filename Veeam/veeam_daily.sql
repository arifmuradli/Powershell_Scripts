SELECT 
    js.job_name AS [Job Name],
    
    CASE js.job_type
        WHEN 0     THEN 'Backup'
        WHEN 12000 THEN 'Windows Agent Backup'
        WHEN 12002 THEN 'Windows Agent Policy'
        WHEN 12005 THEN 'Rescan'
        WHEN 4000  THEN 'Windows Agent Backup (legacy?)'
        WHEN 27    THEN 'Tape Inventory'
        WHEN 28    THEN 'Backup to Tape'
        WHEN 24    THEN 'File to Tape Backup'
        WHEN 13000 THEN 'File Backup'
        ELSE CAST(js.job_type AS varchar(10)) + ' (unknown)'
    END AS [Job Type],
    
    js.creation_time AS [Start Time],
    js.end_time      AS [End Time],
    
    CASE js.result
        WHEN 0 THEN 'Success'
        WHEN 1 THEN 'Warning'
        WHEN 2 THEN 'Failed'
        ELSE 'Other (' + CAST(js.result AS varchar(5)) + ')'
    END AS [Result],
    
    CASE WHEN js.run_manually = 1 THEN 'Yes' ELSE 'No' END AS [Manual],
    
    -- Replace NULL reason with empty string
    ISNULL(js.reason, '') AS [Reason],
    
    ISNULL(js.initiator_name, 'System / Scheduled') AS [Initiated By]
    
FROM 
    "Backup.Model.JobSessions" js WITH (NOLOCK)
    
WHERE 
    js.end_time >= DATEADD(HOUR, -24, GETDATE())
    AND js.end_time IS NOT NULL
    AND js.job_type NOT IN (19, 21, 12003, 12006, 502, 10000, 10001, 22000, 23000, 31000, 32000)
    
ORDER BY 
    -- Priority: Failed (2) → Warning (1) → Success (0) → Other
    CASE js.result
        WHEN 2 THEN 1    -- Failed
        WHEN 1 THEN 2    -- Warning
        WHEN 0 THEN 3    -- Success
        ELSE 4           -- Other
    END,
    js.end_time DESC;    -- Newest finished first within same result
