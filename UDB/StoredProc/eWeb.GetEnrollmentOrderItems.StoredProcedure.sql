USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetEnrollmentOrderItems]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [eWeb].[GetEnrollmentOrderItems] 
	@AdminID INT, @AppletCode VARCHAR(10), @OrderID INT
AS
BEGIN
	SELECT eoi.OrderItemID, ei.ItemID, ei.AdminID, ei.[Description], ei.AttributeName, ed.Name, edo.Value, eoi.[Count], eoi.Code
	FROM eWeb.EnrollmentItem ei
	INNER JOIN eWeb.EnrollmentItemDimensionOption eido ON eido.ItemID = ei.ItemID
	INNER JOIN eWeb.EnrollmentDimensionOption edo ON edo.DimensionOptionID = eido.DimensionOptionID
	INNER JOIN eWeb.EnrollmentDimension ed ON ed.DimensionID = edo.DimensionID
	LEFT OUTER JOIN eWeb.EnrollmentOrderItem eoi ON eoi.ItemID = ei.ItemID AND eoi.OrderID = @OrderID
	WHERE ei.AdminID = @AdminID AND ei.AppletCode = @AppletCode
END

GO
