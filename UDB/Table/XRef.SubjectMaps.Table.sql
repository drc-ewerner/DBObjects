USE [Alaska_udb_dev]
GO
/****** Object:  Table [XRef].[SubjectMaps]    Script Date: 7/2/2024 9:12:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [XRef].[SubjectMaps](
	[AdministrationID] [int] NOT NULL,
	[PA_Subject] [varchar](50) NOT NULL,
	[Subject] [varchar](30) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[UpdateDate] [datetime] NOT NULL,
 CONSTRAINT [pk_SubjectMaps] PRIMARY KEY CLUSTERED 
(
	[AdministrationID] ASC,
	[PA_Subject] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [XRef].[SubjectMaps] ADD  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [XRef].[SubjectMaps] ADD  DEFAULT (getdate()) FOR [UpdateDate]
GO
