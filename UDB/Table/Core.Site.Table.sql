USE [Alaska_udb_dev]
GO
/****** Object:  Table [Core].[Site]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Core].[Site](
	[AdministrationID] [int] NOT NULL,
	[SiteID] [uniqueidentifier] NOT NULL,
	[SiteCode] [varchar](15) NOT NULL,
	[SiteName] [varchar](50) NOT NULL,
	[StatusID] [uniqueidentifier] NULL,
	[Status] [varchar](25) NULL,
	[LevelID] [tinyint] NULL,
	[SiteTypeID] [uniqueidentifier] NULL,
	[SiteType] [varchar](35) NULL,
	[ClientSiteType] [varchar](35) NULL,
	[SiteSubType] [varchar](35) NULL,
	[ChildCount] [int] NULL,
	[MaterialShipToFlag] [bit] NOT NULL,
	[ReportShipToFlag] [bit] NOT NULL,
	[EarlyReturnPriorityLevel] [tinyint] NULL,
	[ShippingEstimate] [int] NULL,
	[SuperSiteCode] [varchar](15) NULL,
	[SuperSiteID] [uniqueidentifier] NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_Site] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[SiteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [uq_Site] UNIQUE NONCLUSTERED 
(
	[AdministrationID] ASC,
	[SiteCode] ASC,
	[SuperSiteCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Core].[Site] ADD  DEFAULT ((0)) FOR [MaterialShipToFlag]
GO
ALTER TABLE [Core].[Site] ADD  DEFAULT ((0)) FOR [ReportShipToFlag]
GO
ALTER TABLE [Core].[Site] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Core].[Site] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
