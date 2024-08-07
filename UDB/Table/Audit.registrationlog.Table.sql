USE [Alaska_udb_dev]
GO
/****** Object:  Table [Audit].[registrationlog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[registrationlog](
	[logId] [bigint] NOT NULL,
	[logTime] [datetime] NOT NULL,
	[registrationId] [varchar](100) NOT NULL,
	[participantId] [varchar](100) NOT NULL,
	[assessmentId] [varchar](100) NOT NULL,
	[form] [varchar](100) NOT NULL,
	[action] [varchar](100) NOT NULL,
	[messageId] [varchar](100) NULL,
	[receiveCount] [int] NULL,
	[status] [varchar](100) NULL,
	[administrationId] [int] NULL,
	[testSessionId] [int] NULL,
	[studentId] [int] NULL,
	[documentId] [int] NULL,
	[data] [varchar](max) NULL,
	[lastError] [varchar](max) NULL,
	[lastErrorTime] [datetime] NULL,
 CONSTRAINT [pk_registrationlog] PRIMARY KEY CLUSTERED 
(
	[registrationId] ASC,
	[participantId] ASC,
	[assessmentId] ASC,
	[form] ASC,
	[logId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[registrationlog] ADD  DEFAULT (NEXT VALUE FOR [audit].[registrationlog_seq]) FOR [logId]
GO
ALTER TABLE [Audit].[registrationlog] ADD  DEFAULT (getdate()) FOR [logTime]
GO
