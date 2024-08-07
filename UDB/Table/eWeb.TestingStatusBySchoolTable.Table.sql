USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TestingStatusBySchoolTable]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TestingStatusBySchoolTable](
	[AdministrationID] [int] NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[Subject] [varchar](50) NOT NULL,
	[Grade] [varchar](2) NOT NULL,
	[TestDate] [date] NOT NULL,
	[DistrictName] [varchar](50) NULL,
	[SchoolName] [varchar](50) NULL,
	[TestsStarted] [int] NULL,
	[TestsEnded] [int] NULL,
 CONSTRAINT [pk_TestingStatusBySchoolTable] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DistrictCode] ASC,
	[SchoolCode] ASC,
	[Subject] ASC,
	[Grade] ASC,
	[TestDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
