USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[SiteSchedule]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[SiteSchedule](
	[AdministrationID] [int] NOT NULL,
	[SiteScheduleID] [int] IDENTITY(1,1) NOT NULL,
	[TestingScheduleID] [int] NOT NULL,
	[DistrictCode] [varchar](10) NOT NULL,
	[SchoolCode] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[SiteScheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[SiteSchedule]  WITH CHECK ADD  CONSTRAINT [eWeb_SiteSchedule_eWeb_TestingSchedule] FOREIGN KEY([AdministrationID], [TestingScheduleID])
REFERENCES [eWeb].[TestingSchedule] ([AdministrationID], [TestingScheduleID])
GO
ALTER TABLE [eWeb].[SiteSchedule] CHECK CONSTRAINT [eWeb_SiteSchedule_eWeb_TestingSchedule]
GO
