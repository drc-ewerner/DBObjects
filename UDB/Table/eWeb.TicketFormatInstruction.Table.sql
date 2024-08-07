USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TicketFormatInstruction]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TicketFormatInstruction](
	[TicketFormatInstructionGuid] [uniqueidentifier] NOT NULL,
	[TicketFormatGuid] [uniqueidentifier] NOT NULL,
	[InstructionText] [varchar](400) NULL,
	[InstructionTitle] [varchar](400) NOT NULL,
	[IsInstructionTitleBold] [bit] NOT NULL,
	[IsInstructionTitleUnderlined] [bit] NOT NULL,
	[ShowChildrenAsList] [bit] NOT NULL,
	[ID] [tinyint] NULL,
	[OrderId] [int] IDENTITY(1,1) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TicketFormatInstructionGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[TicketFormatInstruction] ADD  DEFAULT ((0)) FOR [IsInstructionTitleBold]
GO
ALTER TABLE [eWeb].[TicketFormatInstruction] ADD  DEFAULT ((0)) FOR [IsInstructionTitleUnderlined]
GO
ALTER TABLE [eWeb].[TicketFormatInstruction] ADD  DEFAULT ((0)) FOR [ShowChildrenAsList]
GO
ALTER TABLE [eWeb].[TicketFormatInstruction]  WITH CHECK ADD  CONSTRAINT [fk_TicketFormatInstruction_TicketFormat] FOREIGN KEY([TicketFormatGuid])
REFERENCES [eWeb].[TicketFormat] ([TicketFormatGuid])
GO
ALTER TABLE [eWeb].[TicketFormatInstruction] CHECK CONSTRAINT [fk_TicketFormatInstruction_TicketFormat]
GO
