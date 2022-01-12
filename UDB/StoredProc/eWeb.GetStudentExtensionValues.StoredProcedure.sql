USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetStudentExtensionValues]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [eWeb].[GetStudentExtensionValues]
@AdministrationID INT
AS
begin
	/* 09/02/2010 - Version 1.0 */
	/* 2/3/2011   - Removed hardcoded demographic values - Steve */
	/* 8/28/2012  - Added DisplayOrder - Chris */
	/* 1/29/2014  - Updated to exclude rows with negative Display Order values for accommodations ---Munish */ 
	/* 11/3/2015  - Updated to include ControlType and MaxLength */
	
	select distinct sn.Category, sn.Name, sn.DisplayName, sv.Value, sv.DisplayValue, sn.DisplayOrder as NameSeqNo, sv.DisplayOrder as ValueSeqNo
		, sn.ControlType, sn.[MaxLength]
	from Xref.StudentExtensionNames sn
	inner join Xref.StudentExtensionValues sv on sn.AdministrationID=sv.AdministrationID and sn.Name=sv.Name
	where sn.AdministrationID=@AdministrationID
	and ((sn.Category in (select ContentArea from Scoring.Tests) and isnull(sn.DisplayOrder,0) >= 0)
		 or sn.Category = 'Demographic')
end
GO
