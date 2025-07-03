Use CAMS
Go
if exists(Select 1 from sysobjects where name = 'spWebPutMerchantAcceptance')
	drop proc spWebPutMerchantAcceptance
go
CREATE proc spWebPutMerchantAcceptance 
	(
		@UserID int,
		@JobID bigint,
		@SignatureData image,
		@PrintName varchar(50),
		@UpdateDateTime datetime
	)
as

--Purpose: collect merchant signature and print name
DECLARE @Location int,
	@DateTimeOffset int,
	@UserFound bit

 --FSP Location
 SELECT @Location = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID
	AND IsActive = 1

 IF @@ROWCOUNT < 1
	SELECT @UserFound = 0
 ELSE
	SELECT @UserFound = 1


 If @UserFound = 0
  BEGIN
	--user does not exist, log into the exception log table
	INSERT tblMerchantAcceptanceExceptionLog (JobID,
						SignatureData,
						PrintName,
						UpdateDateTime)
		VALUES (@JobID,
			@SignatureData,
			@PrintName,
			@UpdateDateTime)

	RETURN -1
  END

 --save the signature image
 IF EXISTS(SELECT 1 FROM tblMerchantAcceptance WHERE JobID = @JobID)
  BEGIN
	--copy the previous signature capture to tblMerchantAcceptancePrevious
	INSERT tblMerchantAcceptancePrevious (
				JobID,
				SignatureData,
				PrintName,
				UpdateDateTime)
	  SELECT JobID,
		SignatureData,
		PrintName,
		UpdateDateTime
	   FROM tblMerchantAcceptance 
	  WHERE JobID = @JobID

	--update this capture
	UPDATE tblMerchantAcceptance
	   SET SignatureData = @SignatureData,
		PrintName = @PrintName,
		UpdateDateTime = @UpdateDateTime
	 WHERE JobID = @JobID
  END
 ELSE
  BEGIN
	INSERT tblMerchantAcceptance (JobID, 
					SignatureData, 
					PrintName,
					UpdateDateTime)
		VALUES (@JobID, 
			@SignatureData, 
			@PrintName,
			@UpdateDateTime)

  END

Go

grant exec on dbo.spWebPutMerchantAcceptance to CAMSApp, eCAMS_Role
go


Use webCAMS
go

if exists(Select 1 from sysobjects where name = 'spWebPutMerchantAcceptance')
	drop proc spWebPutMerchantAcceptance
go

CREATE Procedure dbo.spWebPutMerchantAcceptance 
	(
		@UserID int,
		@JobID bigint,
		@SignatureData image,
		@PrintName varchar(50)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 27/10/10 14:16 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutMerchantAcceptance.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 declare @UpdateDateTime datetime
 select @UpdateDateTime = GETDATE()
 EXEC Cams.dbo.spWebPutMerchantAcceptance 
		@UserID = @UserID,
		@JobID = @JobID, 
		@SignatureData = @SignatureData,
		@PrintName = @PrintName,
		@UpdateDateTime = @UpdateDateTime

/*
spWebPutMerchantAcceptance 199516, 1234, '23'
*/
Go

GRANT EXEC on spWebPutMerchantAcceptance to eCAMS_Role
Go
