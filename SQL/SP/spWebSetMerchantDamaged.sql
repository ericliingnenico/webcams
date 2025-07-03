Use CAMS
Go

If exists(select 1 from sysobjects where name = 'spWebSetMerchantDamaged')
 drop proc dbo.spWebSetMerchantDamaged
Go

Create Procedure dbo.spWebSetMerchantDamaged 
	(
		@UserID int,
		@JobID bigint,
		@Serial varchar(32),
		@MMD_ID varchar(5),
		@IsMerchantDamaged bit
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 6/06/11 14:39 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebSetMerchantDamaged.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Set MerchantDamaged flag and add notes to ims job/calls
DECLARE @ret int,
	@JobNotes varchar(255),
	@FSPOperatorNumber int

    --init
    SELECT @ret = 0

	 --Get Location for the user
	 SELECT @FSPOperatorNumber = 0 - InstallerID
	   FROM WebCAMS.dbo.tblUser
	  WHERE UserID = @UserID

	if @FSPOperatorNumber is null
		return @ret

    --check if the need to proceed
    IF ISNULL(@IsMerchantDamaged, 0) = 0 
		RETURN @ret


	IF @IsMerchantDamaged = 1 
     BEGIN
		--build notes
		SELECT @JobNotes = 'Device ['+ ltrim(ISNULL(@Serial, '')) + ', ' + ISNULL(@MMD_ID, '') + '] was marked as MerchantDamaged by FSP @ '  + dbo.fnGetOperatorStamp(@FSPOperatorNumber) + dbo.fnCRLF()

		--set IsMerchantDamaged to job equipment
		IF LEN(@JobID) = 11
		 BEGIN
			UPDATE Call_Equipment
			   SET IsMerchantDamaged = 1
			  WHERE CallNumber = @JobID
					AND Serial = @Serial
					AND MMD_ID = @MMD_ID
						
			--append to CallMemo
			EXEC @ret = dbo.spAddNotesToCall
					@CallNumber = @JobID,
					@NewNotes = @JobNotes ,
					@OperatorName = @FSPOperatorNumber
			--append to FaultMemo as well
			EXEC @ret = dbo.spAddFaultNotesToCall
					@CallNumber = @JobID,
					@NewNotes = @JobNotes ,
					@OperatorName = @FSPOperatorNumber
										
		 END
		ELSE
		 BEGIN
			UPDATE IMS_Job_Equipment
			   SET IsMerchantDamaged = 1
			  WHERE JobID = @JobID
					AND Serial = @Serial
					AND MMD_ID = @MMD_ID
					AND ActionID = 2

			--append to Notes
			EXEC @ret = dbo.spAddNotesToIMSJob
					@JobID = @JobID,
					@NewNotes = @JobNotes ,
					@OperatorName = @FSPOperatorNumber

			--append to InstallerNotes
			EXEC @ret = dbo.spAddInstallerNotesToIMSJob
					@JobID = @JobID,
					@NewNotes = @JobNotes ,
					@OperatorName = @FSPOperatorNumber
						
			 END
     END

   Return @ret


GO

Grant EXEC on spWebSetMerchantDamaged to eCAMS_Role
Go

Use WebCAMS
Go

If exists(select 1 from sysobjects where name = 'spWebSetMerchantDamaged')
 drop proc dbo.spWebSetMerchantDamaged
Go


Create Procedure dbo.spWebSetMerchantDamaged 
	(
		@UserID int,
		@JobID bigint,
		@Serial varchar(32),
		@MMD_ID varchar(5),
		@IsMerchantDamaged bit
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 3/05/04 2:25p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebSetMerchantDamaged.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @ret int

 SET NOCOUNT ON

 EXEC @ret = Cams.dbo.spWebSetMerchantDamaged @UserID = @UserID,
				@JobID = @JobID,
				@Serial = @Serial,
				@MMD_ID = @MMD_ID,
				@IsMerchantDamaged = @IsMerchantDamaged

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*
spWebSetMerchantDamaged 199516
*/
Go

Grant EXEC on spWebSetMerchantDamaged to eCAMS_Role
Go
