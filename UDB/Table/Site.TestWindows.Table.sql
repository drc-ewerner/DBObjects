USE [Alaska_udb_dev]
GO
/****** Object:  Table [Site].[TestWindows]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Site].[TestWindows](
	[AdministrationID] [int] NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[TestWindow] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DistrictCode] ASC,
	[SchoolCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Site].[TestWindows]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [TestWindow])
REFERENCES [Admin].[TestWindow] ([AdministrationID], [TestWindow])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
