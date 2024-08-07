USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[TicketFormat]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[TicketFormat](
	[TicketFormatGuid] [uniqueidentifier] NOT NULL,
	[TicketFormatName] [varchar](40) NOT NULL,
	[IsAdministrationNameFixed] [bit] NOT NULL,
	[AdministrationNameText] [varchar](200) NOT NULL,
	[InstructionHeader] [varchar](200) NULL,
	[Summary] [varchar](400) NULL,
	[Note] [varchar](400) NULL,
	[IsAccommodationRequired] [bit] NOT NULL,
	[IsSISCodeRequired] [bit] NOT NULL,
	[IsFormRequired] [bit] NOT NULL,
	[IsSignatureRequired] [bit] NOT NULL,
	[HasSignInSignOutColumn] [bit] NOT NULL,
	[Use2014Heaaders] [bit] NOT NULL,
	[IsStudentRosterDateOfBirth] [bit] NOT NULL,
	[IsPartRequired] [bit] NOT NULL,
	[IsDistrictStudentIDRequired] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TicketFormatGuid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [IsAdministrationNameFixed]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [IsAccommodationRequired]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [IsSISCodeRequired]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [IsFormRequired]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [IsSignatureRequired]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [HasSignInSignOutColumn]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [Use2014Heaaders]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [IsStudentRosterDateOfBirth]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [IsPartRequired]
GO
ALTER TABLE [eWeb].[TicketFormat] ADD  DEFAULT ((0)) FOR [IsDistrictStudentIDRequired]
GO
