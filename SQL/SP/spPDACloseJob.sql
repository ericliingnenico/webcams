USE [CAMS]
GO
/****** Object:  StoredProcedure [dbo].[spPDACloseJob]    Script Date: 3/05/2018 10:45:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[spPDACloseJob] 
	(
		@UserID int,
		@JobID bigint,
		@OnSiteDateTime datetime,
		@OffSiteDateTime datetime,
		@TechFixID tinyint
	)
	AS
--<!--$$Revision: 73 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 4/04/12 13:35 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDACloseJob.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Close Job from PDA device, @ClosedBy  = - (FSP InstallerID): closed by tech via PDA
-- 16/12/2005: Capture OnSite/OffSite datetime brefore proceed to close job
-- 19/12/2005: set closure context info for spCloseCall/spCloseIMSInstallJob/spCloseIMSDeIntallJob 
--		to raise error as PDA exception for EE operator reference
-- 1/3/2006: FSP norminates TechFix
-- 09/07/2007 Bo Added handling NOINOUT (Ref: Task 1364 - #3036: Handling Upgrades without a device change)
-- 19/03/2008 Bo Added PDAJobClosureLog
-- 28/03/2008 Bo Removed FSP 6000 trial restriction
-- 04/04/2012 Bo Added CBA Battery replacement for call
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
	@JobFSP int,
	@JobExist bit,
	@KitExist bit,
	
	--call
	@State varchar(5),

	@OnSiteDateTimeOffset int,
	@OffSiteDateTimeOffset int,


	@IsOK bit,
	
	@STATUS_PDA_EXCEPTION tinyint,

	@FSPOperatorNumber int,

	@JobFixID int,
	@TechFixActionID tinyint,

	@CRLF varchar(2),

	@NoDeviceInOut 		bit,
	@ProjectNo varchar(20),
	
	@ClientID  varchar(3),
	@TerminalID varchar(20)


 SET NOCOUNT ON
 --init
 SELECT @IsOK = 1,
	@STATUS_PDA_EXCEPTION = 6,  --'PDA EXCEPTION',
	@CRLF = CHAR(13) + CHAR(10),
	@NoDeviceInOut = 0
	
 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@Location

 --log into tblPDAJobClosureLog
 INSERT tblPDAJobClosureLog (
	UserID,
	JobID,
	OnSiteDateTime,
	OffSiteDateTime,
	TechFixID,
	LoggedDateTime)
 VALUES (
	@UserID,
	@JobID,
	@OnSiteDateTime,
	@OffSiteDateTime,
	@TechFixID,
	getdate())


 IF dbo.fnIsSwapCall(@JobID) = 1
  --Swap Calls
  BEGIN
	--get call info
	SELECT @State = State,
		@JobTypeID = 4, --swap
		@ClientID = ClientID,
		@JobFSP = AssignedTo
	  FROM Calls
	 WHERE CallNumber = @JobID


	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

   END --swap call
 ELSE
  --IMS Jobs
  BEGIN
	SELECT @State = State,
		@JobTypeID = JobTypeID,	
		@JobFSP = BookedInstaller,
		@ProjectNo = ProjectNo,
		@ClientID = ClientID,
		@TerminalID = TerminalID
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	SELECT @NoDeviceInOut = CASE WHEN Exists(select 1 from tblProject Where ProjectNo = @ProjectNo and dbo.fnGetXMLValue(ClosureXML, 'NoDeviceInOut') = 'yes') THEN 1 
								ELSE dbo.fnSiteNoNeedToDeactivate(@ClientID, @TerminalID)
							END


	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END
   END --IMS Job

 --Get JobFixID and TechFixActionID
 SELECT @JobFixID = JobFixID,
	@TechFixActionID = TechFixActionID
   FROM tblTechFixList
  WHERE JobTypeID = @JobTypeID
	AND TechFixID = @TechFixID


 --Get time zone offset
 IF @State IS NOT NULL
  BEGIN
	SELECT	@OnSiteDateTimeOffset = dbo.fnGetTimeZoneOffset(@State, @OnSiteDateTime),
		@OffSiteDateTimeOffset = dbo.fnGetTimeZoneOffset(@State, @OffSiteDateTime)
	


	IF @OnSiteDateTimeOffset IS NOT NULL
	  BEGIN
		SELECT @OnSiteDateTime = DateAdd(mi, -@OnSiteDateTimeOffset, @OnSiteDateTime),
			@OffSiteDateTime = DateAdd(mi, -@OffSiteDateTimeOffset, @OffSiteDateTime)

	  END



  END
 
 --Capture OnSiteDateTime/OffSiteDateTime and TechFix/JobFix before closing job
 IF dbo.fnIsSwapCall(@JobID) = 1
  BEGIN
	--Calls
	UPDATE Calls
	   SET OnSiteDateTime = @OnSiteDateTime,
		OnSiteDateTimeOffset = @OnSiteDateTimeOffset,
		OffSiteDateTime = @OffSiteDateTime,
		OffSiteDateTimeOffset = @OffSiteDateTimeOffset,
		FixID = @JobFixID,
		TechFixID = @TechFixID
	  WHERE CallNumber = @JobID
	  
	--CBA Battery replacement
	if @ClientID = 'CBA' and @TechFixID = 19 --19	BATTERY REPLACED ON SITE
	 begin
		if not exists(select 1 from Call_Parts where CallNumber = @JobID and PartID = 'CBY01')
		 begin
			insert Call_Parts (CallNumber, PartID, Qty) 
				select @JobID, 'CBY01', 1
		 end
	 end	
	
  END
 ELSE
  BEGIN
	--IMS Jobs
	UPDATE IMS_Jobs
	   SET OnSiteDateTime = @OnSiteDateTime,
		OnSiteDateTimeOffset = @OnSiteDateTimeOffset,
		OffSiteDateTime = @OffSiteDateTime,
		OffSiteDateTimeOffset = @OffSiteDateTimeOffset,
		FixID = @JobFixID,
		TechFixID = @TechFixID
	  WHERE JobID = @JobID
  END

 --since new process won't update device if there are exceptions
 --we have to check if there is any exception in the log before close job
 IF EXISTS(SELECT 1 FROM tblPDAException WHERE JobID = @JobID)
  BEGIN
	--yes, there is an exception, capture on/off site datetime, abort
	--set to not OK
	SELECT @IsOK = 0

	--set onsite/offsite datetime
	GOTO ExceptionExit

  END


 --verify onsitedatetime, if it is older/newer than 2 days, log an exception
 IF ABS(DateDiff(d, getdate(), @OnSiteDateTime)) >= 2 
  BEGIN
	INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, UpdateDateTime)
		Values (@JobID, 11, '', '', GetDate())

	--set to not OK
	SELECT @IsOK = 0

	--set onsite/offsite datetime
	GOTO ExceptionExit
  END
 
 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)


 --convert OnSiteDateTime/OffSiteDateTime to merchant local time zone for the requirement of closure SP
 --MS web service automatically convert datetime to web server local time zone
 IF @OnSiteDateTimeOffset IS NOT NULL
  BEGIN
	SELECT @OnSiteDateTime = DateAdd(mi, @OnSiteDateTimeOffset, @OnSiteDateTime),
		@OffSiteDateTime = DateAdd(mi, @OffSiteDateTimeOffset, @OffSiteDateTime)

  END


 --set context info for closure
 EXEC spSetContextInfo @Section = 1, @Value = 'Y' 

 IF @TechFixActionID IN (1, 2) ---Complete: Close job, Failed: Close job and log new job
  BEGIN
	 IF dbo.fnIsSwapCall(@JobID) = 1 --calls only process
	  --Swap Calls
	  BEGIN
		--verify the job is belong to this user
		IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
		 BEGIN
	
			--OK close the call
			IF @IsOK = 1
			 BEGIN
				--close the call
				EXEC @ret = dbo.spCloseCall 
						@CallNumber = @JobID,
						@OnSiteDate = @OnSiteDateTime,
						@OnSiteTime = @OnSiteDateTime,
						@OffSiteDate = @OffSiteDateTime,
						@OffSiteTime = @OffSiteDateTime,
						@ClosedBy = @FSPOperatorNumber,
						@FixID = @JobFixID
	
				IF @ret <> 0 
				 BEGIN
					--set not OK
					SELECT @IsOK = 0
					--set onsite/offsite datetime
					GOTO ExceptionExit
				 END
	
			 END
			 		
		 END --job exists
		ELSE
		 BEGIN
			--otherwise, no exception to be logged
			IF @JobExist = 1
			 BEGIN
				--job does exist but not belong to this user
				--log exception
				INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, UpdateDateTime)
					Values (@JobID, 9, 'Failed to close', null, GetDate())
		
				--set to not OK
				SELECT @IsOK = 0
		
				--set onsite/offsite datetime
				GOTO ExceptionExit
			 END
	
		 END --job does not exist
	  END --swap job
	 ELSE
	  --IMS Jobs
	  BEGIN
	
		--verify the job is belong to this user
		IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
		 BEGIN
			--** Validation on the job
			--**  1. Cleanup on DEINSTALL/UPGRADE job: 
			--**	No serialised item in job equipemnt, log exception
			--**	There are serialised items, delete non-serialised items (Un-use ones)
			--**  2. Unpack kit
			--**  3. close the job
	
			IF @JobTypeID IN (2, 3) AND @TechFixActionID = 1  --Complete: Close job
			 BEGIN
				--Cleanup on DEINSTALL job
				IF EXISTS(SELECT 1 FROM IMS_Job_Equipment 
							WHERE JobID = @JobID 
								AND len(Serial) > 15
								AND ActionID = 2)  --'REMOVE'
				 --there are some serialised items, delete non-serilised items
				 BEGIN
					DELETE IMS_Job_Equipment
					  WHERE JobID= @JobID
						AND dbo.fnIsSerialisedDevice(Serial) = 0
						AND ActionID = 2 --'REMOVE'
	
				 END
				ELSE
				 BEGIN
					--check if it is a special upgrade without device in/out
					IF @NoDeviceInOut = 0   --Need to check device in/out
					 BEGIN
						--log the exception - 'Close job - No serialised device specified for DEINSTALL job.'
						INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, UpdateDateTime)
							Values (@JobID, 7, NULL, NULL, GetDate())
			
						--set to not OK
						SELECT @IsOK = 0
			
						--quit
						GOTO ExceptionExit
					 END  --IF @NoDeviceInOut = 0

				 END
			 END
	
	
			IF @JobTypeID IN (1,3) --('INSTALL','UPGRADE' )	--unpack kit
			 BEGIN
				SELECT @KitSerial = je.Serial,
					@KitMMD_ID = je.MMD_ID
				  FROM IMS_Job_Equipment je JOIN tblKit k ON je.MMD_ID = k.Kit_MMD_ID
				  WHERE je.JobID = @JobID
					AND dbo.fnIsSerialisedDevice(je.Serial) = 1
	
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
	
	
					IF @@ROWCOUNT = 0 
					 --kit does not exist
					 BEGIN
						--log the exception - unpack kit error
						INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
							Values (@JobID, 5, @KitSerial, @KitMMD_ID, null, null, GetDate())
		
			
						--set to not OK
						SELECT @IsOK = 0
						
						--set onsite/offsite datetme
						GOTO ExceptionExit
		
					 END
	
					SELECT Serial,
						MMD_ID
					  INTO #myKit
					  FROM IMS_Job_Equipment
					 WHERE JobID = @JobID
		
					--verify if the kit equipments are in this job equipment. 
					IF NOT EXISTS(SELECT 1 FROM #myKit WHERE MMD_ID = @TerminalMMD_ID AND Serial = @TerminalSerial)
					 --terminal device mixed up with kit			 
					 BEGIN
						--log the exception - unpack kit error
						INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
							Values (@JobID, 8, @KitSerial, @KitMMD_ID, @TerminalSerial, @TerminalMMD_ID, GetDate())
		
			
						--set to not OK
						SELECT @IsOK = 0
						
						--set onsite/offsite datetme
						GOTO ExceptionExit
		
					 END
						
					--verify if the kit equipments are in this job equipment. 
					IF NOT EXISTS(SELECT 1 FROM #myKit WHERE MMD_ID = @PrinterMMD_ID AND Serial = @PrinterSerial)
					 --printer device mixed up with the other kit
					 BEGIN
						--log the exception - unpack kit error
						INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
							Values (@JobID, 8, @KitSerial, @KitMMD_ID, @PrinterSerial, @PrinterMMD_ID, GetDate())
		
			
						--set to not OK
						SELECT @IsOK = 0
						
						--set onsite/offsite datetme
						GOTO ExceptionExit
		
					 END
		
					IF NOT(@PinpadSerial IS NULL OR @PinpadMMD_ID IS NULL)
					 BEGIN
						--verify if the kit equipments are in this job equipment. 
						IF NOT EXISTS(SELECT 1 FROM #myKit WHERE MMD_ID = @PinpadMMD_ID AND Serial = @PinpadSerial)
						 --pinpad device mixed up with the other kit
						 BEGIN
							--log the exception - unpack kit error
							INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
								Values (@JobID, 8, @KitSerial, @KitMMD_ID, @PinpadSerial, @PinpadMMD_ID, GetDate())
			
				
							--set to not OK
							SELECT @IsOK = 0
							
							--set onsite/offsite datetme
							GOTO ExceptionExit
			
						 END
		
					 END
			
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
						--log the exception - unpack kit error
						INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, UpdateDateTime)
							Values (@JobID, 5, @KitSerial, @KitMMD_ID, GetDate())
		
			
						--set to not OK
						SELECT @IsOK = 0
						
						--set onsite/offsite datetme
						GOTO ExceptionExit
		
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
					@IsPurgeJob = 1
	
				IF @ret <> 0
				 BEGIN
					--set to not OK
					SELECT @IsOK = 0
					--set onsite/offsite datetime
					GOTO ExceptionExit
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
					@IsPurgeJob = 1
	
				IF @ret <> 0 
				 BEGIN
					--set to not ok 
					SELECT @IsOK = 0
	
					--set onsite/offsite datetime
					GOTO ExceptionExit
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
					@FixID = @JobFixID
	
				IF @ret <> 0
				 BEGIN
					--set to not OK
					SELECT @IsOK = 0
	
					--set onsite/offsite datetime
					GOTO ExceptionExit
	
				 END
			 END
		 END --job exists
		ELSE
		 BEGIN
			IF @JobExist = 1
			 BEGIN
				--job does exist but not belong to this user, log this exception
				--log exception
				INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, UpdateDateTime)
					Values (@JobID, 9, 'Failed to close', null, GetDate())
		
				--set to not OK
				SELECT @IsOK = 0
		
				--set onsite/offsite datetime
				GOTO ExceptionExit
	
			 END
			--otherwise, no need to log an exception
	
		 END --job does not exist
	  END --ims job
  END -- IF @TechFixActionID IN (1, 2) ---Complete: Close job, Failed: Close job and log new job

 IF @TechFixActionID = 3 --EE to review: Raise PDA exception and job to remain open
  BEGIN
	--FSP can not nominate JobFixID and request EE to review the job.
	--log exception
	INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, UpdateDateTime)
		Values (@JobID, 14, 'EE to review', null, GetDate())

	--set to not OK
	SELECT @IsOK = 0

	--set onsite/offsite datetime
	GOTO ExceptionExit
  END

  

ExceptionExit:
 
 --reset context info for closure
 EXEC spSetContextInfo @Section = 1, @Value = ''

 IF @IsOK = 0
 --exception handling: set onsite/offsite datetime, set status as PDA Exception and switch off AllowPDADownload
  BEGIN
	--no exception in log, log one for general infor.
	IF NOT EXISTS(SELECT 1 FROM tblPDAException WHERE JobID = @JobID)
	  BEGIN
		INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, UpdateDateTime)
				Values (@JobID, 10, Null, Null, GetDate())

	  END

	--send exception report before return
	--Call send FSP an exception report if the FSP has its GetPDAExceptionReport = 1 in Locations_Master
	EXEC dbo.spPDASendFSPExceptionReport 
			@UserID = @UserID,
			@JobID = @JobID

	IF dbo.fnIsSwapCall(@JobID) = 1
	 --call
	 BEGIN
		--disable trigger on Calls
		INSERT tblTriggerTrace(ActionType, TriggerName, SPID)
			VALUES (1, 'tr_Calls_PDAException', @@SPID)

		UPDATE Calls
		   SET StatusID = CASE WHEN StatusID = 8 THEN StatusID ELSE @STATUS_PDA_EXCEPTION END,
			AllowPDADownload = 0
		 WHERE CallNumber = @JobID


		 Return -1
	 END
	ELSE
	 --ims jobs
	 BEGIN
		--disable trigger on Calls
		INSERT tblTriggerTrace(ActionType, TriggerName, SPID)
			VALUES (1, 'tr_IMSJobs_PDAException', @@SPID)

		UPDATE IMS_Jobs
		   SET StatusID = CASE WHEN StatusID = 8 THEN StatusID ELSE @STATUS_PDA_EXCEPTION END,
			AllowPDADownload = 0
		 WHERE JobID = @JobID

		 Return -1

	 END


	
  END 

GO
