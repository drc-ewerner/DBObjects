USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebAdministration]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebAdministration](
	[AdministrationID] [int] NOT NULL,
	[AdministrationCode] [varchar](10) NOT NULL,
	[AdministrationName] [varchar](100) NOT NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[UdbConnectionStringName] [varchar](100) NOT NULL,
	[InteractiveReportDate] [datetime] NULL,
	[SeqNo] [int] NOT NULL,
	[StateDbConnectionStringName] [varchar](100) NOT NULL,
	[IsParentAdministration] [bit] NOT NULL,
	[ParentAdministrationId] [int] NOT NULL,
	[StateCode] [varchar](2) NULL,
 CONSTRAINT [PK_Administration] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebAdministration] ADD  DEFAULT ('StateDb.01') FOR [StateDbConnectionStringName]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Administration Code (normally 6 digits)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'eWebAdministration', @level2type=N'COLUMN',@level2name=N'AdministrationCode'
GO
