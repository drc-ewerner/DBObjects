USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[AddStudentToStudentGroupByDistrict]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	CREATE PROCEDURE [eWeb].[AddStudentToStudentGroupByDistrict]
	@AdministrationID INT,
	@DistrictCode VARCHAR(15),
	@StateTeacherID VARCHAR(50),
	@StateStudentID VARCHAR(20),
	@StudentGroupName VARCHAR(250),
	@StudentGroupType VARCHAR(50),
	@AllowUpdateOnly BIT

	--*** Error Codes: ***
	--0: Success()
	--1: Teacher or student does not exist
	--2: Group does not exist
	--3: Teacher and student do not exist at the same school
	--4: Duplicate StateStudentID found
	--5: Group Name is longer than 200 characters
	--6: Student already added
	--7: Group Required
	--8: Group Name Invalid
	WITH RECOMPILE 
	AS
	DECLARE @SchoolCode VARCHAR(15)
	DECLARE @Count INT
	DECLARE @TeacherID INT
	DECLARE @StudentGroupID INT
	DECLARE @StudentID INT
	DECLARE @arSch INT, @mData INT
	DECLARE @ErrorCode INT
	DECLARE @GroupCreated BIT

	SET @ErrorCode = 0
	SET @GroupCreated = 0

	DECLARE @tmpSchoolGroupResults TABLE (SchoolCode varchar(15),ErrorCode INT,GroupCreated BIT)

	/*Verify if the teacher and student exist within the district*/
	IF (NOT EXISTS(SELECT * FROM [Core].[Teacher] [ct]
								   INNER JOIN [Teacher].[Sites] [ts]
								   ON [ts].[AdministrationID] = [ct].[AdministrationID] AND 
									  [ts].[TeacherID] = [ct].[TeacherID]
							 WHERE
								   [ct].[StateTeacherID] = @StateTeacherID AND
								   [ct].[AdministrationID] = @AdministrationID AND
								   [ts].[DistrictCode] = @DistrictCode)

		OR (NOT EXISTS(SELECT * FROM [Core].[Student]
												 WHERE 
												    [StateStudentID] = @StateStudentID AND 
												    [AdministrationID] = @AdministrationID AND
												    [DistrictCode] = @DistrictCode)))
			BEGIN
				SET @ErrorCode = 1 --Teacher/Student do not exist

				INSERT INTO @tmpSchoolGroupResults
				SELECT
					SchoolCode = '',
					ErrorCode = @ErrorCode,
					GroupCreated = @GroupCreated
			END
	ELSE
		/*Find and save all the Schools for the selected District*/
		DECLARE @SchoolCodesByDistrict TABLE (RowNum INT IDENTITY(1,1) PRIMARY KEY CLUSTERED(RowNum),SchoolCode Varchar(15))
		
		INSERT INTO @SchoolCodesByDistrict 
		SELECT 
			 SiteCode
		FROM Core.Site
		WHERE AdministrationID=@AdministrationID 
			  AND SuperSiteCode = @DistrictCode 
			  AND SiteType='School'

		SET @arSch = 1

		/*Loop thru the list of schools to find/save the matching site*/
		WHILE(@arSch <= (SELECT MAX(RowNum) FROM @SchoolCodesByDistrict)) 
		BEGIN

			SELECT @SchoolCode = SchoolCode FROM @SchoolCodesByDistrict WHERE RowNum = @arSch

			/*Collect data to find matching site*/
			DECLARE @SGUData TABLE 
					(
						RowNum INT IDENTITY(1,1) PRIMARY KEY CLUSTERED(RowNum),
						AdminID int,
						DistrictCode varchar(15),
						SchoolCode varchar(15),
						StateTeacherID varchar(256),
						StateStudentID varchar(30),
						TeacherSiteCompare VARCHAR(50),
						StudentSiteCompare VARCHAR(50)

					) 				
	
			INSERT INTO @SGUData
			SELECT
				@AdministrationID AS AdminID,
				@DistrictCode AS DistrictCode,
				@SchoolCode AS SchoolCode,
				@StateTeacherID AS StateTeacherID,
				@StateStudentID AS StateStudentID,
				'MismatchTeacher' AS TeacherSiteCompare,
				'MismatchStudent' AS StudentSiteCompare

			/* Find matching records*/
			UPDATE d
			SET TeacherSiteCompare = 'MatchingTeacher'
			FROM [Core].[Teacher] t
			   JOIN [Teacher].[Sites] ts  
					ON  t.[AdministrationID] = ts.[AdministrationID]
					AND t.[TeacherID]= ts.[TeacherID]
			   JOIN @SGUData d
					ON t.AdministrationID = d.AdminID
					AND t.StateTeacherID = d.StateTeacherID
					AND ts.DistrictCode = d.DistrictCode
					AND ts.SchoolCode = d.SchoolCode

			UPDATE d
			SET StudentSiteCompare = 'MatchingStudent'
			FROM [Core].[Student] s
			   JOIN @SGUData d
					ON s.AdministrationID = d.AdminID
					AND s.StateStudentID = d.StateStudentID
					AND s.DistrictCode = d.DistrictCode
					AND s.SchoolCode = d.SchoolCode

				/*Verify if the student and teacher exist within the same school*/
				IF (@ErrorCode = 0 
					 AND EXISTS(SELECT 1 FROM @SGUData WHERE StudentSiteCompare = 'MatchingStudent' AND TeacherSiteCompare = 'MismatchTeacher'))
					 OR EXISTS(SELECT 1 FROM @SGUData WHERE StudentSiteCompare = 'MismatchTeacher' AND TeacherSiteCompare = 'MatchingStudent'
					)
					BEGIN																
						SET @ErrorCode = 3 --Teacher and student do not exist at the same school
						
						INSERT INTO @tmpSchoolGroupResults
						SELECT
							SchoolCode = @SchoolCode,
							ErrorCode = @ErrorCode,
							GroupCreated = @GroupCreated

						SELECT * FROM @tmpSchoolGroupResults
					END

				SET @arSch = @arSch + 1

		END --- End site loop

		/*Save matching data*/
		DECLARE @MatchedData TABLE 
				(
					RowNum INT IDENTITY(1,1) PRIMARY KEY CLUSTERED(RowNum),
					AdminID int,
					DistrictCode varchar(15),
					SchoolCode varchar(15),
					StateTeacherID varchar(256),
					StateStudentID varchar(30)
				) 				
	
				INSERT INTO @MatchedData
				SELECT DISTINCT
					AdminID,
					DistrictCode,
					SchoolCode,
					StateTeacherID,
					StateStudentID
				FROM @SGUData
				WHERE StudentSiteCompare = 'MatchingStudent' 
				AND TeacherSiteCompare = 'MatchingTeacher'

		SET @mData = 1

		/*Loop thru the matching data to create the group*/
		WHILE((SELECT COUNT(*) FROM @MatchedData) > 0 AND @mData <=(SELECT MAX(RowNum) FROM @MatchedData))
		BEGIN
			SELECT @SchoolCode = SchoolCode FROM @MatchedData WHERE RowNum = @mData

				IF (LEN(COALESCE(@StudentGroupName,'')) > 200)
					   SET @ErrorCode = 5
				ELSE IF (LEN(COALESCE(@StudentGroupName,'')) = 0)
					   SET @ErrorCode = 7 -- Group Required
				ELSE IF @StudentGroupName LIKE '%[^A-Z0-9'' -]%' --[^] syntax = any single character *not* within the specified range ([^a-f]) or set ([^abcdef]).
					   SET @ErrorCode = 8 --Group Name Invalid, may only contain alpha (A-Z, a-z), hyphen (-), apostrophe ('), and space
				ELSE --GroupName length OK
				BEGIN
					   IF (@ErrorCode = 0)
					   BEGIN
							  SELECT @Count = COUNT(*) FROM [Core].[Student]
							  WHERE [StateStudentID] = @StateStudentID 
								  AND [AdministrationID] = @AdministrationID
								  AND [DistrictCode]     = @DistrictCode
								  AND [SchoolCode]        = @SchoolCode

							  IF (@Count) > 1 
									 SET @ErrorCode = 4 -- StateStudentID not unique
					   END

					   IF (@ErrorCode = 0) -- StateTeacherID and StateStudentID ARE unique
							  BEGIN
							  SELECT @TeacherID = [ct].[TeacherID]
									 FROM
										   [Core].[Teacher] [ct]
										   INNER JOIN [Teacher].[Sites] [ts]
										   ON [ts].[AdministrationID] = [ct].[AdministrationID] AND 
											  [ts].[TeacherID] = [ct].[TeacherID]
									 WHERE
										   [ct].[StateTeacherID] = @StateTeacherID AND
										   [ct].[AdministrationID] = @AdministrationID AND
										   [ts].[DistrictCode] = @DistrictCode AND
										   [ts].[SchoolCode] = @SchoolCode

							  SELECT @StudentID = [StudentID] 
									 FROM [Core].[Student]
									 WHERE 
										   [StateStudentID] = @StateStudentID AND 
										   [AdministrationID] = @AdministrationID AND
										   [DistrictCode] = @DistrictCode AND
										   [SchoolCode] = @SchoolCode

							  SELECT @StudentGroupID = [sg].[GroupID] 
									 FROM [Core].[StudentGroup] [sg]
									 INNER JOIN [Teacher].[StudentGroups] [tsg] 
									 ON [tsg].[AdministrationID] = [sg].[AdministrationID] AND 
										[tsg].[GroupID] = [sg].[GroupID]
							  WHERE 
									 [sg].[GroupName] = @StudentGroupName AND 
									 [sg].[AdministrationID] = @AdministrationID AND 
									 [sg].[DistrictCode] = @DistrictCode AND 
									 [sg].[SchoolCode] = @SchoolCode AND 
									 [tsg].[TeacherID] = @TeacherID

							  IF (@ErrorCode = 0 AND @StudentGroupID IS NULL)
							  BEGIN
									 IF (@AllowUpdateOnly = 1)
									 BEGIN
										   SET @ErrorCode = 2 -- Group does not exist
									 END
									 ELSE
									 BEGIN --add new group							
										   SET @StudentGroupID=next value for Core.StudentGroup_SeqEven;
										   INSERT [Core].[StudentGroup]
										   (
												  [AdministrationID],
												  [GroupID],
												  [GroupType],
												  [GroupName],
												  [DistrictCode],
												  [SchoolCode],
												  [CreateDate],
												  [UpdateDate]
										   )
										   VALUES
										   (
												  @AdministrationID,
												  @StudentGroupID,
												  @StudentGroupType,
												  @StudentGroupName,
												  @DistrictCode,
												  @SchoolCode,
												  GETDATE(),
												  GETDATE()
										   )
                           
										   INSERT [Teacher].[StudentGroups]
										   (
												  [AdministrationID],
												  [TeacherID],
												  [GroupID],
												  [CreateDate],
												  [UpdateDate]
										   )
										   VALUES
										   (
												  @AdministrationID,
												  @TeacherID,
												  @StudentGroupID,
												  GETDATE(),
												  GETDATE()
										   )
                           
										   SET @GroupCreated = 1
									 END
							  END

							  IF (@ErrorCode = 0 AND EXISTS (
										   SELECT * FROM [StudentGroup].[Links]
										   WHERE [AdministrationID] = @AdministrationID AND [GroupID] = @StudentGroupID AND [StudentID] = @StudentID))
									 SET @ErrorCode = 6 --duplicate student addition attempt

							  IF (@ErrorCode = 0)
							  BEGIN --Add Student to group
									 INSERT [StudentGroup].[Links] ( [AdministrationID], [GroupID], [StudentID] )
									 VALUES ( @AdministrationID, @StudentGroupID, @StudentID )
							  END
					   END -- StateTeacherID and StateStudentID ARE unique
					END --GroupName length OK

			  SET @mData = @mData + 1

				INSERT INTO @tmpSchoolGroupResults
				SELECT
					SchoolCode = @SchoolCode,
					ErrorCode = @ErrorCode,
					GroupCreated = @GroupCreated

		END
		IF (@ErrorCode <> 3)
			SELECT * FROM @tmpSchoolGroupResults    
GO
