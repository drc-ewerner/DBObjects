USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentQuestion]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentQuestion](
	[QuestionID] [int] IDENTITY(1,1) NOT NULL,
	[AdminID] [int] NOT NULL,
	[SiteType] [varchar](35) NOT NULL,
	[Description] [varchar](500) NOT NULL,
	[AppletCode] [varchar](10) NOT NULL,
 CONSTRAINT [pk_EnrollmentQuestion] PRIMARY KEY CLUSTERED 
(
	[QuestionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[EnrollmentQuestion] ADD  DEFAULT ('EVS') FOR [AppletCode]
GO
