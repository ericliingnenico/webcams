Use WebCAMS
Go

Alter PROCEDURE dbo.spWebValidateTIDBeforeLogJob 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20),
		@JobTypeID tinyint
	)
	AS
--<!--$$Revision: 25 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 25/01/16 15:34 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebValidateTIDBeforeLogJob.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
DECLARE @ret int
 SET NOCOUNT ON
 --init 
 SELECT @ret = -1

 IF EXISTS(SELECT 1 FROM tblUser u join vwUserClient uc ON u.UserID = uc.UserID and uc.ClientID = @ClientID and u.UserID = @UserID)
  BEGIN
 	EXEC @ret = CAMS.dbo.spWebValidateTIDBeforeLogJob @UserID = @UserID, @ClientID = @ClientID, @TerminalID = @TerminalID, @JobTypeID = @JobTypeID
  END


 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*
spWebValidateTIDBeforeLogJob 199955, 'boq', '30015108', 4
select * from webCAMS.dbo.tblUSer
 where emailaddress = 'boq'


*/
Go

Grant EXEC on spWebValidateTIDBeforeLogJob to eCAMS_Role
Go


Use CAMS
Go

Alter Procedure dbo.spWebValidateTIDBeforeLogJob 
	(
		@UserID int,
		@ClientID varchar(3),
		@TerminalID varchar(20),
		@JobTypeID tinyint
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/03/03 17:02 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebValidateTIDBeforeLogJob.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @ret int,
	@SiteExist bit,
	@JobExist bit,	
	@CallExist bit,
	@STATUS_PDAEXCEPTION tinyint,
	@STATUS_FSPEXCEPTION tinyint,
	@STATUS_COMPLETED tinyint,
	@STATUS_INSTALLED tinyint,
	@STATUS_CANCEL_PEND tinyint,
	@SiteExistWithCorrectDeviceType bit,
	@NonShortermRentalJobExist bit





 set nocount on

 --init
 SELECT @ret = 0,
	@SiteExist = 0,
	@CallExist = 0,
	@JobExist = 0,
	@STATUS_PDAEXCEPTION = 6,
	@STATUS_FSPEXCEPTION = 7,
	@STATUS_COMPLETED = 5,
	@STATUS_INSTALLED = 20,
	@STATUS_CANCEL_PEND = 15,
	@SiteExistWithCorrectDeviceType = 0,
	@NonShortermRentalJobExist = 0

 --common validation

 --TID exists in job/call
 IF EXISTS(SELECT 1 FROM IMS_Jobs WITH (NOLOCK) WHERE ClientID = @ClientID AND TerminalID = @TerminalID
								 AND StatusID NOT IN (@STATUS_PDAEXCEPTION, @STATUS_FSPEXCEPTION, @STATUS_COMPLETED, @STATUS_INSTALLED, @STATUS_CANCEL_PEND))
  BEGIN
	SELECT 	@JobExist = 1
  END


 IF EXISTS(SELECT 1 FROM Calls WITH (NOLOCK) WHERE ClientID = @ClientID AND TerminalID = @TerminalID
								AND StatusID NOT IN (@STATUS_PDAEXCEPTION, @STATUS_FSPEXCEPTION, @STATUS_COMPLETED)
								and isnull(ProjectNo, '') not in ('HICVISASEC','HIC_BASE'))
  BEGIN
	SELECT 	@CallExist = 1
	if @ClientID = 'SUN' and @TerminalID ='99400' --#7481 SUBJECT: SUNCORP - LOGGING MULTIPLE JOBS UNDER TID 99400
	 begin
		SELECT 	@CallExist = 0
	 end
  END

 IF EXISTS(SELECT 1 FROM Sites WITH (NOLOCK) WHERE ClientID = @ClientID AND TerminalID = @TerminalID)
  BEGIN
	SELECT 	@SiteExist = 1
  END

 IF EXISTS(SELECT 1 FROM Sites s WITH (NOLOCK) JOIN WebCams.dbo.tblUserClientDeviceType u WITH (NOLOCK) ON s.ClientID = u.ClientID AND isnull(s.DeviceType, '') = ISNULL(u.DeviceType, isnull(s.DeviceType, ''))
					WHERE s.ClientID = @ClientID AND s.TerminalID = @TerminalID AND u.UserID = @UserID)
  BEGIN
	SELECT 	@SiteExistWithCorrectDeviceType = 1
  END

 IF EXISTS(SELECT 1 FROM IMS_Jobs WITH (NOLOCK) WHERE ClientID = @ClientID AND TerminalID = @TerminalID
								 AND StatusID NOT IN (@STATUS_PDAEXCEPTION, @STATUS_FSPEXCEPTION, @STATUS_COMPLETED, @STATUS_INSTALLED, @STATUS_CANCEL_PEND)
								 AND isnull(ShortTermRentalYN, 0) = 0 )
  BEGIN
	SELECT 	@NonShortermRentalJobExist = 1
  END

 --Install Jobs
 IF @JobTypeID = 1
  BEGIN
	--stop if site exists
	IF @SiteExist = 1  and @ClientID not in ('CBA')
	  BEGIN
		RAISERROR('The merchant site already exists in CAMS. Can not log this install request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--stop if job exists
	IF @JobExist = 1
	  BEGIN
		RAISERROR('An open job on this terminalID already exists in CAMS. Can not log this install request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--stop if call exists
	IF @CallExist = 1
	  BEGIN
		RAISERROR('An open swap job on this terminalID already exists in CAMS. Can not log this install request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

  END

 --DeInstall Jobs
 IF @JobTypeID = 2 and @ClientID not in ('CBA')
  BEGIN
	--stop if site does not exist
	IF @SiteExist = 0
	  BEGIN
		RAISERROR('The merchant site does not exist in CAMS. Can not log this closure request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	IF @SiteExistWithCorrectDeviceType = 0
	  BEGIN
		RAISERROR('You do not have permission to access the merchant site. Can not log this closure request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--stop if job exist
	IF @JobExist = 1
	  BEGIN
		RAISERROR('An open job on this terminalID already exists in CAMS. Can not log this clsoure request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--stop if call exist
	IF @CallExist = 1
	  BEGIN
		RAISERROR('An open swap job on this terminalID already exists in CAMS. Can not log this closure request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

  END

 --Upgrade Jobs
 IF @JobTypeID = 3
  BEGIN
	--stop if site does not exist
	IF @SiteExist = 0
	  BEGIN
		RAISERROR('The merchant site does not exist in CAMS. Can not log this upgrade request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	IF @SiteExistWithCorrectDeviceType = 0
	  BEGIN
		RAISERROR('You do not have permission to access the merchant site. Can not log this upgrade request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--stop if job exist
	IF @NonShortermRentalJobExist = 1
	  BEGIN
		RAISERROR('An open job on this terminalID already exists in CAMS. Can not log this upgrade request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--stop if call exist
	IF @CallExist = 1
	  BEGIN
		RAISERROR('An open swap job on this terminalID already exists in CAMS. Can not log this upgrade request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

  END

 --Swap
 IF @JobTypeID = 4
  BEGIN
	--stop if site does not exist
	IF @SiteExist = 0
	  BEGIN
		RAISERROR('The merchant site does not exist in CAMS. Can not log this swap request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END


	IF @SiteExistWithCorrectDeviceType = 0
	  BEGIN
		RAISERROR('You do not have permission to access the merchant site. Can not log this swap request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--No need to stop if job exist, we are going to load upgrade job to system at day one

	--stop if call exist
	IF @CallExist = 1
	  BEGIN
		RAISERROR('An open swap job on this terminalID already exists in CAMS. Can not log another one, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END
	--stop NAB to log swap on secondary TID
	if @ClientID in ('NAB', 'HIC') and dbo.fnIsSecondaryTID(@ClientID, @TerminalID) = 1
	  BEGIN
		RAISERROR('Can not log a swap on a secondary TID, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--#7198: CHANGE TO NAB SWAP LOGGING
/*
	if @ClientID in ('NAB') and @TerminalID	like 'B%'
	 begin
		raiserror('THIS FUNCTION IS NOT ALLOWED PLEASE TRANSFER CALL TO INTEGRATED HELP DESK 9403 1637.', 16, 1)
		select @ret = -1
		goto Exit_Handle
	 end
*/

  END

 --Additional service
 IF @JobTypeID = 5
  BEGIN
	--stop if site does not exist
	IF @SiteExist = 0
	  BEGIN
		RAISERROR('The merchant site does not exist in CAMS. Can not log this aditional service request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	IF @SiteExistWithCorrectDeviceType = 0
	  BEGIN
		RAISERROR('You do not have permission to access the merchant site. Can not log this aditional service request, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END

	--No need to stop if job exist
	--stop if addiitonal service request exists
	IF EXISTS(SELECT 1 FROM Calls WITH (NOLOCK) WHERE  ClientID = @ClientID AND TerminalID = @TerminalID AND (SymptomID = 800 OR FaultID = 2225))
	  BEGIN
		RAISERROR('An additional service request already exists in CAMS. Can not log another one, aborted', 16, 1)
	 	SELECT @ret = -1
		GOTO Exit_Handle
	  END


  END


--Return
Exit_Handle:
RETURN @ret

GO

Grant EXEC on spWebValidateTIDBeforeLogJob to eCAMS_Role
Go


