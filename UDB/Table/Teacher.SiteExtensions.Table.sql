USE [Alaska_udb_dev]
GO
/****** Object:  Table [Teacher].[SiteExtensions]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Teacher].[SiteExtensions](
	[AdministrationID] [int] NOT NULL,
	[TeacherID] [int] NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Value] [varchar](100) NULL,
 CONSTRAINT [pk_SiteExtensions] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[TeacherID] ASC,
	[DistrictCode] ASC,
	[SchoolCode] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Teacher].[SiteExtensions]  WITH CHECK ADD  CONSTRAINT [fk_SiteExtensions_Sites] FOREIGN KEY([AdministrationID], [TeacherID], [DistrictCode], [SchoolCode])
REFERENCES [Teacher].[Sites] ([AdministrationID], [TeacherID], [DistrictCode], [SchoolCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Teacher].[SiteExtensions] CHECK CONSTRAINT [fk_SiteExtensions_Sites]
GO
