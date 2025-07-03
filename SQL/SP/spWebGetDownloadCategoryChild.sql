Use WebCAMS
Go
--<!--$$Revision: 2 $-->
--<!--$$Author: Thanh $-->
--<!--$$Date: 21/04/05 1:17p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetDownloadCategoryChild.sql $-->
--<!--$$NoKeywords: $-->

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'spWebGetDownloadCategoryChild' 
	   AND 	  type = 'P')
    DROP PROCEDURE dbo.spWebGetDownloadCategoryChild
GO

CREATE PROCEDURE dbo.spWebGetDownloadCategoryChild (
	@ParentID	int,
	@TreeLevel	smallint
)
AS

SET NOCOUNT ON

DECLARE @DownloadCategoryID	int,
	@NextParentID		int,
	@CategoryName		varchar(255),
	@NextLevel		smallint,
	@Prefix			varchar(10)



 SELECT @NextLevel = @TreeLevel + 1
 SELECT @Prefix = REPLACE(SPACE(@NextLevel),' ','--')

 --Get parent location children first, loop through each parent to retrieve its children
 DECLARE curChildren CURSOR LOCAL FAST_FORWARD
	FOR SELECT * FROM  tblDownloadCategory
	  WHERE ParentCategoryID = @ParentID
	ORDER BY CategoryName




OPEN curChildren

WHILE 1 = 1
  BEGIN
	FETCH NEXT FROM curChildren
	  INTO @DownloadCategoryID, @NextParentID, @CategoryName

	IF @@FETCH_STATUS <> 0
		BREAK

	INSERT #CategoryTree
          SELECT @DownloadCategoryID, @NextParentID,  @Prefix + @CategoryName

	EXEC spWebGetDownloadCategoryChild @DownloadCategoryID,@NextLevel
  END 

 CLOSE curChildren

 DEALLOCATE curChildren

/*
-- =============================================
-- example to execute the store procedure
-- =============================================
EXEC spWebGetDownloadCategoryChild 
*/
GO


Grant EXEC on spWebGetDownloadCategoryChild to eCAMS_Role
Go