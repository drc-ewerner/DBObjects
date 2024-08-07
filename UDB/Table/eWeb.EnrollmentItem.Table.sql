USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[EnrollmentItem]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[EnrollmentItem](
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[AdminID] [int] NOT NULL,
	[Description] [varchar](50) NULL,
	[AttributeName] [varchar](25) NULL,
	[AppletCode] [varchar](10) NULL,
 CONSTRAINT [pk_EnrollmentItem] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
