USE [Alaska_udb_dev]
GO
/****** Object:  Table [Document].[TierOverrideLog]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Document].[TierOverrideLog](
	[AdministrationID] [int] NOT NULL,
	[DocumentID] [int] NOT NULL,
	[LogTime] [datetime] NOT NULL,
	[Tier] [varchar](50) NOT NULL,
 CONSTRAINT [pk_TierOverrideLog] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[DocumentID] ASC,
	[LogTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Document].[TierOverrideLog] ADD  DEFAULT (getdate()) FOR [LogTime]
GO
ALTER TABLE [Document].[TierOverrideLog]  WITH CHECK ADD  CONSTRAINT [fk_TierOverrideLog_TestTicket] FOREIGN KEY([AdministrationID], [DocumentID])
REFERENCES [Document].[TestTicket] ([AdministrationID], [DocumentID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Document].[TierOverrideLog] CHECK CONSTRAINT [fk_TierOverrideLog_TestTicket]
GO
