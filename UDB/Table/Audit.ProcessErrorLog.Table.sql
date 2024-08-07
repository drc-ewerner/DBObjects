USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[ProcessErrorLog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ProcessErrorLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[LogTime] [datetime] NOT NULL,
	[Process] [varchar](200) NULL,
	[ItemKey] [varchar](8000) NULL,
	[Version] [bigint] NULL,
	[VersionRow] [int] NULL,
	[Error] [varchar](max) NULL,
	[ClearTime] [datetime] NULL,
 CONSTRAINT [pk_ProcessErrorLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[ProcessErrorLog] ADD  DEFAULT (getdate()) FOR [LogTime]
GO
ALTER TABLE [Audit].[ProcessErrorLog] ADD  DEFAULT (NULL) FOR [ClearTime]
GO
