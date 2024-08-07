USE [Alaska_udb_dev]
GO
/****** Object:  StoredProcedure [eWeb].[GetEISPopulatedData]    Script Date: 7/2/2024 9:21:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****************************************************************************
 * Titile: EIS Data Population Checks - eDirect Test Setup
 * Author: Chris Hedberg
 * CreateDate: 11/25/2013
 * LastUpdated: 01/06/2014
 *
 * Description: This script executes querys against all tables that EIS is
 * responsible for related to eDirect test setup. 
 * If a table returns no results, you will have to check 
 * to see if that data is used for your states test setup task. If it is,
 * contact EIS to let them know they need to populate data for you.
 *
 * If your state is using the online batch split architecture, run this 
 * script on the edm database (because this is linked to the udb database)
 * to see if data has been populated. Otherwise, you will not be able to 
 * access the journal tables.
 ****************************************************************************/
CREATE PROCEDURE [eWeb].[GetEISPopulatedData]
	@AdminID int
AS


/*Set these flags manually ''Y'' or ''N''*/
Declare @ShowResultsGood as Char
Declare @ShowResultsBad as Char
Declare @ShowDetail as Char

Set @ShowResultsGood = 'Y'
Set @ShowResultsBad = 'Y'

Declare @CanContinue as Bit
Set @CanContinue = 1

Declare @ResultsGood as Table (
[Good Tables] varchar(100),
[RecordCount] int
)

Declare @ResultsBad as Table (
[Bad Tables] varchar(100),
[RecordCount] int
)

Declare @CombinedResults as Table (
[GoodOrBad] varchar(50),
[TableName] varchar(100),
[RecordCount] int
)

Declare @Count int


/****************************************************************************
 * BEGIN TESTS BELOW THIS LINE
 ****************************************************************************/


/*Scoring.Tests*/
Set @Count = -1;
Set @Count = (
	Select Count(*) 
	From Scoring.Tests
	Where AdministrationID = @AdminID
)

IF(@Count > 0)
BEGIN
	Insert Into @ResultsGood
	Select 'Scoring.Tests', @Count
END
ELSE
BEGIN
	Insert Into @ResultsBad
	Select 'Scoring.Tests', @Count

	Set @CanContinue = 0
END



/*Scoring.TestLevels */
Set @Count = -1;
Set @Count = (
	Select Count(*) 
	From Scoring.TestLevels 
	Where AdministrationID = @AdminID
)

IF(@Count > 0)
BEGIN
	Insert Into @ResultsGood
	Select 'Scoring.TestLevels', @Count
END
ELSE
BEGIN
	Insert Into @ResultsBad
	Select 'Scoring.TestLevels', @Count

	Set @CanContinue = 0
END



/*Scoring.Tests and Scoring.TestLevels*/
Set @Count = -1;
Set @Count = (
	Select Count(*) 
	From Scoring.Tests st
	Inner Join Scoring.TestLevels stl
		On st.AdministrationID = stl.AdministrationID
		And st.Test = stl.Test
	Where st.AdministrationID = @AdminID
)

IF(@Count > 0)
BEGIN
	Insert Into @ResultsGood
	Select 'Scoring.Tests AND Scoring.TestLevels', @Count
END
ELSE
BEGIN
	Insert Into @ResultsBad
	Select 'Scoring.Tests AND Scoring.TestLevels', @Count

	Set @CanContinue = 0
END



