SELECT SONUMBER, integrationstatuswms
FROM   SQLPAPAYA11020.VRDBWMSPROD.dbo.SO where CREATEDDATE between '2023-01-30 00:00:00.000' and
'2023-01-30 23:00:00.000' -- and integrationstatuswms='None'
group by SONUMBER,integrationstatuswms

SELECT *
FROM   SQLPAPAYA11020.VRDBWMSPROD.dbo.SO where CREATEDDATE between '2023-01-30 00:00:00.000' and
'2023-01-30 23:00:00.000'
order by CREATEDDATE desc
-- and integrationstatuswms='None'
--group by SONUMBER,integrationstatuswms