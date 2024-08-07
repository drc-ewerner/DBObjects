USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetSubTestLevels]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*  *****************************************************************
    * Description:  This proc returns a list of SubTestLevels
    *================================================================
    * Created:      ?
    * Developer:    ?
    *================================================================
    * Changes:
    *
	* Date:         12/21/18
    * Developer:    Priya Srinivasan
    * Description:  Added join to core.testsession and selected test from that
 
    *****************************************************************
*/


		CREATE PROC [eWeb].[GetSubTestLevels]
			    @AdminID INT
			  , @TestSessionID INT
		AS
		BEGIN
			SELECT stl.AdministrationID, stl.TestSessionID, ts.Test, SubTest, SubLevel 
			FROM TestSession.SubTestLevels stl
				JOIN Core.TestSession ts
				ON stl.AdministrationID = ts.AdministrationID
					AND stl.TestSessionID = ts.TestSessionID
			WHERE stl.TestSessionID = @TestSessionID AND stl.AdministrationID = @AdminID
		END
;
GO
