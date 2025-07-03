Use CAMS
Go

Alter Procedure dbo.spWebCloseFSPJob 
	(
		@UserID int,
		@JobID bigint,
		@TechFixID tinyint,
		@Notes varchar(250),
		@OnSiteDateTime datetime,
		@OffSiteDateTime datetime
	)
	AS
--<!--$$Revision: 36 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 5/04/13 14:02 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCloseFSPJob.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: FSP close Job from Web, @ClosedBy  = - (FSP InstallerID): closed by tech via web
DECLARE @JobTypeID tinyint,
	@ret int,

	--kit
	@KitSerial varchar(32),
	@KitMMD_ID varchar(5),
	@TerminalSerial varchar(32),
	@TerminalMMD_ID varchar(5),
	@PrinterSerial varchar(32),
	@PrinterMMD_ID varchar(5),
	@PinpadSerial varchar(32),
	@PinpadMMD_ID varchar(5),

	@Location int,
	@TerminalID varchar(20),
	@ClientID varchar(3),
	@JobFSP int,
	@JobExist bit,
	@KitExist bit,
	
	--call
	@State varchar(5),
	
	@ExtraInfoTypeID int,
	@ExtraInfoNotes varchar(2000),
	@ExtraInfoData varchar(2000),

	@JobNotes varchar(500),

	@OnSiteDateTimeOffset int,
	@OffSiteDateTimeOffset int,
	
	@STATUS_PDA_EXCEPTION tinyint,
	@CRLF varchar(2),
	@EXTRA_TYPE_FAILURE varchar(50),

	@FSPOperatorNumber int,

	@JobIDString varchar(11),

	@JobFixID int,
	@TechFixActionID tinyint,
	
	@CheckKitParts bit,

	@IsLiveDB int,

	@UpdateDateTime datetime,
	@Recipient varchar(100),
	@TemplateParameters varchar(1000),

	@ProblemNumber varchar(20)


 SET NOCOUNT ON


 --init
 SELECT @IsLiveDB = COUNT(*)   
 FROM tblControl  
 WHERE Attribute = 'IsLiveDB' and AttrValue = 'YES'

 SELECT @STATUS_PDA_EXCEPTION = 6, --'PDA EXCEPTION',
	@CRLF = CHAR(13) + CHAR(10),
	@EXTRA_TYPE_FAILURE = 'CLOSURE FAILURE',
	@JobIDString = CAST(@JobID as varchar(11)),
	@ret = 0
	
 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@Location


 --verify onsitedatetime, if it is older/newer than 20 days, log an exception
 IF ABS(DateDiff(d, getdate(), @OnSiteDateTime)) >= 20 
  BEGIN
	RAISERROR('OnSiteDateTime is more than 20 days old. Please contact Keycorp to close this job. Abort', 16, 1)

	SELECT @ret = -1

	GOTO Exit_Handle
  END

 IF  @OnSiteDateTime > @OffSiteDateTime
  BEGIN
	RAISERROR('OnSiteDateTime is later than OffSiteDateTime. Abort', 16, 1)

	SELECT @ret = -1

	GOTO Exit_Handle
  END
 
 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)

 IF dbo.fnIsSwapCall(@JobID) = 1  --calls only process
  --Swap Calls
  BEGIN
	--get call info
	SELECT @State = State,
		@JobFSP = AssignedTo,
		@TerminalID = TerminalID,
		@ClientID = ClientID,
		@ProblemNumber = ProblemNumber,
		@JobTypeID = 4 --swap
	  FROM Calls
	 WHERE CallNumber = @JobID


	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END
   END
 ELSE
   BEGIN
	SELECT @State = State,
		@JobTypeID = JobTypeID,	
		@JobFSP = BookedInstaller,
		@TerminalID = TerminalID,
		@ClientID = ClientID,
		@ProblemNumber = ProblemNumber
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END
   END

 --verify the job is belong to this user
 IF NOT EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
  BEGIN
	IF @JobExist = 1
	 BEGIN
		RAISERROR('Job [%s] is not assigned to FSP (%d) group. Abort', 16, 1, @JobIDString, @Location)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END
	ELSE
	 BEGIN
		RAISERROR('Job [%s] does not exist. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END

  END


 --get time zone offset
 SELECT	@OnSiteDateTimeOffset = dbo.fnGetTimeZoneOffset(@State, @OnSiteDateTime),
	@OffSiteDateTimeOffset = dbo.fnGetTimeZoneOffset(@State, @OffSiteDateTime)

 --collect OnSite/OffSite datetime first
 IF dbo.fnIsSwapCall(@JobID) = 1
  BEGIN
	UPDATE Calls
	   SET OnSiteDateTime = DateAdd(mi, -@OnSiteDateTimeOffset, @OnSiteDateTime), --adjust back melbourne time
		OnSiteDateTimeOffset = @OnSiteDateTimeOffset,
		OffSiteDateTime = DateAdd(mi, -@OffSiteDateTimeOffset, @OffSiteDateTime), --adjust back melbourne time
		OffSiteDateTimeOffset = @OffSiteDateTimeOffset  
	 WHERE CallNumber = @JobID


  END
 ELSE
  BEGIN
	UPDATE IMS_Jobs
	   SET OnSiteDateTime = DateAdd(mi, -@OnSiteDateTimeOffset, @OnSiteDateTime), --adjust back melbourne time
		OnSiteDateTimeOffset = @OnSiteDateTimeOffset,
		OffSiteDateTime = DateAdd(mi, -@OffSiteDateTimeOffset, @OffSiteDateTime), --adjust back melbourne time
		OffSiteDateTimeOffset = @OffSiteDateTimeOffset  
	 WHERE JobID = @JobID
  END



 --appending notes to jobs
 IF @Notes IS NOT NULL
  BEGIN
	SELECT @JobNotes = @Notes + @CRLF + 
				'OnSiteDateTime:' + CONVERT(varchar, @OnSiteDateTime, 120) + 
				' , OffSiteDateTime:' + CONVERT(varchar, @OffSiteDateTime, 120) + @CRLF +
				'(' + CAST(@FSPOperatorNumber as varchar) + ') ' + dbo.fnFormatDateTime(Getdate())

	IF dbo.fnIsSwapCall(@JobID) = 1
	 BEGIN
		EXEC dbo.spAddNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @JobNotes,
			@OperatorName = @FSPOperatorNumber
	 END
	ELSE
	 BEGIN
		EXEC dbo.spAddNotesToIMSJob 
			@JobID = @JobID,
			@NewNotes = @JobNotes,
			@OperatorName = @FSPOperatorNumber
	 END
	
  END

 --check if Option is TechFix selection

 SELECT @JobFixID = JobFixID,
	@TechFixActionID = TechFixActionID,
	@CheckKitParts = CheckKitParts
   FROM tblTechFixList
  WHERE JobTypeID = @JobTypeID
	AND TechFixID = @TechFixID			

 IF dbo.fnIsSwapCall(@JobID) = 1
  BEGIN
	UPDATE Calls
	   SET TechFixID = @TechFixID
	 WHERE CallNumber = @JobID
  END
 ELSE
  BEGIN
	UPDATE IMS_Jobs
	   SET TechFixID = @TechFixID
	 WHERE JobID = @JobID
  END

 --after collect onsite and fix, check if FSP comfirm the kitting parts usage
 if dbo.fnIsSwapCall(@JobID) = 1 and @CheckKitParts = 1
  begin
	if exists(select 1 from Call_Equipment ce with (nolock) join vwPIMCurrentDeviceKit dk with (nolock) on ce.NewMMD_ID = dk.MMD_ID and ce.NewSerial = dk.Serial
				where ce.CallNumber = @JobID and dbo.fnIsSerialisedDevice(ce.NewSerial) = 1 and dk.ItemType='E')
	 begin
		if not exists(select 1 from tblFSPKitPartUsageConfirmLog where JobID = @JobID)
		 begin
			RAISERROR('Kitted device is used for the job. Please confirm kitted parts usage prior closing the job. Abort.', 16, 1)
			SELECT @ret = -1
			GOTO Exit_Handle
		 end
	 end
  end


 --FSP escalate job to EE service desk
 IF @TechFixActionID = 3 --EE to review: Raise PDA exception and job to remain open
  BEGIN
	 IF dbo.fnIsSwapCall(@JobID) = 1
	  BEGIN
		--collect OnSiteDateTime/OffSiteDateTime
		UPDATE Calls
		   SET StatusID = @STATUS_PDA_EXCEPTION,
			AllowPDADownload = 0
		 WHERE CallNumber = @JobID
	  END
	 ELSE
	  BEGIN
		--collect OnSiteDateTime/OffSiteDateTime
		UPDATE IMS_Jobs
		   SET StatusID = @STATUS_PDA_EXCEPTION,
			AllowPDADownload = 0
		 WHERE JobID = @JobID
	  END
	GoTo Exit_Handle

  END
  
 --swap device, must have device-in/out
 if @TechFixID = 1 and dbo.fnIsSwapCall(@JobID) = 1
  begin
	if not exists(select 1 from Call_Equipment where CallNumber = @JobID and dbo.fnIsSerialisedDevice(serial) = 1 and dbo.fnIsSerialisedDevice(NewSerial) = 1)
	 begin
		RAISERROR('Must scan device in/out prior closing the job. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GoTo Exit_Handle
	 end
  end
  
 --if tech choose fix of (2/SWAPPED POWERPACK)
 --swap must have call parts selected
 if @TechFixID in (2) and dbo.fnIsSwapCall(@JobID) = 1
  begin
	if not exists(select 1 from Call_Parts where CallNumber = @JobID)
	 begin
		RAISERROR('Must select parts used prior closing the job. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GoTo Exit_Handle
	 end
  end

 --if tech choose fix of (19/BATTERY REPLACED ON SITE,3/REPLACED CABLE)
 --swap must have call parts selected
 if @TechFixID in (3,19) and dbo.fnIsSwapCall(@JobID) = 1 and @ClientID in ('CBA', 'HIC')
  begin
	if not exists(select 1 from Call_Parts where CallNumber = @JobID)
	 begin
		RAISERROR('Must select parts used prior closing the job. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GoTo Exit_Handle
	 end
  end

--if tech choose fix of (22/COMPLETED - SWAPPED SIM)
--job must have inventory extra info record indicating a bundled sim swap has occurred
  if @TechFixID = 22
	begin
		if not exists (SELECT 1 
						FROM tblInventoryExtraInfo 
						WHERE TypeID in (SELECT TypeID FROM tblInventoryExtraInfoType WHERE [Type] = 'BUNDLED SIM SWAP') and InfoData = cast(@JobID as varchar(20)))
			begin
				RAISERROR('Must swap bundled SIM prior closing the job. Abort', 16, 1, @JobIDString)
				SELECT @ret = -1
				GoTo Exit_Handle
			end
	end

  exec @ret = spEnsurePartCompliance @JobID = @JobID,
									 @Validate = 1

  if (@ret = -1)
	begin
		RAISERROR('Compliant parts have not been used correctly. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GoTo Exit_Handle
	end
  
 --OK, let's close the job
 IF dbo.fnIsSwapCall(@JobID) = 1
  BEGIN
	--close the call
	EXEC @ret = dbo.spCloseCall 
			@CallNumber = @JobID,
			@OnSiteDate = @OnSiteDateTime,
			@OnSiteTime = @OnSiteDateTime,
			@OffSiteDate = @OffSiteDateTime,
			@OffSiteTime = @OffSiteDateTime,
			@ClosedBy = @FSPOperatorNumber,
			@FixID = @JobFixID,
			@Notes = @Notes
  
	IF @ret <> 0 
	 BEGIN
		GOTO Exit_Handle
	 END

 END
 ELSE
  BEGIN
	 ----Check if Serial number assigned
	 --IF EXISTS(SELECT 1 FROM IMS_Job_Equipment WHERE JobID = @JobID AND dbo.fnIsSerialisedDevice(ISNULL(Serial, '')) = 0) 
	 -- BEGIN
		--RAISERROR ('Unable to close the job as complete until all serial numbers have been entered.', 16, 1)
		--SELECT @ret = -1
		--GOTO Exit_Handle			
	 -- END

	--** Validation on the job
	--**  2. Unpack kit
	--**  3. close the job

	IF @JobTypeID IN (1, 3) --('INSTALL','UPGRADE' )	--unpack kit
	 BEGIN
		SELECT @KitSerial = je.Serial,
			@KitMMD_ID = je.MMD_ID
		  FROM IMS_Job_Equipment je JOIN tblKit k ON je.MMD_ID = k.Kit_MMD_ID
		  WHERE je.JobID = @JobID

		SELECT @KitExist = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END

		--unpack kit if kit exists
		IF @KitExist = 1
		 BEGIN
			--get details of the kit
			SELECT @TerminalSerial = TerminalSerial,
				@TerminalMMD_ID = TerminalMMD_ID,
				@PrinterSerial = PrinterSerial,
				@PrinterMMD_ID = PrinterMMD_ID,
				@PinpadSerial = PinpadSerial,
				@PinpadMMD_ID = PinpadMMD_ID
			  FROM Equipment_Kits 
			 WHERE  KitSerial =  @KitSerial 
				 AND KitMMD_ID = @KitMMD_ID 



			--unpack the kit to condition of 19
			EXEC @ret = dbo.spUnPackKit 
				@UnPackCondition = 19,
				@KitSerial = @KitSerial,
				@KitMMD_ID = @KitMMD_ID,
				@TerminalSerial = @TerminalSerial,
				@TerminalMMD_ID = @TerminalMMD_ID,
				@PrinterSerial = @PrinterSerial,
				@PrinterMMD_ID = @PrinterMMD_ID,
				@PinpadSerial = @PinpadSerial,
				@PinpadMMD_ID = @PinpadMMD_ID,
				@Operator = @FSPOperatorNumber

			--failed to unpack the kit, return
			IF @ret <> 0
			 BEGIN
			
				--set onsite/offsite datetme
				GOTO Exit_Handle

			 END
				
	
		 END --IF @KitExist = 1
	 END --IF @JobType IN ('INSTALL','UPGRADE' )	--unpack kit


	--install job
	IF @JobTypeID = 1 --'INSTALL' 
	 BEGIN
		--close the job
		EXEC @ret = dbo.spCloseIMSInstallJob
			@JobID = @JobID,
			@OnSiteDate = @OnSiteDateTime,
			@OnSiteTime = @OnSiteDateTime,
			@OffSiteDate = @OffSiteDateTime,
			@OffSiteTime = @OffSiteDateTime,
			@ClosedBy = @FSPOperatorNumber,
			@CloseComment = NULL,
			@FixID = @JobFixID,
			@IsPurgeJob = 1,
			@Notes = @Notes

		IF @ret <> 0
		 BEGIN
			--set onsite/offsite datetime
			GOTO Exit_Handle
		 END
	 END


	IF @JobTypeID = 2 --'DEINSTALL'
	 BEGIN
		--verify the deinstall job

		--close it
		EXEC @ret = dbo.spCloseIMSDeInstallJob
			@JobID = @JobID,
			@OnSiteDate = @OnSiteDateTime,
			@OnSiteTime = @OnSiteDateTime,
			@OffSiteDate = @OffSiteDateTime,
			@OffSiteTime = @OffSiteDateTime,
			@ClosedBy = @FSPOperatorNumber,
			@CloseComment = NULL,
			@FixID = @JobFixID,
			@IsPurgeJob = 1,
			@Notes = @Notes

		IF @ret <> 0 
		 BEGIN

			--set onsite/offsite datetime
			GOTO Exit_Handle
		 END
	 END
	
	IF @JobTypeID = 3 --'UPGRADE'
	 BEGIN
		--verify the upgrade job

		--close it
		EXEC @ret = dbo.spCloseIMSUpgradeJob
			@JobID = @JobID,
			@OnSiteDate = @OnSiteDateTime,
			@OnSiteTime = @OnSiteDateTime,
			@OffSiteDate = @OffSiteDateTime,
			@OffSiteTime = @OffSiteDateTime,
			@ClosedBy = @FSPOperatorNumber,
			@CloseComment = NULL,
			@FixID = @JobFixID,
			@Notes = @Notes

		IF @ret <> 0
		 BEGIN

			--set onsite/offsite datetime
			GOTO Exit_Handle

		 END
	 END
  END --ims job

Exit_Handle:
  RETURN @ret
GO

--Grant EXEC on spWebCloseFSPJob to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebCloseFSPJob 
	(
		@UserID int,
		@JobID bigint,
		@TechFixID tinyint,
		@Notes varchar(250),
		@OnSiteDateTime datetime,
		@OffSiteDateTime datetime
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebCloseFSPJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebCloseFSPJob @UserID = @UserID,
		@JobID = @JobID,
		@TechFixID = @TechFixID,
		@Notes = @Notes,
		@OnSiteDateTime = @OnSiteDateTime,
		@OffSiteDateTime = @OffSiteDateTime

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret
/*

spWebCloseFSPJob @UserID = 199516,
		@JobID = 221895,
		@OnSiteDateTime = '2004-01-05 14:30:00',
		@OffSiteDateTime = '2004-01-05 15:00:00'

*/
Go

--Grant EXEC on spWebCloseFSPJob to eCAMS_Role
Go

