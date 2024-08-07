USE [Alaska_udb_dev]
GO
/****** Object:  Table [eWeb].[Sweet]    Script Date: 7/2/2024 9:12:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [eWeb].[Sweet](
	[StudentID] [int] IDENTITY(1,1) NOT NULL,
	[SchoolID] [nvarchar](7) NULL,
	[District] [nvarchar](15) NULL,
	[School] [nvarchar](21) NULL,
	[Grade] [nvarchar](2) NULL,
	[TeachID] [nvarchar](3) NULL,
	[TeachLName] [nvarchar](20) NULL,
	[TeachFName] [nvarchar](16) NULL,
	[StateID] [nvarchar](10) NULL,
	[PermID] [nvarchar](12) NULL,
	[LName] [nvarchar](40) NULL,
	[FName] [nvarchar](20) NULL,
	[MName] [nvarchar](13) NULL,
	[Generation] [nvarchar](4) NULL,
	[DOB] [nvarchar](8) NULL,
	[Gender] [nvarchar](1) NULL,
	[Ethnic] [nvarchar](3) NULL,
	[EFA1_eFA10] [nvarchar](40) NULL,
	[IEP_dB] [nvarchar](1) NULL,
	[IEP_MD] [nvarchar](1) NULL,
	[INSet] [nvarchar](2) NULL,
	[Plan504] [nvarchar](1) NULL,
	[EIA1_EIA10] [nvarchar](50) NULL,
	[Meals] [nvarchar](1) NULL,
	[Migrant] [nvarchar](1) NULL,
	[EngProf] [nvarchar](1) NULL,
	[COB] [nvarchar](5) NULL,
	[FirstLang] [nvarchar](3) NULL,
	[UsEntry] [nvarchar](8) NULL,
	[ESOLcohort] [nvarchar](1) NULL,
	[ESOLModel] [nvarchar](10) NULL,
	[AltAssess] [nvarchar](1) NULL,
	[ELASort] [nvarchar](3) NULL,
	[MathSort] [nvarchar](3) NULL,
	[SciSort] [nvarchar](3) NULL,
	[SocSort] [nvarchar](3) NULL,
	[ELACustom] [nvarchar](1) NULL,
	[MathCustom] [nvarchar](1) NULL,
	[SciCustom] [nvarchar](1) NULL,
	[SocCustom] [nvarchar](1) NULL,
	[NextSch] [nvarchar](3) NULL,
	[HSAPPrt] [nvarchar](1) NULL,
	[HSAPUpd] [nvarchar](1) NULL,
	[AltSch] [nvarchar](1) NULL,
	[EnterDate] [nvarchar](8) NULL,
	[EnterCode] [nvarchar](3) NULL,
	[PreKProg] [nvarchar](3) NULL,
	[CreationDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [eWeb].[Sweet] ADD  CONSTRAINT [DF_PreCode_CreationDate]  DEFAULT (getdate()) FOR [CreationDate]
GO
