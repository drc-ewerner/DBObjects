USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveEnrollmentCustomizedQuestionAnswer]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[SaveEnrollmentCustomizedQuestionAnswer]
    @OrderId		int
    ,@QuestionID    int
	,@Answer		varchar(500)

/*  *****************************************************************
    * Description:  Save enrollment customized question answer for 
    *               a specified order. It should be consumed by save 
	*				enrollment order proc.
    *================================================================
*/

AS
BEGIN
	IF LEN(@Answer) > 0
	BEGIN
		UPDATE [eWeb].[EnrollmentOrderQuestionAnswer]
		   SET [Answer] = @Answer
		WHERE [OrderID] = @OrderId AND [QuestionID] = @QuestionID

		IF @@ROWCOUNT = 0
		INSERT INTO [eWeb].[EnrollmentOrderQuestionAnswer]
				   ([OrderID],[QuestionID],[Answer])
			 VALUES
				   (@OrderId, @QuestionID, @Answer)
	END
	ELSE
	BEGIN
		DELETE FROM [eWeb].[EnrollmentOrderQuestionAnswer]
		WHERE [OrderID] = @OrderId AND [QuestionID] = @QuestionID
	END
	
END
GO
