Use CAMS
Go
if exists(Select 1 from sysobjects where name = 'spWebUploadMerchantSignedJobSheet')
	drop proc spWebUploadMerchantSignedJobSheet
go
CREATE proc spWebUploadMerchantSignedJobSheet 
	(
		@UserID int,
		@JobID bigint,
		@JobSheet image,
		@ContentType varchar(50)
	)
as

--Purpose: Upload Merchant Signed JobSheet
DECLARE @UserFound bit



 IF not exists(select 1 from WebCAMS.dbo.tblUser where UserID = @UserID	and IsActive = 1)
	SELECT @UserFound = 0
 ELSE
	SELECT @UserFound = 1


 If @UserFound = 0
  BEGIN
	--user does not exist, log into the exception log table
	INSERT tblMerchantSignedJobSheetExceptionLog (JobID,
						JobSheet,
						ContentType,
						UpdateDateTime)
		VALUES (@JobID,
			@JobSheet,
			@ContentType,
			GETDATE())

	RETURN -1
  END

 --save the signature image
 IF EXISTS(SELECT 1 FROM tblMerchantSignedJobSheet WHERE JobID = @JobID)
  BEGIN
	--copy the previous signature capture to tblMerchantSignedJobSheetPrevious
	INSERT tblMerchantSignedJobSheetPrevious (
				JobID,
				JobSheet,
				ContentType,
				UpdateDateTime)
	  SELECT JobID,
			JobSheet,
			ContentType,
			UpdateDateTime
	   FROM tblMerchantSignedJobSheet 
	  WHERE JobID = @JobID

	--update this capture
	UPDATE tblMerchantSignedJobSheet
	   SET JobSheet = @JobSheet,
		ContentType = @ContentType,
		UpdateDateTime = GETDATE()
	 WHERE JobID = @JobID
  END
 ELSE
  BEGIN
	INSERT tblMerchantSignedJobSheet (JobID, 
					JobSheet, 
					ContentType,
					UpdateDateTime)
		VALUES (@JobID, 
			@JobSheet, 
			@ContentType,
			GETDATE())

  END

Go

grant exec on dbo.spWebUploadMerchantSignedJobSheet to CAMSApp, eCAMS_Role
go


Use webCAMS
go

if exists(Select 1 from sysobjects where name = 'spWebUploadMerchantSignedJobSheet')
	drop proc spWebUploadMerchantSignedJobSheet
go

CREATE Procedure dbo.spWebUploadMerchantSignedJobSheet 
	(
		@UserID int,
		@JobID bigint,
		@JobSheet image,
		@ContentType varchar(50)
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/02/11 18:40 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebUploadMerchantSignedJobSheet.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int

 EXEC @ret = Cams.dbo.spWebUploadMerchantSignedJobSheet 
		@UserID = @UserID,
		@JobID = @JobID, 
		@JobSheet = @JobSheet,
		@ContentType = @ContentType


 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret

/*
spWebUploadMerchantSignedJobSheet 199516, 1234, '23'
*/
Go

GRANT EXEC on spWebUploadMerchantSignedJobSheet to eCAMS_Role
Go
