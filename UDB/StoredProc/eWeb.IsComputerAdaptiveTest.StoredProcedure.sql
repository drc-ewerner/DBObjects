USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[IsComputerAdaptiveTest]    Script Date: 1/12/2022 1:30:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [eWeb].[IsComputerAdaptiveTest]
    @AdministrationID int
   ,@Test nvarchar(50)
   ,@Level nvarchar(20)
AS
BEGIN

  Declare @Format varchar(100)
  
  Select 
  @Format = Max([Format]) 
  From [Scoring].[TestForms]
  Where [AdministrationID] = @AdministrationID
  And [Test] = @Test
  And [Level] =@Level
  
  Return case when @Format='CAT' then 1 else 0 end
END
GO
