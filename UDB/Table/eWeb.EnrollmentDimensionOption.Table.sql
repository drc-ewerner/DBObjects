USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentDimensionOption]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentDimensionOption](
	[DimensionOptionID] [int] IDENTITY(1,1) NOT NULL,
	[DimensionID] [int] NULL,
	[Value] [varchar](50) NULL,
 CONSTRAINT [PK_EnrollmentDimensionOptions] PRIMARY KEY CLUSTERED 
(
	[DimensionOptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentDimensionOption]  WITH CHECK ADD  CONSTRAINT [FK_EnrollmentDimensionOptions_EnrollmentDimension] FOREIGN KEY([DimensionID])
REFERENCES [eWeb].[EnrollmentDimension] ([DimensionID])
GO
ALTER TABLE [eWeb].[EnrollmentDimensionOption] CHECK CONSTRAINT [FK_EnrollmentDimensionOptions_EnrollmentDimension]
GO
