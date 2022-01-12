USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[MailingMapping]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[MailingMapping](
	[StateCode] [varchar](4) NOT NULL,
	[Environment] [varchar](30) NOT NULL,
	[EmailType] [varchar](50) NOT NULL,
	[TemplateID] [varchar](50) NOT NULL,
	[CreatedOn] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[MailingMapping] ADD  CONSTRAINT [DF_MailingMapping_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
