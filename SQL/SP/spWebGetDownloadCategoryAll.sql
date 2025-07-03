Use WebCAMS
Go
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:29 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetDownloadCategoryAll.sql $-->
--<!--$$NoKeywords: $-->


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'spWebGetDownloadCategoryAll' 
	   AND 	  type = 'P')
    DROP PROCEDURE dbo.spWebGetDownloadCategoryAll
GO

CREATE PROCEDURE dbo.spWebGetDownloadCategoryAll 
AS
SET NOCOUNT ON
CREATE TABLE #CategoryTree (
		DownloadCategoryID	int,
		ParentID		int,
		CategoryName	varchar(255) collate database_default
	)

DECLARE @DownloadCategoryID	int,
	@ParentID		int,
	@CategoryName		varchar(255),
	@TreeLevel		smallint


 --Get parent location children first, loop through each parent to retrieve its children
 DECLARE curParents CURSOR LOCAL FAST_FORWARD
	FOR SELECT * FROM tblDownloadCategory
	  WHERE ParentCategoryID IS NULL
	ORDER BY CategoryName

 OPEN curParents 
 
 SET @TreeLevel = 0
WHILE 1 = 1
  BEGIN
	FETCH NEXT FROM curParents 
	  INTO @DownloadCategoryID, @ParentID, @CategoryName

	IF @@FETCH_STATUS <> 0
		BREAK

	INSERT #CategoryTree
          SELECT @DownloadCategoryID, @ParentID,  @CategoryName

	EXEC spWebGetDownloadCategoryChild @DownloadCategoryID, @TreeLevel
  END 

 CLOSE curParents
 DEALLOCATE curParents

 SELECT *
   FROM #CategoryTree
/*
-- =============================================
-- example to execute the store procedure
-- =============================================
EXEC spWebGetDownloadCategoryAll
*/
GO

Grant EXEC on spWebGetDownloadCategoryAll to eCAMS_Role
Go