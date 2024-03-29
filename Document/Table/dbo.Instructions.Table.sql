USE [Alaska_documents_dev]
GO
/****** Object:  Table [dbo].[Instructions]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Instructions](
	[Environment] [varchar](50) NOT NULL,
	[InstructionKey] [varchar](50) NOT NULL,
	[Instructions] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Environment] ASC,
	[InstructionKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
