USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentDimensionOption]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentDimensionOption](
	[DimensionOptionID] [int] IDENTITY(1,1) NOT NULL,
	[DimensionID] [int] NULL,
	[Value] [varchar](50) NULL,
 CONSTRAINT [pk_EnrollmentDimensionOption] PRIMARY KEY CLUSTERED 
(
	[DimensionOptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentDimensionOption]  WITH CHECK ADD  CONSTRAINT [fk_EnrollmentDimensionOption_EnrollmentDimension] FOREIGN KEY([DimensionID])
REFERENCES [eWeb].[EnrollmentDimension] ([DimensionID])
GO
ALTER TABLE [eWeb].[EnrollmentDimensionOption] CHECK CONSTRAINT [fk_EnrollmentDimensionOption_EnrollmentDimension]
GO
