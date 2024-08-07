USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [Service].[update_accommodations_for_ticket]    Script Date: 7/2/2024 9:21:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Service].[update_accommodations_for_ticket]
@administrationId int,
@studentId int,
@test varchar(50),
@incoming varchar(max)
as set xact_abort on;

declare @i table(category varchar(50),name varchar(50),value varchar(1000));

insert @i (category,name,value)
select distinct m.category,name=coalesce(x.name,y.name,z.name),m.value
from openjson(@incoming,'$.accommodations') with (subject varchar(50),name varchar(50)) z
join xref.cedsmap m on m.cedsGroup='Accommodation' and m.cedsValue=z.subject and m.category=(select contentArea from scoring.tests where administrationId=@administrationId and test=@test)
outer apply (select name from xref.studentextensionnames x where x.administrationId=@administrationId and x.category=m.category and x.name=z.name+'.*') x
outer apply (select name from xref.cedsmap y where y.cedsGroup='Accommodation.'+z.name and y.cedsValue='*') y;

merge student.extensions t
using @i i on @administrationId=t.administrationId and @studentId=t.studentId and i.category=t.category and i.name=t.name
when matched then
update set value=i.value
when not matched then insert (administrationid,studentid,category,name,value) values (@administrationid,@studentid,i.category,i.name,i.value);

delete x
from student.extensions x
where administrationId=@administrationId and studentId=@studentId
and category=(select contentArea from scoring.tests t where t.administrationId=@administrationId and t.test=@test)
and not exists(select * from @i i where i.category=x.category and i.name=x.name);
GO
