USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[TestForms]    Script Date: 1/12/2022 1:28:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[TestForms](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Level] [varchar](20) NOT NULL,
	[Form] [varchar](20) NOT NULL,
	[DocumentCode] [varchar](20) NOT NULL,
	[Description] [varchar](1000) NULL,
	[Format] [varchar](50) NULL,
	[OnlineData] [xml] NULL,
	[Version] [varchar](50) NULL,
	[FormName] [varchar](50) NULL,
	[FormSet] [varchar](20) NULL,
	[Status] [varchar](20) NULL,
	[VisualIndicator] [varchar](2) NULL,
	[SpiralingOption] [varchar](20) NULL,
	[FormSessionName] [varchar](100) NULL,
	[LCID] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC,
	[Level] ASC,
	[Form] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Scoring].[TestForms]  WITH CHECK ADD FOREIGN KEY([AdministrationID], [Test], [Level])
REFERENCES [Scoring].[TestLevels] ([AdministrationID], [Test], [Level])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
