USE [Alaska_udb_dev]
GO
/****** Object:  Table [Core].[Administration]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[Administration](
	[AdministrationID] [int] NOT NULL,
	[AdministrationCode] [varchar](10) NOT NULL,
	[AdministrationName] [varchar](100) NULL,
	[Season] [varchar](20) NULL,
	[Year] [varchar](10) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[Status] [varchar](50) NULL,
	[Description] [varchar](50) NULL,
	[LongDescription] [varchar](400) NULL,
	[MasterAdministrationID] [int] NULL,
	[StateCode] [varchar](10) NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_Administration] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Core].[Administration] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Core].[Administration] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
