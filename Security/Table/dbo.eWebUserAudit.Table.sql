USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUserAudit]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebUserAudit](
	[UserAuditId] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [uniqueidentifier] NOT NULL,
	[ChangedBy] [uniqueidentifier] NOT NULL,
	[Logdate] [datetime] NOT NULL,
 CONSTRAINT [PK_eWebUserAudit] PRIMARY KEY CLUSTERED 
(
	[UserAuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebUserAudit] ADD  CONSTRAINT [DF_eWebUserAudit_Logdate]  DEFAULT (getdate()) FOR [Logdate]
GO
