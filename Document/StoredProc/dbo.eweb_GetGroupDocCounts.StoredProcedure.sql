USE [Alaska_documents_dev]
GO
/****** Object:  StoredProcedure [dbo].[eweb_GetGroupDocCounts]    Script Date: 11/21/2023 8:33:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[eweb_GetGroupDocCounts]
(@groupId INT, @envCode NVARCHAR (20)
)
WITH RECOMPILE
AS
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	DECLARE  @envCode2 VARCHAR (20)
	SET @envCode2 = @envCode;

	SET ANSI_WARNINGS OFF;

	IF OBJECT_ID('tempdb..#MaxApprovedVersion','U') IS NOT NULL  
      DROP TABLE #MaxApprovedVersion

	CREATE TABLE #MaxApprovedVersion ([Version] smallint)
	CREATE INDEX index1 ON #MaxApprovedVersion ( [Version]);
	
	INSERT INTO #MaxApprovedVersion ([Version])
		SELECT	Max(dgv.Version) AS Version
		from	DocGroupVersion dgv
			INNER JOIN DocGroupVersionPublish dgvp ON dgv.DocGroupVerId = dgvp.DocGroupVerId
		where	dgvp.EnvironmentCode = @EnvCode2	
		and		dgvp.ApprovedDate IS NOT NULL
		and		dgv.DocGroupId = @groupId;

	IF OBJECT_ID('tempdb..#NewUnApprovedVersion','U') IS NOT NULL  
      DROP TABLE #NewUnApprovedVersion

	CREATE TABLE #NewUnApprovedVersion ([Version] smallint)
	CREATE INDEX index1 ON #NewUnApprovedVersion ( [Version]);
	
	INSERT INTO #NewUnApprovedVersion ([Version])
		SELECT	Max(dgv.Version) AS Version
		from	DocGroupVersion dgv
			INNER JOIN DocGroupVersionPublish dgvp ON dgv.DocGroupVerId = dgvp.DocGroupVerId
		where	dgvp.EnvironmentCode = @EnvCode2	
		and		dgvp.ApprovedDate IS NULL
		and		dgv.DocGroupId = @groupId
		and		((select * from #MaxApprovedVersion)IS NULL
		or		dgv.Version > (select Max(Version) from #MaxApprovedVersion));

	IF OBJECT_ID('tempdb..#DocApproved','U') IS NOT NULL  
      DROP TABLE #DocApproved
	
	CREATE TABLE #DocApproved (
		[VersionKey] [uniqueidentifier],
		[DocID] [uniqueidentifier],
		[Version] smallint,
		[FilePath] [varchar](1200)
	)

	CREATE INDEX index1 ON #DocApproved ( [VersionKey]);
	
	INSERT INTO #DocApproved ([VersionKey],[DocID],[Version],[FilePath])
		select	d.VersionKey, d.DocId, dgv.Version, d.FilePath
		from	DocGroupVersion dgv
				INNER JOIN #MaxApprovedVersion ver ON ver.Version = dgv.Version
				INNER JOIN DocGroupVersionDoc dgvd ON dgvd.DocGroupVerId = dgv.DocGroupVerId
				INNER JOIN Doc d ON dgvd.DocId = d.DocId
		where	dgv.DocGroupId = @groupId and dgvd.IsActive = 1;

	IF OBJECT_ID('tempdb..#DocNew','U') IS NOT NULL  
      DROP TABLE #DocNew
	
	CREATE TABLE #DocNew (
		[VersionKey] [uniqueidentifier],
		[DocID] [uniqueidentifier],
		[Version] smallint,
		[FilePath] [varchar](1200)
	)

	CREATE INDEX index1 ON #DocNew ( [VersionKey]);
	
	INSERT INTO #DocNew ([VersionKey],[DocID],[Version],[FilePath])
		select	d.VersionKey, d.DocId, dgv.Version, d.FilePath
		from	DocGroupVersion dgv
				INNER JOIN #NewUnApprovedVersion ver ON ver.Version = dgv.Version
				INNER JOIN DocGroupVersionDoc dgvd ON dgvd.DocGroupVerId = dgv.DocGroupVerId
				INNER JOIN Doc d ON dgvd.DocId = d.DocId
		where	dgv.DocGroupId = @groupId and dgvd.IsActive = 1;


	WITH 
	Updated AS (
	SELECT	Count(*) AS UpdatedCount
	FROM	#DocNew 
			INNER JOIN #DocApproved ON #DocNew.VersionKey = #DocApproved.VersionKey 
				AND #DocNew.FilePath<>#DocApproved.FilePath
	), 
	Added AS (
	SELECT	Count(*) AS AddedCount
	FROM	#DocNew 
			WHERE NOT Exists(SELECT * FROM #DocApproved WHERE #DocNew.VersionKey = #DocApproved.VersionKey)
	),
	Approved AS (
			select	count(*) As ApprovedCount
			from	#DocApproved
	),
	UnApproved AS (
			select	count(*) As UnApprovedCount
			from	#DocNew
	)

	SELECT ApprovedCount, UnapprovedCount, UpdatedCount, AddedCount
	FROM	Approved, Unapproved, Updated, Added

END
GO
