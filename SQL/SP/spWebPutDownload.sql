Use WebCAMS
Go

Alter Procedure dbo.spWebPutDownload 
	(
		@Seq int OUTPUT,
		@DownloadCategoryID int,
		@DownloadDescription varchar(1000),
		@DownloadURL varchar(500),
		@FileSize varchar(50),
		@DisplayOrder int,
		@IsActive bit,
		@IsAudit bit,
		@UserID int
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-11-10 16:27:12$-->
--<!--$ModifiedBy: Andrew Falzon <andrew.falzon@bambora.com>$-->
--<!--$Comment: CAMS-776 Stored procedures for FSP download admin screens.$-->
--<!--$Commit$-->

SET NOCOUNT ON

IF @Seq > 0
	BEGIN
		IF EXISTS (SELECT 1 FROM tblDownload WHERE Seq = @Seq)
			BEGIN
				UPDATE tblDownload SET  DownloadCategoryID = @DownloadCategoryID, 
										DownloadDescription = @DownloadDescription, 
										DownloadURL = @DownloadURL, 
										FileSize = @FileSize,
										DisplayOrder = @DisplayOrder,
										IsActive = @IsActive,
										IsAudit = IsAudit,
										UpdateDateTime = GETDATE(),
										UpdatedBy = @UserID
				WHERE Seq = @Seq
			END
		ELSE
			BEGIN
				raiserror('Download not found for the specified Seq value.', 16, 1) 
			END
	END
ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM tblDownload WHERE DownloadCategoryID = @DownloadCategoryID and DownloadDescription = @DownloadDescription and DownloadURL = @DownloadURL)
			BEGIN
				raiserror('Download already exists.', 16, 1)
			END
		ELSE
			BEGIN
				INSERT INTO tblDownload
					SELECT @DownloadCategoryID, @DownloadDescription, @DownloadURL, @FileSize, @DisplayOrder, @IsActive, GETDATE(), @IsAudit, @UserID

				SELECT @Seq = SCOPE_IDENTITY()
			END
	END

RETURN @@ERROR

GO

Grant EXEC on spWebPutDownload to eCAMS_Role
Go


