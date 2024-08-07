USE [Alaska_udb_dev]
GO
/****** Object:  Table [Scoring].[Standards]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Scoring].[Standards](
	[AdministrationID] [int] NOT NULL,
	[Test] [varchar](50) NOT NULL,
	[Content] [xml] NULL,
 CONSTRAINT [pk_Standards] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[Test] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Scoring].[Standards]  WITH CHECK ADD  CONSTRAINT [fk_Standards_Tests] FOREIGN KEY([AdministrationID], [Test])
REFERENCES [Scoring].[Tests] ([AdministrationID], [Test])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [Scoring].[Standards] CHECK CONSTRAINT [fk_Standards_Tests]
GO
