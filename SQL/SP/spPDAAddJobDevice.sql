USE [CAMS]
GO
/****** Object:  StoredProcedure [dbo].[spPDAAddJobDevice]    Script Date: 3/05/2018 10:45:18 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER Procedure [dbo].[spPDAAddJobDevice] 
	(
		@UserID int,
		@JobID bigint,
		@Serial varchar(32),
		@MMD_ID varchar(5),
		@NewSerial varchar(32),
		@NewMMD_ID varchar(5),
		@Action smallint
	)
	AS
--<!--$$Revision: 86 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 29/11/11 13:55 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAAddJobDevice.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add new device to IMS jobs/calls
--- Swap jobs: DeviceIn = @NewSerial/@NewMMD_ID 
---		DeviceOut = @Serial/@MMD_ID
--- Upgrade jobs: DeviceIn = @NewSerial/@NewMMD_ID 
---		DeviceOut = @Serial/@MMD_ID

--- Install jobs: DeviceIn = @Serial/@MMD_ID
--- DeInstall jobs: DeviceOut = @Serial/@MMD_ID
--- 10/10/2005: Amend the revoke location/condition
--- 20/10/2005: Stop raising exception if the kit device has been unpacked and removed from inventory
--- 21/10/2005: Add spelling check to device-in
--- 26/10/2005: Amended device revoke-to location/Condition (Ref. Task 530)
--- 21/12/2005: Change the revoked location to job FSP location (ref: Task 539)
--- 26/09/2007: 3101 - MANAGING UPGRADE STOCK - CONDITION 18 - WebCAMS changes (Ref. Task 1523)
--- 04/04/2008: Task 1833: #3338: CHANGE TO SERIAL HANDLING RULES
--- 16/04/2008: Task 1851: #3461: NEED TO CONFIRM CLIENT ID ON A PDA UPLOAD

DECLARE @Note varchar(65),
	@ret int,
	@Location int,
	@LastLocation int,
	@LastCondition int,
	@IsException bit,
	
	@ClientID varchar(3),
	@TerminalID varchar(20),

	@JobTypeID tinyint,

	@FSPOperatorNumber int,
	@IsDone bit,

	@Require3DES bit,
	@RequireEMV bit,

	@COMPLIANCE_3DES tinyint,
	@COMPLIANCE_EMV tinyint,
	
	@Is3DES bit,
	@IsEMV bit,
	@NewIs3DES bit,
	@NewIsEMV bit,

	@SoftwareVersion varchar(20),
	@HardwareRevision varchar(20),
	@NewSoftwareVersion varchar(20),
	@NewHardwareRevision varchar(20),

	@TerminalSerial varchar(32),
	@TerminalMMD_ID varchar(5),
	@PrinterSerial varchar(32),
	@PrinterMMD_ID varchar(5),
	@PinpadSerial varchar(32),
	@PinpadMMD_ID varchar(5),

	@JobFSP int,
	@DeviceCount int,
	@JobExist bit,

	@PrevNewSerial varchar(32),
	@PrevNewMMD_ID varchar(5)


 --init
 SELECT @IsException = 0,
	@IsDone = 0,
	@Require3DES = 0,
	@RequireEMV = 0,
	@COMPLIANCE_3DES = 1,
	@COMPLIANCE_EMV = 2,

	@Is3DES = 0,
	@IsEMV = 0,
	@NewIs3DES = 0,
	@NewIsEMV = 0


 --Get Location for the user
 SELECT @Location = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@Location


 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamily(@Location)

 --Create cache tables
 SELECT Serial,
	MMD_ID,
	Location,
	Is3DES,
	IsEMV,
	SoftwareVersion,
	HardwareRevision
  INTO #MyDeviceIn
  FROM Equipment_Inventory 
 WHERE 1 = 2


 SELECT Serial,
	MMD_ID,
	Is3DES,
	IsEMV,
	SoftwareVersion,
	HardwareRevision
  INTO #MyDeviceOut
  FROM Equipment_Inventory
 WHERE 1 = 2



 --***Get job details
 IF LEN(@JobID) = 11 
  --Swap Calls
  BEGIN
	--get call details
	SELECT @ClientID = ClientID,
		@TerminalID = TerminalID,
		@JobTypeID = 4, --'SWAP',
		@JobFSP = AssignedTo
	  FROM Calls
	 WHERE CallNumber = @JobID
	
	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

  END
 ELSE
  --IMS Jobs
  BEGIN
	--get job details
	SELECT @ClientID = ClientID,
		@JobTypeID = JobTypeID,
		@TerminalID = CASE WHEN JobTypeID = 3 THEN OldTerminalID
				ELSE TerminalID END,
		@JobFSP = BookedInstaller
	 FROM  IMS_Jobs
	 WHERE JobID = @JobID

	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

  END

 --***validation

 --verify if the job is belong to this user
 IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
  BEGIN

	 --get device compliance requirements
	 SELECT @Require3DES = dbo.fnJobDeviceRequireCompliantDevice(@JobID, @MMD_ID, @COMPLIANCE_3DES),
		@RequireEMV = dbo.fnJobDeviceRequireCompliantDevice(@JobID, @MMD_ID, @COMPLIANCE_EMV)


	--Swap/Upgrad jobs: The device to be added is an installation (Serial/MMD_ID is device out, NewSerial/NewMMD_ID is device in)
	IF @Action = 1 
	 BEGIN
		IF @JobTypeID = 1 --'INSTALL'
		--The device to be added is an installation of new device (Serial/MMD_ID is the device in)
		 BEGIN
			--In order to generalise the process, we have to set newSerial/NewMMD_ID as device in
			SELECT @NewSerial = @Serial,
				@NewMMD_ID = @MMD_ID
		 END		

		--cache device in
		INSERT INTO #MyDeviceIn
		SELECT Serial,
			MMD_ID,
			Location,
			Is3DES,
			IsEMV,
			SoftwareVersion,
			HardwareRevision
		  FROM Equipment_Inventory 
	 	 WHERE Serial = @NewSerial 
				AND (@ClientID IN (SELECT * FROM dbo.fnGetSiteClientIDFromDeviceClientID(ClientID))   --FDI
						OR @ClientID = ClientID)   --FDI: mixed with some devices with CUS and some with FDI


		SELECT @DeviceCount = @@ROWCOUNT

		--no record found, try alternative serial number
		IF @DeviceCount = 0
		 BEGIN
			INSERT INTO #MyDeviceIn
			SELECT ei.Serial,
				ei.MMD_ID,
				ei.Location,
				ei.Is3DES,
				ei.IsEMV,
				ei.SoftwareVersion,
				ei.HardwareRevision
			  FROM Equipment_Inventory ei JOIN dbo.fnGetAlternativeSerialNumber(NULL, @NewSerial) a 
							ON ei.Serial = a.Serial AND ei.MMD_ID = a.MMD_ID
			 WHERE (@ClientID IN (SELECT * FROM dbo.fnGetSiteClientIDFromDeviceClientID(ei.ClientID))   --FDI
						OR @ClientID = ei.ClientID)   --FDI: mixed with some devices with CUS and some with FDI

			SELECT @DeviceCount = @@ROWCOUNT
			
		 END

			
		--unique matching
		IF @DeviceCount = 1
		 BEGIN
			--refresh MMD_ID and Serial
			SELECT @NewMMD_ID = MMD_ID,
				@NewSerial = Serial
			  FROM #MyDeviceIn 
		 END

		--multiple devices found
		IF @DeviceCount > 1
		 BEGIN
			DELETE #myDeviceIn
			 WHERE MMD_ID <> @NewMMD_ID
			
			--get new count
			SELECT @DeviceCount = COUNT(*) FROM #myDeviceIn
		 END

		IF @DeviceCount = 1
		 BEGIN
			IF NOT EXISTS(SELECT 1 FROM #MyDeviceIn my JOIN #myLocFamily l ON my.Location = l.Location
					WHERE ISNULL(Is3DES, 0) = CASE WHEN @Require3DES = 1 THEN 1 ELSE ISNULL(Is3DES, 0) END
					AND ISNULL(IsEMV, 0) = CASE WHEN @RequireEMV = 1 THEN 1 ELSE ISNULL(IsEMV, 0) END)
			 --Not compliant, raise exception
			 BEGIN
			 	SELECT @IsException = 1
			 END

		 END
		ELSE
		 --device not in system or more than one serial number in system, raise exception
		 BEGIN
		 	SELECT @IsException = 1
		 END

	
		IF LEN(@JobID) = 11 
		--If it a Swap Call, then we need to make sure the device-out's MMD_ID is right
		 BEGIN
			--Get right MMD_ID for the device out. No bell to ring, only populate device-out's mmd_id
			INSERT INTO #myDeviceOut
		        SELECT Serial,
				MMD_ID,
				Is3DES,
				IsEMV,
				SoftwareVersion,
				HardwareRevision
			   FROM Site_Equipment
			WHERE Serial = @Serial 
				AND ClientID = @ClientID
				AND TerminalID = @TerminalID
	
			SELECT @DeviceCount = @@ROWCOUNT
			
			--No device found, try alternative serial
			IF @DeviceCount = 0
			 BEGIN
				INSERT INTO #myDeviceOut
			        SELECT se.Serial,
					se.MMD_ID,
					se.Is3DES,
					se.IsEMV,
					se.SoftwareVersion,
					se.HardwareRevision
				   FROM Site_Equipment se JOIN dbo.fnGetAlternativeSerialNumber(NULL, @Serial) a 
									on se.MMD_ID = a.MMD_ID and se.Serial = a.Serial
				WHERE se.ClientID = @ClientID
					AND se.TerminalID = @TerminalID
		
				SELECT @DeviceCount = @@ROWCOUNT
				
			 END

			--try on ClientID/Serial, since device could exist on the other site
			IF @DeviceCount = 0
			 BEGIN
				INSERT INTO #myDeviceOut
			        SELECT Serial,
					MMD_ID,
					Is3DES,
					IsEMV,
					SoftwareVersion,
					HardwareRevision
				   FROM Site_Equipment
				WHERE Serial = @Serial 
					AND ClientID = @ClientID
	
				SELECT @DeviceCount = @@ROWCOUNT
			 END

			--unique matching found
			IF @DeviceCount = 1
			 --only one device found, get the mmd_id and Serial
			 BEGIN
				SELECT @MMD_ID = MMD_ID,
					@Serial = Serial
				 FROM #myDeviceOut
			 END
		  END

	 END --IF @Action = 1 '' install a new device

	--The recrod to be added is removal of an existing device (Serial/MMD_ID is device out, NewSerial/NewMMD_ID is empty)
	IF @Action = 2
	 BEGIN
		--verify if the device is on site
		INSERT INTO #myDeviceOut
	        SELECT Serial,
			MMD_ID,
			Is3DES,
			IsEMV,
			SoftwareVersion,
			HardwareRevision
		   FROM Site_Equipment
		WHERE Serial = @Serial 
			AND ClientID = @ClientID
			AND TerminalID = @TerminalID

		SELECT @DeviceCount = @@ROWCOUNT

		--no device found, try alternative serial number
		IF @DeviceCount = 0
		 BEGIN
			INSERT INTO #myDeviceOut
		        SELECT se.Serial,
				se.MMD_ID,
				se.Is3DES,
				se.IsEMV,
				se.SoftwareVersion,
				se.HardwareRevision
			   FROM Site_Equipment se JOIN dbo.fnGetAlternativeSerialNumber(NULL, @Serial) a 
								on se.MMD_ID = a.MMD_ID and se.Serial = a.Serial
			WHERE se.ClientID = @ClientID
				AND se.TerminalID = @TerminalID
	
			SELECT @DeviceCount = @@ROWCOUNT
			
		 END		

		IF @DeviceCount = 1
		 --only one device found, get the mmd_id & serial
		 BEGIN
			SELECT @MMD_ID = MMD_ID,
				@Serial = Serial
			 FROM #myDeviceOut
		 END
		ELSE
		 --flag the exception
		 BEGIN
			--try on ClientID/Serial, since device could exist on other site
			IF @DeviceCount = 0
			 BEGIN
				INSERT INTO #myDeviceOut
			        SELECT Serial,
					MMD_ID,
					Is3DES,
					IsEMV,
					SoftwareVersion,
					HardwareRevision
				   FROM Site_Equipment
				WHERE Serial = @Serial 
					AND ClientID = @ClientID
	
				SELECT @DeviceCount = @@ROWCOUNT
				
			 END

			IF @DeviceCount = 1
		  	 BEGIN
				SELECT @MMD_ID = MMD_ID
				  FROM #myDeviceOut
			 END

			--apply exception handling on device out
			EXEC @ret = dbo.spPDAApplyExceptionRuleOnDeviceOut 
					@JobID = @JobID,
					@MMD_ID = @MMD_ID OUTPUT,
					@Serial = @Serial OUTPUT,
					@FSPOperatorNumber = @FSPOperatorNumber,
					@IsDone = @IsDone OUTPUT

			IF @ret <> 0 
				GOTO RollBack_Handle

			SELECT @IsException = CASE @IsDone WHEN 1 THEN 0 ELSE 1 END

		 END
	 END --IF @Action = 2 ''remove the existing device

   END --job exists


 --get compliance/version info
 SELECT @Is3DES = Is3DES,
	@IsEMV = IsEMV,
	@SoftwareVersion = SoftwareVersion,
	@HardwareRevision = HardwareRevision
  FROM #myDeviceOut

 SELECT @NewIs3DES = Is3DES,
	@NewIsEMV = IsEMV,
	@NewSoftwareVersion = SoftwareVersion,
	@NewHardwareRevision = HardwareRevision
  FROM #myDeviceIn


 --***Actions  

 --Start Transaction
 DECLARE @bInCallerTransaction bit
 SET @bInCallerTransaction = @@TRANCOUNT
 IF @bInCallerTransaction = 0
	BEGIN TRAN

 IF LEN(@JobID) = 11 
  --Swap Calls
  BEGIN
	--verify if the job is belong to this user
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN
		--The device to be added is an installation (Serial/MMD_ID is device out, NewSerial/NewMMD_ID is device in)
		IF @Action = 1 
		 BEGIN
			IF @IsException = 0	
			 --no exception, 
			 BEGIN
				--populate call device
				--Check if device out exists in Call Equipment
				SELECT @PrevNewSerial = NewSerial,
					@PrevNewMMD_ID = NewMMD_ID
				  FROM Call_Equipment
				 WHERE CallNumber = @JobID 
					AND Serial = @Serial 
					AND MMD_ID = @MMD_ID
			
			
				IF @@ROWCOUNT = 1
				  --device exists, Update with the new serial/mmd_id
				  BEGIN
					UPDATE Call_Equipment
					   SET NewSerial = @NewSerial,
						NewMMD_ID = @NewMMD_ID,
						Swapped = 1,
						NewSoftwareVersion = @NewSoftwareVersion,
						NewHardwareRevision = @NewHardwareRevision,
						NewIs3DES = @NewIs3DES,
						NewIsEMV = @NewIsEMV
					  WHERE CallNumber = @JobID
						AND Serial = @Serial
						AND MMD_ID = @MMD_ID
	
					SELECT @ret = @@ERROR				
					IF @ret <> 0 
						GOTO RollBack_Handle

					--select lastlocation/lastcondition
					SELECT @LastLocation = @JobFSP,
						@LastCondition = CASE WHEN LastCondition IN  (18, 19, 20) THEN LastCondition
									ELSE dbo.fnGetRevokedDeviceDefaultCondition(MMD_ID) END
					 FROM Equipment_Inventory 
					WHERE Serial = @PrevNewSerial
						AND MMD_ID = @PrevNewMMD_ID

					--only free up the current device when it is in inventory	
					IF @@ROWCOUNT = 1
					 BEGIN
			
						SELECT @Note = 'NO LONGER RESERVED FOR ' + CAST(@JobID as varchar)
			
						--free up the device only when it exists
						EXEC @ret = dbo.spChangeInventoryConditionLocation 
								@Serial = @PrevNewSerial,
								@MMD_ID = @PrevNewMMD_ID,
								@NewCondition = @LastCondition,
								@NewLocation = @LastLocation,
								@Note = @Note,
								@AddedBy = @FSPOperatorNumber
			
						 IF @ret <> 0 
							GOTO RollBack_Handle
			
					 END	

	
				  END
				ELSE
				  --device does not exist, add it in
				  BEGIN
					--add the call equipment record
					INSERT Call_Equipment (CallNumber,
								Serial,
								MMD_ID,
								SoftwareVersion,
								HardwareRevision,
								Is3DES,
								IsEMV,
								Faulty,
								NewSerial,
								NewMMD_ID,
								NewSoftwareVersion,
								NewHardwareRevision,
								NewIs3DES,
								NewIsEMV,
								Swapped)
						VALUES	(@JobID,
							@Serial,
							@MMD_ID,
							@SoftwareVersion,
							@HardwareRevision,
							@Is3DES,
							@IsEMV,
							1,
							@NewSerial,
							@NewMMD_ID,
							@NewSoftwareVersion,
							@NewHardwareRevision,
							@NewIs3DES,
							@NewIsEMV,
							1)
	
					SELECT @ret = @@ERROR
					IF @ret <> 0 
						GOTO RollBack_Handle
									
				  END

				--reserve the device in
				--change loc/cond to reserve the device
				SELECT @Note = 'RESERVED FOR ' + CAST(@JobID as varchar)
				EXEC @ret = dbo.spChangeInventoryConditionLocation 
						@Serial = @NewSerial,
						@MMD_ID = @NewMMD_ID,
						@NewCondition = 9,
						@NewLocation = @Location,
						@Note = @Note,
						@AddedBy = @FSPOperatorNumber
		
				 IF @ret <> 0 
					GOTO RollBack_Handle


			 END
			ELSE
			 --there is an exception
			 BEGIN
				--log the exception - device to be installed is not in inventory
				INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
					Values (@JobID, 1, null, null, @NewSerial, @NewMMD_ID, GetDate())

				SELECT @ret = @@ERROR
				IF @ret <> 0 
					GOTO RollBack_Handle
				
			 END
	
		 END --IF @Action = 1 '' install a new device

		--The recrod to be added is removal existing device (Serial/MMD_ID is device out, NewSerial/NewMMD_ID is empty)
		IF @Action = 2
		 BEGIN
			IF @IsException = 0
			 BEGIN			
				--populate device
				IF NOT EXISTS(SELECT 1 FROM Call_Equipment
								WHERE CallNumber = @JobID 
									AND Serial = @Serial
									AND MMD_ID = @MMD_ID)
				 --not exists in call equipment, add it in
				 BEGIN
					INSERT Call_Equipment(CallNumber,
								Serial,
								MMD_ID,
								SoftwareVersion,
								HardwareRevision,
								Is3DES,
								IsEMV,
								Faulty,
								NewSerial,
								NewMMD_ID)
						VALUES (@JobID,
							@Serial,
							@MMD_ID,
							@SoftwareVersion,
							@HardwareRevision,
							@Is3DES,
							@IsEMV,
							1,
							'CONFIRM01',
							@MMD_ID)
	
					SELECT @ret = @@ERROR
					IF @ret <> 0
						GOTO RollBack_Handle
	
								
				 END
			 END --no exception
			ELSE
			--handle exceptions
			 BEGIN
				--log the exception - device to be removed is not on site
				INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
					Values (@JobID, 2, null, null, @Serial, @MMD_ID, GetDate())

				SELECT @ret = @@ERROR
				IF @ret <> 0 
					GOTO RollBack_Handle
			 END


		 END --IF @Action = 2 ''remove the existing device
	 END --job exists and belongs to this user
	ELSE
	 BEGIN
		IF @JobExist = 1
	 	 BEGIN
			--job does exist but NOT belong to this user, log the exception
			--Device-in for swap
			IF @Action = 1
			 BEGIN
				--PDASerial is device-in
				INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
					Values (@JobID, 9, 'PDASerial IN', null, @NewSerial, @NewMMD_ID, GetDate())
	
				SELECT @ret = @@ERROR
				IF @ret <> 0 
					GOTO RollBack_Handle
	
	
			 END
	
			--device-out for swap		
			IF @Action = 2
			 BEGIN
				--PDASerial is device-out
				INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
					Values (@JobID, 9, 'PDASerial OUT', null, @Serial, @MMD_ID, GetDate())
	
	
				SELECT @ret = @@ERROR
				IF @ret <> 0 
					GOTO RollBack_Handle
			 END

		 END --IF @JobExist = 1
		----otherwise, the job has been closed by EE helpdesk, no exception to log
	 END 

  END -- swap job
 ELSE
  --IMS Jobs
  BEGIN
	--verify if the job exists
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN

		IF @Action = 1
		 BEGIN
			IF @IsException = 0	
			 --no exception, 
			 BEGIN
				IF @JobTypeID = 3 --'UPGRADE'
				 BEGIN
					--In Upgrade jobs, Device In/Out are not in pair. 
					--So verify if the device out has been serialised before adding it to ims job equipment
					IF LEN(@Serial) > 0 AND LEN(@MMD_ID) > 0
					 BEGIN
						--Check if device OUT exists in IMS Job Equipment
						IF NOT EXISTS(SELECT 1 FROM IMS_Job_Equipment
										WHERE JobID = @JobID 
											AND Serial = @Serial 
											AND MMD_ID = @MMD_ID
											AND ActionID = 2)  --'REMOVE'
						  --device does not exist, add it in
						  BEGIN
							--add it in
							INSERT IMS_Job_Equipment (JobID,
										Serial,
										MMD_ID,
										ActionID,
										IsValid,
										Is3DES,
										IsEMV)
								VALUES	(@JobID,
									@Serial,
									@MMD_ID,
									2, --'REMOVE',
									1,
									@Is3DES,
									@IsEMV)
				
							SELECT @ret = @@ERROR
							IF @ret <> 0
								GOTO RollBack_Handle
				
											
						  END
					 END

				 END --IF @JobType = 'UPGRADE'
	
	
				--get prev device
				SELECT @PrevNewSerial = Serial,
					@PrevNewMMD_ID = MMD_ID
				 FROM IMS_Job_Equipment
				WHERE JobID = @JobID
					AND MMD_ID = @NewMMD_ID
					AND ActionID = 1 -- IN ('INSTALL', 'CONFIRM')
		
				--Add device IN if not exists
				IF @@ROWCOUNT = 1
				 BEGIN
					--delete not serialised device with the same MMD_ID
					DELETE IMS_Job_Equipment
					 WHERE JobID = @JobID
						AND MMD_ID = @PrevNewMMD_ID
						AND Serial = @PrevNewSerial
						AND ActionID = 1 -- IN ('INSTALL', 'CONFIRM')
						
			

					--release the device
					SELECT @LastLocation = @JobFSP,
						@LastCondition = CASE WHEN LastCondition IN  (18, 19, 20) THEN LastCondition
									ELSE dbo.fnGetRevokedDeviceDefaultCondition(MMD_ID) END
					 FROM Equipment_Inventory 
					WHERE Serial = @PrevNewSerial
						AND MMD_ID = @PrevNewMMD_ID
			

					--free up the previous reserved equipment
					IF @@ROWCOUNT = 1
					 BEGIN
						--Is it part of Kit? If so, no need to release the device, just leave as it is
						--otherwise, release it
						IF EXISTS(SELECT 1 FROM Equipment_Kits WHERE (PinpadSerial = @PrevNewSerial AND PinpadMMD_ID = @PrevNewMMD_ID) 
												OR (PrinterSerial = @PrevNewSerial AND PrinterMMD_ID = @PrevNewMMD_ID) 
												OR (TerminalSerial = @PrevNewSerial AND TerminalMMD_ID = @PrevNewMMD_ID) )
						 BEGIN
							--in a kit, unpack it from PDA
							EXEC @ret = dbo.spPDAProcessKit 
								@UserID = @UserID,
								@Serial = @PrevNewSerial,
								@MMD_ID = @PrevNewMMD_ID,
								@IsFaultyOutOfBox = 0
			
							IF @ret <> 0
								GOTO RollBack_Handle
			
						 END
			
			
						SELECT @Note = 'NO LONGER RESERVED FOR ' + CAST(@JobID as varchar)
			
						--free up the device only when it exists
						EXEC @ret = dbo.spChangeInventoryConditionLocation 
								@Serial = @PrevNewSerial,
								@MMD_ID = @PrevNewMMD_ID,
								@NewCondition = @LastCondition,
								@NewLocation = @LastLocation,
								@Note = @Note,
								@AddedBy = @FSPOperatorNumber
			
						IF @ret <> 0 
							GOTO RollBack_Handle
			
			
					 END	--IF @@ROWCOUNT = 1, device is in inventory
				 END --IF @@ROWCOUNT = 1

				--Add device IN if not exists
				IF NOT EXISTS(SELECT 1 FROM IMS_Job_Equipment
								WHERE JobID = @JobID
									AND Serial = @NewSerial
									AND MMD_ID = @NewMMD_ID
									AND ActionID = 1) -- IN ('INSTALL', 'CONFIRM')
				 BEGIN
					--add it in
					INSERT IMS_Job_Equipment (JobID,
								Serial,
								MMD_ID,
								ActionID,
								IsValid,
								Is3DES,
								IsEMV)
						VALUES	(@JobID,
							@NewSerial,
							@NewMMD_ID,
							1, --'INSTALL',
							1,
							@NewIs3DES,
							@NewIsEMV)
		
					SELECT @ret = @@ERROR
					IF @ret <> 0
						GOTO RollBack_Handle
		
				 END

				--if it is a kit, we unpack it
				IF EXISTS(SELECT 1 FROM tblKit WHERE Kit_MMD_ID = @NewMMD_ID)
				 BEGIN
					--get kit details
					SELECT 	@TerminalSerial = TerminalSerial,
						@TerminalMMD_ID = TerminalMMD_ID,
						@PrinterSerial = PrinterSerial,
						@PrinterMMD_ID = PrinterMMD_ID,
						@PinpadSerial = PinpadSerial,
						@PinpadMMD_ID = PinpadMMD_ID
				 		FROM Equipment_Kits 
					 WHERE KitSerial = @NewSerial
						AND KitMMD_ID = @NewMMD_ID
		
					--yes, it exists
					IF @@ROWCOUNT = 1 
					 BEGIN
						--do unpack the kit
						EXEC @ret = dbo.spUnPackKit 
							@UnPackCondition = 20,
							@KitSerial = @NewSerial,
							@KitMMD_ID = @NewMMD_ID,
							@TerminalSerial = @TerminalSerial,
							@TerminalMMD_ID = @TerminalMMD_ID,
							@PrinterSerial = @PrinterSerial,
							@PrinterMMD_ID = @PrinterMMD_ID,
							@PinpadSerial = @PinpadSerial,
							@PinpadMMD_ID = @PinpadMMD_ID,
							@Operator = @FSPOperatorNumber
		
						IF @ret <> 0 
						GOTO RollBack_Handle
		
					 END
				 END
		

				--reserve the device in
				--Is it part of Kit? If so, no need to reserve the device, just leave as it is
				--otherwise, reserve it
				IF EXISTS(SELECT 1 FROM Equipment_Kits WHERE (PinpadSerial = @NewSerial AND PinpadMMD_ID = @NewMMD_ID) 
										OR (PrinterSerial = @NewSerial AND PrinterMMD_ID = @NewMMD_ID) 
										OR (TerminalSerial = @NewSerial AND TerminalMMD_ID = @NewMMD_ID) )
				 BEGIN
					--in a kit, unpack it from PDA
					EXEC @ret = dbo.spPDAProcessKit 
						@UserID = @UserID,
						@Serial = @NewSerial,
						@MMD_ID = @NewMMD_ID,
						@IsFaultyOutOfBox = 0

					IF @ret <> 0
						GOTO RollBack_Handle

				 END
				ELSE
				 BEGIN
					--not in a kit, reserve it
					SELECT @Note = 'RESERVED FOR INSTALL AT ' + @TerminalID + ' (JOB ' + CAST(@JobID as varchar) + ')'
	
					 --Update the device condition 9				
					EXEC @ret = dbo.spChangeInventoryConditionLocation 
							@Serial = @NewSerial,
							@MMD_ID = @NewMMD_ID,
							@NewCondition = 9,
							@NewLocation = @Location,
							@Note = @Note,
							@AddedBy = @FSPOperatorNumber
		
					 IF @ret <> 0 
						GOTO RollBack_Handle
					
				 END		

			 END
			ELSE
			 --there is an exception
			 BEGIN
				--verify if the device is a kit
				IF EXISTS(SELECT 1 FROM tblKit WHERE Kit_MMD_ID = @NewMMD_ID)
				 BEGIN
					IF EXISTS(SELECT 1 FROM Equipment_Kits_History 
							  WHERE KitSerial = @NewSerial 
								AND KitMMD_ID = @NewMMD_ID)
					 BEGIN
						--The kit has been unpacked. This is why can not find the macthing device in inventory.
						--should not raise exception
						SELECT @IsException = 0
						
					 END				

				 END
				
				IF @IsException = 1
				 BEGIN
					--log the exception - device to be installed is not in inventory
					INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
						Values (@JobID, 1, null, null, @NewSerial, @NewMMD_ID, GetDate())
	
					SELECT @ret = @@ERROR
					IF @ret <> 0 
						GOTO RollBack_Handle
				 END				
			 END
			

	
		 END --IF @Action = 1  '' install a new device


		--The device to be added is a removal of existing device (Serial/MMD_ID is device out)
		IF @Action = 2
		 BEGIN
			--process excpetion			
			IF @IsException = 0
			 BEGIN
				--Add device if not exists
				IF NOT EXISTS(SELECT 1 FROM IMS_Job_Equipment
							WHERE JobID = @JobID
								AND Serial = @Serial
								AND MMD_ID = @MMD_ID
								AND ActionID = 2) --IN ('REMOVE')
				 BEGIN
					--add it in
					INSERT IMS_Job_Equipment (JobID,
								Serial,
								MMD_ID,
								ActionID,
								IsValid,
								Is3DES,
								IsEMV)
						VALUES	(@JobID,
							@Serial,
							@MMD_ID,
							2, --'REMOVE',
							1,
							@Is3DES,
							@IsEMV)
		
					SELECT @ret = @@ERROR
					IF @ret <> 0
						GOTO RollBack_Handle
		
				 END
			 END --no exception	
			ELSE
			 BEGIN
				--log the exception - device to be removed is not on site
				INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
					Values (@JobID, 2, null, null, @Serial, @MMD_ID, GetDate())

				SELECT @ret = @@ERROR
				IF @ret <> 0 
					GOTO RollBack_Handle
			 END

		 END --@Action = 2  ''remove existing device

	 END -- job exists
	ELSE
	 BEGIN
		IF @JobExist = 1
		 BEGIN
			--job does exist but does not belong to this user, log this exception
			--install device
			IF @Action = 1
			 BEGIN
				--PDASerial is device-in
				IF @NewSerial IS NULL OR LTRIM(@NewSerial) = ''
				 BEGIN
					--no serial in @NewSerial means it is device-in for install job
					INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
						Values (@JobID, 9, 'PDASerial IN', null, @Serial, @MMD_ID, GetDate())
	
	
					SELECT @ret = @@ERROR
					IF @ret <> 0 
						GOTO RollBack_Handle
				 END
				ELSE
				 BEGIN
					--@NewSerial not null means it is device-in for upgrade job
					INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
						Values (@JobID, 9, 'PDASerial IN', null, @NewSerial, @NewMMD_ID, GetDate())
	
	
					SELECT @ret = @@ERROR
					IF @ret <> 0 
						GOTO RollBack_Handle
	
				 END
				
			 END
	
			--remove device
			IF @Action = 2
			 BEGIN
				--PDASerial is device-out
				INSERT tblPDAException (JobID, TypeID, Serial, MMD_ID, PDASerial, PDAMMD_ID, UpdateDateTime)
					Values (@JobID, 9, 'PDASerial OUT', null, @Serial, @MMD_ID, GetDate())
	
	
				SELECT @ret = @@ERROR
				IF @ret <> 0 
					GOTO RollBack_Handle
				
			 END		
		 END 
		--otherwise, the job has been closed by EE helpdesk, no exception to log

	 END -- job does not exist

  END --ims job

 --Commit
 IF @bInCallerTransaction = 0
	COMMIT TRAN


Exit_Handle:

 RETURN @ret

RollBack_Handle:
 IF @bInCallerTransaction = 0
	ROLLBACK TRAN

 GOTO Exit_Handle

GO
