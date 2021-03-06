USE [Alaska_udb_dev]
GO
/****** Object:  Table [Teacher].[Sites]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Teacher].[Sites](
	[AdministrationID] [int] NOT NULL,
	[TeacherID] [int] NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TeacherID] ASC,
	[DistrictCode] ASC,
	[SchoolCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Teacher].[Sites]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [TeacherID])
REFERENCES [Core].[Teacher] ([AdministrationID], [TeacherID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
