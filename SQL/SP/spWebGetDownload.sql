Use WebCAMS
Go

Alter Procedure dbo.spWebGetDownload (
	@Seq int = NULL,
	@CategoryID	int = NULL,
	@From tinyint, ---@From : 1 - From Web, 2 - From Mobile Device
	@UserID int = NULL
)
AS

DECLARE @IsAdmin bit = (SELECT 1 FROM tblUserModule WHERE UserID = @UserID and ModuleID = 7)
DECLARE @IncludeDisabled bit = 0

IF @CategoryID < 0
	BEGIN
		SELECT @IncludeDisabled = 1, @CategoryID = ABS(@CategoryID)
	END

 IF (@Seq IS NULL) AND (@CategoryID IS NULL)
  --list all the active downloads
  BEGIN
	 if @From = 1
	  begin
		 SELECT 
			DownloadDescription as [Description],
			'<A HREF="../Member/FSPDownload.aspx?DLID=' + CAST(Seq as varchar) + '">' + case when DownloadCategoryID = 16 then 'View' else 'Download' end + '</A>' as [Action],
			FileType = dbo.fnGetFileExtension(DownloadURL),
			FileSize,
			UpdateDateTime as EffectiveDate
		  FROM tblDownload 
		  WHERE (IsActive = 1 OR (@IsAdmin = 1 and @IncludeDisabled = 1))
		  Order By DownloadDescription
	  end
	else
	  begin
		 SELECT 
			Seq,
			DownloadDescription as [Description],
			FileType = dbo.fnGetFileExtension(DownloadURL),
			FileSize,
			UpdateDateTime as EffectiveDate
		  FROM tblDownload 
		  WHERE (IsActive = 1 OR (@IsAdmin = 1 and @IncludeDisabled = 1))
		  Order By DownloadDescription
	  end
	
  END
 ELSE
  --only get one download details
  BEGIN
    IF ISNULL(@Seq,0) > 0 
      BEGIN
		SELECT *
		  FROM tblDownload
		 WHERE Seq = @Seq
			AND (IsActive = 1 or @IsAdmin = 1)
      END
    ELSE IF ISNULL(@CategoryID,0) > 0 
      BEGIN
		CREATE TABLE #CategoryTree (
				DownloadCategoryID	int,
				ParentID		int,
				CategoryName	varchar(255) collate database_default
			)

  		EXEC spWebGetDownloadCategoryChild @CategoryID, 0

		 if @From = 1
		  begin
			SELECT 
				d.DownloadDescription as [Description],
				'<A HREF="../Member/FSPDownload.aspx?DLID=' + CAST(d.Seq as varchar) + '">' + case when DownloadCategoryID = 16 then 'View' else 'Download' end + '</A>' as [Action],
				FileType = dbo.fnGetFileExtension(DownloadURL),
				d.FileSize,
				d.UpdateDateTime as EffectiveDate
				FROM tblDownload d
				WHERE (d.IsActive = 1 OR (@IsAdmin = 1 and @IncludeDisabled = 1))
					AND ((d.DownloadCategoryID = @CategoryID)
	    				OR (d.DownloadCategoryID IN (SELECT DownloadCategoryID FROM #CategoryTree)))      
				ORDER By d.DownloadDescription			
		  end
		else
		  begin
			SELECT 
				Seq,
				d.DownloadDescription as [Description],
				FileType = dbo.fnGetFileExtension(DownloadURL),
				d.FileSize,
				d.UpdateDateTime as EffectiveDate
				FROM tblDownload d
				WHERE (d.IsActive = 1 OR (@IsAdmin = 1 and @IncludeDisabled = 1))
					AND ((d.DownloadCategoryID = @CategoryID)
	    				OR (d.DownloadCategoryID IN (SELECT DownloadCategoryID FROM #CategoryTree)))      
				ORDER By d.DownloadDescription			
		  end

	  END
   END

/*

exec spWebGetDownload null,4, 2

exec spWebGetDownload null,4, 1

*/
GO

Grant EXEC on spWebGetDownload to eCAMS_Role
Go