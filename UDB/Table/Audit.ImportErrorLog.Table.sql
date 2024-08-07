USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[ImportErrorLog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ImportErrorLog](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[LogTime] [datetime] NOT NULL,
	[RequestID] [varchar](100) NULL,
	[MessageID] [varchar](100) NULL,
	[Service] [varchar](100) NULL,
	[Method] [varchar](100) NULL,
	[Data] [varchar](max) NULL,
	[Attributes] [varchar](max) NULL,
	[Error] [varchar](max) NULL,
 CONSTRAINT [pk_ImportErrorLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[ImportErrorLog] ADD  DEFAULT (getdate()) FOR [LogTime]
GO
