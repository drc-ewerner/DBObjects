USE [Alaska_udb_dev]
GO
/****** Object:  Table [TestSession].[History]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [TestSession].[History](
	[AdministrationID] [int] NOT NULL,
	[TestSessionID] [int] NOT NULL,
	[TestSessionHistoryID] [int] IDENTITY(1,1) NOT NULL,
	[CreateDate] [datetime] NULL,
	[UserID] [uniqueidentifier] NULL,
	[Source] [varchar](20) NULL,
	[TestSessionXml] [xml] NULL,
 CONSTRAINT [pk_History] PRIMARY KEY CLUSTERED 
(
	[TestSessionHistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
