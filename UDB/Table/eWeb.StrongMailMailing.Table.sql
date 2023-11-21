USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[StrongMailMailing]    Script Date: 11/21/2023 8:51:36 AM ******/
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
