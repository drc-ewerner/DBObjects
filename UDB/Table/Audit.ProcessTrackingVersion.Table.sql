USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[ProcessTrackingVersion]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ProcessTrackingVersion](
	[Process] [varchar](200) NOT NULL,
	[CurrentVersion] [bigint] NOT NULL,
	[CurrentVersionRow] [int] NOT NULL,
	[Options] [xml] NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
	[ExData] [xml] NULL,
	[CurrentKey] [nvarchar](max) NULL,
	[State] [nvarchar](max) NULL,
 CONSTRAINT [pk_ProcessTrackingVersion] PRIMARY KEY CLUSTERED 
(
	[Process] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[ProcessTrackingVersion] ADD  DEFAULT ((1)) FOR [CurrentVersion]
GO
ALTER TABLE [Audit].[ProcessTrackingVersion] ADD  DEFAULT ((0)) FOR [CurrentVersionRow]
GO
ALTER TABLE [Audit].[ProcessTrackingVersion] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Audit].[ProcessTrackingVersion] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
