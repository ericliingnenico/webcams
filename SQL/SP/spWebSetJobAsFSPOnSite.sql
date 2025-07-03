Use CAMS
Go

--If exists(select 1 from sysobjects where name = 'spWebSetJobAsFSPOnSite')
-- drop proc dbo.spWebSetJobAsFSPOnSite
--Go

Alter Procedure dbo.spWebSetJobAsFSPOnSite 
	(
		@UserID int,
		@JobID bigint,
		@Latitude	float = null,
		@Longitude	float = null
	)
	AS
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/01/16 9:46 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebSetJobAsFSPOnSite.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Set Job status to FSP Onsite and add notes
DECLARE @ret int,
	@JobNotes varchar(255),
	@FSPOperatorNumber int,
	@FSPID int,
	@IsLiveDB bit


    --init
    SELECT @ret = 0

	SELECT @IsLiveDB = COUNT(*)   
	FROM tblControl  
	WHERE Attribute = 'IsLiveDB' and AttrValue = 'YES'

	 --Get Location for the user
	 SELECT @FSPOperatorNumber = 0 - InstallerID,
			@FSPID = InstallerID
	   FROM WebCAMS.dbo.tblUser
	  WHERE UserID = @UserID

	if @FSPOperatorNumber is null
		return @ret

	
	--build notes
	SELECT @JobNotes = dbo.fnCRLF() + 'FSP OnSite '  + dbo.fnGetOperatorStamp(@FSPOperatorNumber) + dbo.fnCRLF()

	--set IsMerchantDamaged to job equipment
	IF LEN(@JobID) = 11
	 BEGIN
		--update call status
		UPDATE Calls
		   SET StatusID = 24
		  WHERE CallNumber = @JobID
					
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

		if @Latitude is null ---geolocation not working on the smartphone, use job location
		 begin
			select 	@Latitude = Latitude,
					@Longitude	= Longitude
			  from vwCalls
			  where CallNumber = @JobID
		 end 
	 END
	ELSE
	 BEGIN
		--update job status
		UPDATE IMS_Jobs
		   SET StatusID = 24
		  WHERE JobID = @JobID

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

		if @Latitude is null ---geolocation not working	on the smartphone, use job location
		 begin
			select 	@Latitude = Latitude,
					@Longitude	= Longitude
			  from IMS_Jobs
			  where JobID = @JobID
		 end
					
	 END

	--log the onsite activities
	insert tblFSPOnSiteLog(
			FSPID,
			JobID,
			Latitude,
			Longitude,
			LoggedDate)
		select
			@FSPID,
			@JobID,
			@Latitude,
			@Longitude,
			GETDATE()

	-- SEND REMEDY UPDATE WHEN NECESSARY (CAMS-840)
	EXEC @ret = spSendRemedyStatusUpdate @JobID = @JobID, @JobStatus = 'On Site'
		
   Return @ret


GO

Grant EXEC on spWebSetJobAsFSPOnSite to eCAMS_Role
Go

Use WebCAMS
Go

If exists(select 1 from sysobjects where name = 'spWebSetJobAsFSPOnSite')
 drop proc dbo.spWebSetJobAsFSPOnSite
Go


Create Procedure dbo.spWebSetJobAsFSPOnSite 
	(
		@UserID int,
		@JobID bigint,
		@Latitude	float,
		@Longitude	float
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 3/05/04 2:25p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebSetJobAsFSPOnSite.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @ret int

 SET NOCOUNT ON

 EXEC @ret = Cams.dbo.spWebSetJobAsFSPOnSite @UserID = @UserID,
				@JobID = @JobID,
				@Latitude = @Latitude,
				@Longitude = @Longitude

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*
spWebSetJobAsFSPOnSite 199516
*/
Go

Grant EXEC on spWebSetJobAsFSPOnSite to eCAMS_Role
Go
