USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetAccommodationContentAreas]    Script Date: 11/21/2023 8:56:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*  *****************************************************************
    * Description:  
    *================================================================
    * Created:      1/27/2015
    * Developer:   
    *================================================================
    * Changes: Updating proc so that it is consistent across clients
    *
    * Date:  1/27/2015        
    * Developer:    Julie Cheah
    * Description:  
    *****************************************************************
*/


CREATE PROCEDURE [eWeb].[GetAccommodationContentAreas]
@AdministrationID INT,
@Grade varchar(2) = NULL  
AS
select distinct ca.ContentArea 
from Scoring.Tests t
join Scoring.ContentAreas ca on t.AdministrationID = ca.AdministrationID and t.ContentArea = ca.ContentArea
where ca.AdministrationID=@AdministrationID and ca.ContentArea is not null and ca.ContentArea not like '$%'
and ca.IsForAccommodations = 1
and not exists(select * from Config.Extensions ext where AdministrationID=@AdministrationID and Category='eWeb' and Name=ca.ContentArea + '.Hide' and Value='Y')


GO
