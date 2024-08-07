USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[RCD_AuditDetail]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[RCD_AuditDetail](
	[AdministrationID] [int] NOT NULL,
	[AuditSummaryID] [int] NOT NULL,
	[AuditDetailID] [int] NOT NULL,
	[ClassName] [varchar](500) NULL,
	[Version] [varchar](100) NULL,
	[Name] [varchar](500) NULL,
	[Description] [varchar](500) NULL,
	[Required] [varchar](1) NULL,
	[Selected] [varchar](1) NULL,
	[UserInteraction] [varchar](1) NULL,
	[Status] [varchar](50) NULL,
	[InfoMessage] [varchar](max) NULL,
	[Client] [varchar](1) NULL,
	[Installer] [varchar](1) NULL,
	[EtestClient] [varchar](1) NULL,
 CONSTRAINT [pk_RCD_AuditDetail] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[AuditSummaryID] ASC,
	[AuditDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Insight].[RCD_AuditDetail]  WITH CHECK ADD  CONSTRAINT [fk_RCD_AuditDetail_RCD_AuditSummary] FOREIGN KEY([AdministrationID], [AuditSummaryID])
REFERENCES [Insight].[RCD_AuditSummary] ([AdministrationID], [AuditSummaryID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Insight].[RCD_AuditDetail] CHECK CONSTRAINT [fk_RCD_AuditDetail_RCD_AuditSummary]
GO
