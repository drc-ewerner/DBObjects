USE [Alaska_security_dev]
GO
/****** Object:  Table [dbo].[eWebUserDemographic]    Script Date: 7/2/2024 9:42:55 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eWebUserDemographic](
	[UserId] [uniqueidentifier] NOT NULL,
	[NamePrefix] [varchar](10) NULL,
	[FirstName] [varchar](30) NULL,
	[MiddleInitial] [varchar](1) NULL,
	[LastName] [varchar](30) NULL,
	[NameSuffix] [varchar](10) NULL,
	[AddrLine1] [varchar](50) NULL,
	[AddrLine2] [varchar](50) NULL,
	[City] [varchar](30) NULL,
	[State] [varchar](2) NULL,
	[Zip5] [varchar](5) NULL,
	[Zip4] [varchar](4) NULL,
	[Phone] [varchar](12) NULL,
	[PhoneExtn] [varchar](10) NULL,
 CONSTRAINT [PK_eWebUserDemographics] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[eWebUserDemographic]  WITH CHECK ADD  CONSTRAINT [FK_eWebUserDemographic__aspnet_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eWebUserDemographic] CHECK CONSTRAINT [FK_eWebUserDemographic__aspnet_Users]
GO