IF(@CanContinue <> 0)
BEGIN


	/*Scoring.TestForms*/
	Set @Count = -1
	Set @Count = (
		Select Count(*)
		From Scoring.TestForms
		Where AdministrationID = @AdminID
	)

	IF(@Count > 0)
	BEGIN
		Insert Into @ResultsGood
		Select 'Scoring.TestForms', @Count
	END
	ELSE
	BEGIN
		Insert Into @ResultsBad
		Select 'Scoring.TestForms', @Count
	END



	/*Xref.Grades*/
	Set @Count = -1;
	Set @Count = (
		Select Count(*) 
		From Xref.Grades
		Where AdministrationID = @AdminID
		And isnull(IsNotOnlineTesting,'') <> 'T'
	)

	IF(@Count > 0)
	BEGIN
		Insert Into @ResultsGood
		Select 'Xref.Grades', @Count
	END
	ELSE
	BEGIN
		Insert Into @ResultsBad
		Select 'Xref.Grades', @Count
	END



	/*Xref.StudentExtensionNames*/
	Set @Count = -1;
	Set @Count = (
		Select Count(*) 
		From Xref.StudentExtensionNames
		Where AdministrationID = @AdminID
	)

	IF(@Count > 0)
	BEGIN
		Insert Into @ResultsGood
		Select 'Xref.StudentExtensionNames', @Count
	END
	ELSE
	BEGIN
		Insert Into @ResultsBad
		Select 'Xref.StudentExtensionNames', @Count
	END



	/*Xref.StudentExtensionValues*/
	Set @Count = -1;
	Set @Count = (
		Select Count(*) 
		From Xref.StudentExtensionValues
		Where AdministrationID = @AdminID
	)

	IF(@Count > 0)
	BEGIN
		Insert Into @ResultsGood
		Select 'Xref.StudentExtensionValues', @Count
	END
	ELSE
	BEGIN
		Insert Into @ResultsBad
		Select 'Xref.StudentExtensionValues', @Count
	END





	/*Scoring.TestAccommodationForms*/
	Set @Count = -1;
	Set @Count = (
		Select Count(*) 
		From Scoring.TestAccommodationForms
		Where AdministrationID = @AdminID
	)

	IF(@Count > 0)
	BEGIN
		Insert Into @ResultsGood
		Select 'Scoring.TestAccommodationForms', @Count
	END
	ELSE
	BEGIN
		Insert Into @ResultsBad
		Select 'Scoring.TestAccommodationForms', @Count
	END



	/*Check For Missing Demographics*/
	Declare @CountA int
	Declare @CountB int
	Set @CountA = -1
	Set @CountB = -2

	Set @CountA = (
		Select Count(*) From xRef.StudentExtensionValues
		Where AdministrationID = @AdminID
		And Category = 'Demographic'
	)

	Set @CountB = (
		Select Count(*) From xRef.StudentExtensionNames N
		Inner Join xRef.StudentExtensionValues V
			On N.AdministrationID = V.AdministrationID
			and N.Category = V.Category
			and N.Name = V.Name
		Where N.AdministrationID = @AdminID
		And N.Category = 'Demographic'
	)

	IF(@CountA = @CountB)
	BEGIN
		Insert Into @ResultsGood
		Select 'xRef.StudentExtension Demographics.', @CountB
	END
	ELSE 
	BEGIN 
		/*Demographis are not joining properly*/
		Insert Into @ResultsBad
		Select 'xRef.StudentExtension Demographics Join Issue. DIFF = ', ABS(@CountA - @CountB)
	END



	/*Check For Missing TestingCodes*/
	Set @CountA = -1
	Set @CountB = -2

	Set @CountA = (
		Select Count(*) From xRef.StudentExtensionValues
		Where AdministrationID = @AdminID
		And Category = 'TestingCodes'
	)

	Set @CountB = (
		Select Count(*) From xRef.StudentExtensionNames N
		Inner Join xRef.StudentExtensionValues V
			On N.AdministrationID = V.AdministrationID
			and N.Category = V.Category
			and N.Name = V.Name
		Where N.AdministrationID = @AdminID
		And N.Category = 'TestingCodes' --Same Record Count As In Values Table!
	)

	IF(@CountA = @CountB)
	BEGIN
		Insert Into @ResultsGood
		Select 'xRef.StudentExtension TestingCodes.', @CountB
	END
	ELSE 
	BEGIN
		/*Demographis are not joining properly*/
		Insert Into @ResultsBad
		Select 'xRef.StudentExtension TestingCodes Join Issue. DIFF=', ABS(@CountA - @CountB)
	END



	/*Check For Missing Accommodations*/
	Set @CountA = -1
	Set @CountB = -2

	Set @CountA = (
		Select Count(*) From xRef.StudentExtensionValues V
		Inner Join Scoring.Tests T
			On V.AdministrationID = T.AdministrationID
			And V.Category = T.ContentArea
		Where V.AdministrationID = @AdminID
		And V.Category not in ('Demographic','TestingCodes')
	)

	Set @CountB = (
		Select Count(*) From xRef.StudentExtensionNames N
		Inner Join xRef.StudentExtensionValues V
			On N.AdministrationID = V.AdministrationID
			and N.Category = V.Category
			and N.Name = V.Name
		Inner Join Scoring.Tests T
			On V.AdministrationID = T.AdministrationID
			And V.Category = T.ContentArea
		Where N.AdministrationID = @AdminID
		And N.Category not in ('Demographic','TestingCodes')
	)

	IF(@CountA = @CountB)
	BEGIN
		Insert Into @ResultsGood
		Select 'xRef.StudentExtension Accomm.', @CountB
	END
	ELSE
	BEGIN
		/*Accomm are not joining properly*/
		Insert Into @ResultsBad
		Select 'xRef.StudentExtension Accomm Join Issue. DIFF=', ABS(@CountA - @CountB)
	END



	/*Scoring.TestFormParts*/
	Set @Count = -1;
	Set @Count = (
		Select Count(*) 
		From Scoring.TestFormParts
		Where AdministrationID = @AdminID
	)

	IF(@Count > 0)
	BEGIN
		Insert Into @ResultsGood
		Select 'Scoring.TestFormParts', @Count
	END
	ELSE
	BEGIN
		Insert Into @ResultsBad
		Select 'Scoring.TestFormParts', @Count
	END

	/*Put results into the combined table*/
	IF(@ShowResultsGood = 'Y' And @ShowResultsBad = 'Y')
	BEGIN
		/*Good and Bad Results*/
		Insert Into @CombinedResults ([GoodOrBad],[TableName],[RecordCount])
		Select 'Good', [Good Tables], [RecordCount] 
		From @ResultsGood
		UNION ALL
		Select 'Bad', [Bad Tables], [RecordCount] 
		From @ResultsBad

	END
	ELSE
	BEGIN

		/*Good Results*/
		IF(@ShowResultsGood = 'Y')
		Insert Into @CombinedResults ([GoodOrBad],[TableName],[RecordCount])
		Select 'Good', [Good Tables], [RecordCount] 
		From @ResultsGood

		/*Bad Results*/
		IF(@ShowResultsBad = 'Y')
		Insert Into @CombinedResults ([GoodOrBad],[TableName],[RecordCount])
		Select 'Bad', [Bad Tables], [RecordCount] 
		From @ResultsBad

	END

END
ELSE
BEGIN
	PRINT('The tables Scoring.Tests and Scoring.TestLevels are not populated!')

	/*Bad Results*/
	Insert Into @CombinedResults ([GoodOrBad],[TableName],[RecordCount])
	Select 'Bad', [Bad Tables], [RecordCount] 
	From @ResultsBad
END


/*Select the output data here. This is the only select that returns data.*/
Select [GoodOrBad],[TableName],[RecordCount] 
From @CombinedResults
GO
