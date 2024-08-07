USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[IsComputerAdaptiveTest]    Script Date: 7/2/2024 9:21:54 AM ******/
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
