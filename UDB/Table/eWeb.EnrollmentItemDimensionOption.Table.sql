USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentItemDimensionOption]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentItemDimensionOption](
	[ItemDimensionOptionID] [int] IDENTITY(1,1) NOT NULL,
	[ItemID] [int] NULL,
	[DimensionOptionID] [int] NULL,
 CONSTRAINT [pk_EnrollmentItemDimensionOption] PRIMARY KEY CLUSTERED 
(
	[ItemDimensionOptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentItemDimensionOption]  WITH CHECK ADD  CONSTRAINT [fk_EnrollmentItemDimensionOption_EnrollmentDimensionOption] FOREIGN KEY([DimensionOptionID])
REFERENCES [eWeb].[EnrollmentDimensionOption] ([DimensionOptionID])
GO
ALTER TABLE [eWeb].[EnrollmentItemDimensionOption] CHECK CONSTRAINT [fk_EnrollmentItemDimensionOption_EnrollmentDimensionOption]
GO
ALTER TABLE [eWeb].[EnrollmentItemDimensionOption]  WITH CHECK ADD  CONSTRAINT [fk_EnrollmentItemDimensionOption_EnrollmentItem] FOREIGN KEY([ItemID])
REFERENCES [eWeb].[EnrollmentItem] ([ItemID])
GO
ALTER TABLE [eWeb].[EnrollmentItemDimensionOption] CHECK CONSTRAINT [fk_EnrollmentItemDimensionOption_EnrollmentItem]
GO
