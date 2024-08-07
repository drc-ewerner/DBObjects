USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[SaveEnrollmentOrderItem]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [eWeb].[SaveEnrollmentOrderItem]
	@OrderItemID as INT OUTPUT,
	@OrderID as INT,
	@ItemID as INT,
	@Count As INT,
	@Code as VARCHAR(50)
 AS
 BEGIN
	If @Count  IS NULL And @Code  IS NULL
	BEGIN
		DELETE FROM eWeb.EnrollmentOrderItem
		WHERE   OrderID = @OrderID
		AND	ItemID = @ItemID
		SET @OrderItemID = NULL
	END
	ELSE
	BEGIN
		SELECT @OrderItemID = OrderItemID
			FROM eWeb.EnrollmentOrderItem
			WHERE   OrderID = @OrderID
					AND	ItemID = @ItemID
		IF @OrderItemID IS NOT NULL
		BEGIN
			UPDATE eWeb.EnrollmentOrderItem SET
				   [Count] = @Count,
				   [Code] = @Code,
				   LastUpdateDate = GetDate()
			WHERE OrderItemID = @OrderItemID
		END
		ELSE
		BEGIN
			INSERT INTO eWeb.EnrollmentOrderItem (
				OrderID,
				ItemID,
				[Count],
				[Code],
				LastUpdateDate)
			VALUES (
				@OrderID,
				@ItemID,
				@Count,
				@Code,
				GetDate())
			SET @OrderItemID = SCOPE_IDENTITY()
		END
	 END
 END
GO
