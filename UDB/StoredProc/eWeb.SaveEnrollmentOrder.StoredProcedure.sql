USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveEnrollmentOrder]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [eWeb].[SaveEnrollmentOrder]
	@OrderID as INT OUTPUT,
	@AdminID as INT,
	@StatusID as INT,
	@DistrictCode char(15),
	@SchoolCode char(15)
AS

BEGIN
	SELECT @OrderID = OrderID FROM eWeb.EnrollmentOrder 
					WHERE   AdminID = @AdminID
						AND	DistrictCode = @DistrictCode
						AND SchoolCode = @SchoolCode

	IF @OrderID IS NOT NULL
	BEGIN
		UPDATE eWeb.EnrollmentOrder SET 
			  StatusID = @StatusID,
			  LastUpdateDate = GetDate()
		WHERE @OrderID = OrderID 		
		
	END
	ELSE
	BEGIN
		INSERT INTO eWeb.EnrollmentOrder
			(AdminID,
			StatusID,
			DistrictCode,
			SchoolCode,
			LastUpdateDate)
		VALUES
			(@AdminID,
			@StatusID,
			@DistrictCode,
			@SchoolCode,
			GetDate())

		SET @OrderID = SCOPE_IDENTITY()
	END
	 
END
GO
