USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentOrderItem]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentOrderItem](
	[OrderItemID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NULL,
	[ItemID] [int] NULL,
	[Count] [int] NULL,
	[LastUpdateDate] [datetime] NULL,
	[Code] [varchar](50) NULL,
 CONSTRAINT [pk_EnrollmentOrderItem] PRIMARY KEY CLUSTERED 
(
	[OrderItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem] ADD  CONSTRAINT [DF_EnrollmentOrderLine_LastUpdateDate]  DEFAULT (getdate()) FOR [LastUpdateDate]
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem]  WITH CHECK ADD  CONSTRAINT [fk_EnrollmentOrderItem_EnrollmentItem] FOREIGN KEY([ItemID])
REFERENCES [eWeb].[EnrollmentItem] ([ItemID])
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem] CHECK CONSTRAINT [fk_EnrollmentOrderItem_EnrollmentItem]
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem]  WITH CHECK ADD  CONSTRAINT [fk_EnrollmentOrderItem_EnrollmentOrder] FOREIGN KEY([OrderID])
REFERENCES [eWeb].[EnrollmentOrder] ([OrderID])
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem] CHECK CONSTRAINT [fk_EnrollmentOrderItem_EnrollmentOrder]
GO
