USE [Alaska_udb_dev]
GO
/****** Object:  Table [Insight].[OnlineTests]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insight].[OnlineTests](
	[AdministrationID] [int] NOT NULL,
	[OnlineTestID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentID] [int] NOT NULL,
	[Method] [varchar](20) NULL,
	[CreateDate] [datetime] NOT NULL,
	[Section] [varchar](20) NULL,
	[Source] [varchar](50) NOT NULL,
	[ElapsedTime] [int] NULL,
 CONSTRAINT [pk_OnlineTests] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[OnlineTestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Insight].[OnlineTests] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [Insight].[OnlineTests] ADD  DEFAULT ('') FOR [Source]
GO
