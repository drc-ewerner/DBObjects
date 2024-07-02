USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[StrongMailMailing]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[StrongMailMailing](
	[StateCode] [varchar](4) NULL,
	[Environment] [varchar](20) NOT NULL,
	[EmailType] [varchar](30) NOT NULL,
	[MailingID] [varchar](30) NOT NULL
) ON [PRIMARY]
GO
