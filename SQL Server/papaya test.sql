select * from [SQLPAPAYANEW].[VRDBWMS].[dbo].[SO];

select * from [SQLPAPAYANEW].[VRDBWMS].[dbo].[PO];

select distinct PONUMBER from [SQLPAPAYANEW].[VRDBWMS].[dbo].[PO];

select distinct itemnumber, itemname,SONUMBER from [SQLPAPAYANEW].[VRDBWMS].[dbo].[SO];


select distinct itemnumber, itemname, PONUMBER from [SQLPAPAYANEW].[VRDBWMS].[dbo].[PO];