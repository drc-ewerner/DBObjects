USE [Alaska_udb_dev]
GO
/****** Object:  View [Q].[t]    Script Date: 7/2/2024 9:18:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [Q].[t] as 
select test,level,form,status=case when nottestedcode='Canceled' then 'Canceled' else status end,standard=isnull(standard,externalformid),administrationid,studentid,documentid,createdate,r=registrationid,p=participantid,ef=externalformid,statestudentid,starttime,endtime,updatedate,districtcode,schoolcode,standard0,rpf=registrationid+':'+participantid+':'+externalformid
from q.tt q
outer apply (select standard=value from document.extensions x where x.administrationid=q.administrationid and x.documentid=q.documentid and x.name='standardformatted') standard
outer apply (select standard0=value from document.extensions x where x.administrationid=q.administrationid and x.documentid=q.documentid and x.name='standard') standard0
GO
