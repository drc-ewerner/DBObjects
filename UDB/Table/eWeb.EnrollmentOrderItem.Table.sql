USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentOrderItem]    Script Date: 1/12/2022 1:28:44 PM ******/
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
 CONSTRAINT [PK_EnrollmentOrderLine] PRIMARY KEY CLUSTERED 
(
	[OrderItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem] ADD  CONSTRAINT [DF_EnrollmentOrderLine_LastUpdateDate]  DEFAULT (getdate()) FOR [LastUpdateDate]
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem]  WITH CHECK ADD  CONSTRAINT [FK_EnrollmentOrderLine_EnrollmentItem] FOREIGN KEY([ItemID])
REFERENCES [eWeb].[EnrollmentItem] ([ItemID])
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem] CHECK CONSTRAINT [FK_EnrollmentOrderLine_EnrollmentItem]
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem]  WITH CHECK ADD  CONSTRAINT [FK_EnrollmentOrderLine_EnrollmentOrder] FOREIGN KEY([OrderID])
REFERENCES [eWeb].[EnrollmentOrder] ([OrderID])
GO
ALTER TABLE [eWeb].[EnrollmentOrderItem] CHECK CONSTRAINT [FK_EnrollmentOrderLine_EnrollmentOrder]
GO
