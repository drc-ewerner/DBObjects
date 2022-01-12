USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[RCD_AuditSummary]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[RCD_AuditSummary](
	[AdministrationID] [int] NOT NULL,
	[AuditSummaryID] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [varchar](250) NOT NULL,
	[DistrictCode] [varchar](15) NULL,
	[DistrictName] [varchar](100) NULL,
	[SchoolName] [varchar](100) NULL,
	[MachineName] [varchar](250) NULL,
	[LastExecuteDate] [datetime] NULL,
	[Mode] [varchar](50) NULL,
	[GlobalPass] [varchar](1) NULL,
	[StopOnError] [varchar](1) NULL,
	[BuildVersion] [varchar](100) NULL,
	[InstallerDirectory] [varchar](500) NULL,
	[CreateDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[AuditSummaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[RCD_AuditSummary] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
