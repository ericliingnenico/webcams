Use CAMS
Go

If exists(select 1 from sysobjects where name = 'spWebFSPCallMerchant')
 drop proc dbo.spWebFSPCallMerchant
Go

Create Procedure dbo.spWebFSPCallMerchant 
	(
		@UserID int,
		@JobID bigint,
		@PhoneNumber varchar(50)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 23/05/13 10:24 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebFSPCallMerchant.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Set Job status to FSP Onsite and add notes
DECLARE @ret int,
	@JobNotes varchar(255),
	@FSPOperatorNumber int,
	@FSPID int,
	@Latitude	float,
	@Longitude	float


    --init
    SELECT @ret = 0

	 --Get Location for the user
	 SELECT @FSPOperatorNumber = 0 - InstallerID,
			@FSPID = InstallerID
	   FROM WebCAMS.dbo.tblUser
	  WHERE UserID = @UserID

	if @FSPOperatorNumber is null
		return @ret

	
	--build notes
	SELECT @JobNotes = 'FSP tried to call merchant on ' + isnull(@PhoneNumber, '') + ' @ '  + dbo.fnGetOperatorStamp(@FSPOperatorNumber) + dbo.fnCRLF()

	--set IsMerchantDamaged to job equipment
	IF LEN(@JobID) = 11
	 BEGIN
		--UPDATE Calls
		--   SET StatusID = 24
		--  WHERE CallNumber = @JobID
					
		--append to CallMemo
		EXEC @ret = dbo.spAddNotesToCall
				@CallNumber = @JobID,
				@NewNotes = @JobNotes ,
				@OperatorName = @FSPOperatorNumber

	 END
	ELSE
	 BEGIN
		--UPDATE IMS_Jobs
		--   SET StatusID = 24
		--  WHERE JobID = @JobID

		--append to Notes
		EXEC @ret = dbo.spAddNotesToIMSJob
				@JobID = @JobID,
				@NewNotes = @JobNotes ,
				@OperatorName = @FSPOperatorNumber

					
	 END

	--log the onsite activities
	insert tblFSPCallMerchantLog(
			FSPID,
			JobID,
			PhoneNumber,
			LoggedDate)
		select
			@FSPID,
			@JobID,
			@PhoneNumber,
			GETDATE()
		
   Return @ret


GO

Grant EXEC on spWebFSPCallMerchant to eCAMS_Role
Go

Use WebCAMS
Go

If exists(select 1 from sysobjects where name = 'spWebFSPCallMerchant')
 drop proc dbo.spWebFSPCallMerchant
Go


Create Procedure dbo.spWebFSPCallMerchant 
	(
		@UserID int,
		@JobID bigint,
		@PhoneNumber varchar(50)
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 3/05/04 2:25p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebFSPCallMerchant.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @ret int

 SET NOCOUNT ON

 EXEC @ret = Cams.dbo.spWebFSPCallMerchant @UserID = @UserID,
				@JobID = @JobID,
				@PhoneNumber = @PhoneNumber

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*
spWebFSPCallMerchant 199516
*/
Go

Grant EXEC on spWebFSPCallMerchant to eCAMS_Role
Go
