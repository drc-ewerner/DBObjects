USE [Alaska_udb_dev]
GO
/****** Object:  Table [Site].[TestWindows]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Site].[TestWindows](
	[AdministrationID] [int] NOT NULL,
	[DistrictCode] [varchar](15) NOT NULL,
	[SchoolCode] [varchar](15) NOT NULL,
	[TestWindow] [varchar](20) NOT NULL,
 CONSTRAINT [pk_TestWindows] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DistrictCode] ASC,
	[SchoolCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Site].[TestWindows]  WITH CHECK ADD  CONSTRAINT [fk_TestWindows_Admin_TestWindow] FOREIGN KEY([AdministrationID], [TestWindow])
REFERENCES [Admin].[TestWindow] ([AdministrationID], [TestWindow])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Site].[TestWindows] CHECK CONSTRAINT [fk_TestWindows_Admin_TestWindow]
GO
