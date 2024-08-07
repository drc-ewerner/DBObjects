USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveMaterialsOrder]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [eWeb].[SaveMaterialsOrder]
       @OrderID as INT OUTPUT,
       @AdminID as INT,
       @StatusID as INT,
       @DistrictCode char(15),
       @SchoolCode char(15),
       @AppletCode as varchar(10) = 'EVS',
       @FirstName as varchar(30) = '',
       @LastName as varchar(30) = '',
       @EmailAddress as varchar(256) = ''
AS
BEGIN
    SELECT @OrderID = OrderID FROM eWeb.EnrollmentOrder
                                  WHERE   AdminID = @AdminID
                                         AND    DistrictCode = @DistrictCode
                                         AND SchoolCode = @SchoolCode
                                         AND AppletCode = @AppletCode
	END
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
                     LastUpdateDate,
                     AppletCode)
              VALUES
                     (@AdminID,
                     @StatusID,
                     @DistrictCode,
                     @SchoolCode,
                     GetDate(),
                     @AppletCode)
 
              SET @OrderID = SCOPE_IDENTITY()
             
      END

	IF (@StatusID = 3 AND  eWeb.GetConfigExtensionValue(@adminID,'eWeb','ConfigUI.EnrollmentsMultipleCompletesReportingEnable', 'N')='Y')
		INSERT INTO eWeb.EnrollmentOrderCompletes
		(AdminID,
		OrderID,
		FirstName,
		LastName,
		EmailAddress, 
		LastUpdateDate)
		Values
		(@AdminID,
		@OrderID,
		@FirstName,
		@LastName,
		@EmailAddress,
		GetDate()
		)
 
	IF ((@FirstName <> '' OR @LastName <> '' OR @EmailAddress <> '') AND @StatusID = 3)
BEGIN
		UPDATE eWeb.EnrollmentOrder SET 
				  FirstName = @FirstName,
				  LastName = @LastName,
				  EmailAddress = @EmailAddress
		WHERE OrderID = @OrderID 

	END
GO
