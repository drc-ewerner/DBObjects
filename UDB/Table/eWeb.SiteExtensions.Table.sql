USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[SiteExtensions]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[SiteExtensions](
	[AdministrationID] [int] NOT NULL,
	[DistrictCode] [varchar](10) NOT NULL,
	[SchoolCode] [varchar](10) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DistrictCode] ASC,
	[SchoolCode] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
