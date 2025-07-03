Use CAMS
Go

Alter Procedure dbo.spWebAddFSPJobEquipment 
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
--<!--$$Revision: 51 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 5/04/13 14:02 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFSPJobEquipment.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add new device to IMS jobs/calls
--- Swap jobs: DeviceIn = @NewSerial/@NewMMD_ID 
---		DeviceOut = @Serial/@MMD_ID
--- Install jobs: DeviceIn = @Serial/@MMD_ID
--- DeInstall jobs: DeviceOut = @Serial/@MMD_ID
--- 26/10/2005: Amended device revoke-to location/Condition (Ref. Task 530)
--- 21/12/2005: Changed revoked location to job FSP location (ref. Task 539)
--- 07/04/2008: Task 1833: #3338: CHANGE TO SERIAL HANDLING RULES
--- 16/04/2008: Task 1851: #3461: NEED TO CONFIRM CLIENT ID ON A PDA UPLOAD

DECLARE @Note varchar(65),
	@ret int,
	@Location int,
	@LastLocation int,
	@LastCondition int,

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
	
	@JobFSP int,
	@DeviceCount int,
	@DeviceType varchar(15),
	@JobExist bit,

	@MySerial varchar(32),
	@JobIDString varchar(11),

	@TerminalSerial varchar(32),
	@TerminalMMD_ID varchar(5),
	@PrinterSerial varchar(32),
	@PrinterMMD_ID varchar(5),
	@PinpadSerial varchar(32),
	@PinpadMMD_ID varchar(5),

	@PrevNewSerial varchar(32),
	@PrevNewMMD_ID varchar(5)


 --init
 SELECT @ret = 0,
	@IsDone = 0,
	@Require3DES = 0,
	@RequireEMV = 0,
	@COMPLIANCE_3DES = 1,
	@COMPLIANCE_EMV = 2,

	@Is3DES = 0,
	@IsEMV = 0,
	@NewIs3DES = 0,
	@NewIsEMV = 0,
	@JobIDString = CAST(@JobID as varchar(11))

--temp pading serial due to removal of pading from webcams
select @Serial = case when @Serial like '' or @Serial like 'CONFIRM%' or @Serial like 'TBA' or @Serial like 'SERIAL_NUMBER%' then @Serial else dbo.fnLeftPadSerial(@Serial) end,
		@NewSerial = dbo.fnLeftPadSerial(@NewSerial)

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
 IF dbo.fnIsSwapCall(@JobID) = 1
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
		@JobFSP = BookedInstaller,
		@DeviceType = DeviceType
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
		IF @JobTypeID IN (1, 3) --('INSTALL', 'UPGRADE')
		--The device to be added is an installation of new device (Serial/MMD_ID is the device in)
		 BEGIN
			--In order to generalise the process, we have to set newSerial/NewMMD_ID as device in
			SELECT @NewSerial = @Serial,
				@NewMMD_ID = @MMD_ID
		 END		


		--caceh device in
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


		--unique matching
		IF @DeviceCount = 1
		 BEGIN
			--refresh MMD_ID
			SELECT @NewMMD_ID = MMD_ID 
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
			--validate if the device is already in Job Equipment
			IF dbo.fnIsSwapCall(@JobID) = 1
			 BEGIN
				IF EXISTS(SELECT 1 FROM Call_Equipment WHERE CallNumber = @JobID
										AND NewSerial = @NewSerial)
				 BEGIN
					RAISERROR('DeivceIn [%s] is already in job [%s] equipment. Abort', 16, 1, @NewSerial, @JobIDString)
					SELECT @ret = -1
					GOTO Exit_Handle
				 END
			 END
			ELSE
			 BEGIN
				IF EXISTS(SELECT 1 FROM IMS_Job_Equipment WHERE JobID = @JobID 
										AND Serial = @NewSerial 
										AND ActionID = 1 ) --IN ('INSTALL', 'CONFIRM')
				 BEGIN
					RAISERROR('DeivceIn [%s] is already in job [%s] equipment. Abort', 16, 1, @NewSerial, @JobIDString)
					SELECT @ret = -1
					GOTO Exit_Handle
				 END
			 END
	
			--check if device is at FSP location (including any members of the family)
			SELECT @MySerial = Serial FROM #MyDeviceIn my JOIN #myLocFamily l ON my.Location = l.Location
			IF @@ROWCOUNT = 0
			 BEGIN
				RAISERROR('DeivceIn [%s] is not at FSP location . Abort', 16, 1, @NewSerial)
				SELECT @ret = -1
				GOTO Exit_Handle
			 END

			SELECT @MySerial = Serial FROM #MyDeviceIn my JOIN #myLocFamily l ON my.Location = l.Location
					WHERE ISNULL(Is3DES, 0) <> CASE WHEN @Require3DES = 1 THEN 1 ELSE ISNULL(Is3DES, 0) END
					OR ISNULL(IsEMV, 0) <> CASE WHEN @RequireEMV = 1 THEN 1 ELSE ISNULL(IsEMV, 0) END

			IF @@ROWCOUNT > 0
			 --Not compliant , raise exception
			 BEGIN
				RAISERROR('DeivceIn [%s] is not 3DES/EMV compliant. Abort', 16, 1, @NewSerial)
				SELECT @ret = -1
				GOTO Exit_Handle
			 END

		 END
		ELSE
		 --device not in system or more than one serial number is system, raise exception
		 BEGIN
			IF @DeviceCount = 0
			 --Device does not exist , raise exception
			 BEGIN
				RAISERROR('DeviceIn [%s] does not exist.', 16, 1, @NewSerial)
				SELECT @ret = -1
				GOTO Exit_Handle
			 END
			ELSE
			 --More than one device exist with the same serial number, prompt user to select
			 BEGIN
				RAISERROR('More than one device with serial number [%s] exist.', 16, 1, @NewSerial)
				SELECT @ret = -1
				GOTO Exit_Handle
			 END
		 END


	
		IF dbo.fnIsSwapCall(@JobID) = 1
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

			--unique matching found
			IF @DeviceCount = 1
			 --only one device found, get the mmd_id & serial
			 BEGIN
				SELECT @MMD_ID = MMD_ID,
					@Serial = Serial
				 FROM #myDeviceOut
			 END
			ELSE
			 BEGIN
				--no exact matching on ClientID/TerminalID/Serial, now try ClientID/Serial
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

				--found one, get MMD_ID
				IF @DeviceCount <= 1
				 BEGIN
					SELECT @MMD_ID = MMD_ID
					  FROM #myDeviceOut

					--apply exception handling on device out
					EXEC @ret = dbo.spPDAApplyExceptionRuleOnDeviceOut 
							@JobID = @JobID,
							@MMD_ID = @MMD_ID OUTPUT,
							@Serial = @Serial OUTPUT,
							@FSPOperatorNumber = @FSPOperatorNumber,
							@IsDone = @IsDone OUTPUT
		
					IF @ret <> 0 
						GOTO RollBack_Handle
		
					IF @IsDone = 1
					 begin
					    --Get correct MMD
						SELECT @MMD_ID = MMD_ID
						   FROM Site_Equipment
							WHERE Serial = @Serial 
								AND ClientID = @ClientID

						SELECT @DeviceCount = @@ROWCOUNT
					 
					 end
					else
					 --Device does not exist , raise exception
					 BEGIN
						RAISERROR('DeviceOut [%s] does not exist.', 16, 1, @Serial)
						SELECT @ret = -1
						GOTO Exit_Handle
					 END

				 END
				ELSE
				 BEGIN
					IF @DeviceCount = 0
					 --Device does not exist , raise exception
					 BEGIN
						RAISERROR('DeviceOut [%s] does not exist.', 16, 1, @Serial)
						SELECT @ret = -1
						GOTO Exit_Handle
					 END
					ELSE
					 --More than one device exist with the same serial number, prompt user to select
					 BEGIN
						RAISERROR('More than one device with serial number [%s] exist.', 16, 1, @Serial)
						SELECT @ret = -1
						GOTO Exit_Handle
					 END

				 END
			 END

		  END

	 END --IF @Action = 1 '' install a new device

	--The recrod to be added is removal existing device (Serial/MMD_ID is device out, NewSerial/NewMMD_ID is empty)
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
			--no exact matching on ClientID/TerminalID/Serial, now try ClientID/Serial
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
				--found one, get MMD_ID
				IF @DeviceCount = 1
				 BEGIN
					SELECT @MMD_ID = MMD_ID
					  FROM #myDeviceOut
				 END
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

			IF @IsDone = 0
			 --Device does not exist , raise exception
			 BEGIN
				RAISERROR('DeviceOut [%s] does not exist.', 16, 1, @Serial)
				SELECT @ret = -1
				GOTO Exit_Handle
			 END
		 END

		--validate if the device is already in Job Equipment
		IF dbo.fnIsSwapCall(@JobID) = 1
		 BEGIN
			IF EXISTS(SELECT 1 FROM Call_Equipment WHERE CallNumber = @JobID
									AND Serial = @Serial)
			 BEGIN
				RAISERROR('DeivceOut [%s] is already in job [%s] equipment. Abort', 16, 1, @Serial, @JobIDString)
				SELECT @ret = -1
				GOTO Exit_Handle
			 END
		 END
		ELSE
		 BEGIN
			IF EXISTS(SELECT 1 FROM IMS_Job_Equipment WHERE JobID = @JobID 
									AND Serial = @Serial 
									AND ActionID = 2)  -- IN ('REMOVE')
			 BEGIN
				RAISERROR('DeivceOut [%s] is already in job [%s] equipment. Abort', 16, 1, @Serial, @JobIDString)
				SELECT @ret = -1
				GOTO Exit_Handle
			 END
		 END


	 END --IF @Action = 2 ''remove the existing device

   END --job exists
 ELSE
  BEGIN
	IF @JobExist = 1
	 BEGIN
		RAISERROR('Job [%s] is not assigned to FSP [%d] group. Abort', 16, 1, @JobIDString, @Location)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END
	ELSE
	 BEGIN
		RAISERROR('Job [%s] does not exist. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END

  END -- job does not exist


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

 IF dbo.fnIsSwapCall(@JobID) = 1
  --Swap Calls
  BEGIN
	--The device to be added is an installation (Serial/MMD_ID is device out, NewSerial/NewMMD_ID is device in)
	IF @Action = 1 
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

			--set LastLocation/LastCondition
			SELECT @LastLocation = @JobFSP,
				@LastCondition = CASE WHEN LastCondition IN  (18, 19, 20) THEN LastCondition
							ELSE dbo.fnGetRevokedDeviceDefaultCondition(MMD_ID) END
			 FROM Equipment_Inventory 
			WHERE Serial = @PrevNewSerial
				AND MMD_ID = @PrevNewMMD_ID


			--only free up the current device when it is in inventory	
			IF @@ROWCOUNT = 1
			 BEGIN
				--if no condition specified, select lastcondition
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

		--Append kitting parts to Call parts (keep current existing ones)
		select top 1 LogID 
			into #myKitPart
			from vwPIMCurrentDeviceKit 
				where ItemType='E' and MMD_ID = @NewMMD_ID and Serial = @NewSerial
		 
		if @@ROWCOUNT > 0
		 begin
			insert Call_Parts
				select @JobID, p.PartNo, ld.Quantity
					from tblPartPackingLogDetail ld join tblPart p on ld.PartID = p.PartID
								left outer join Call_Parts cp on cp.CallNumber = @JobID and cp.PartID = p.PartNo 
					where ld.LogID in (select LogID from #myKitPart) 
						and ld.ItemType = 'P'
						and cp.CallNumber is null
		 end


	 END --IF @Action = 1 '' install a new device

	--The recrod to be added is removal existing device (Serial/MMD_ID is device out, NewSerial/NewMMD_ID is empty)
	IF @Action = 2
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
						Faulty)
				VALUES (@JobID,
					@Serial,
					@MMD_ID,
					@SoftwareVersion,
					@HardwareRevision,
					@Is3DES,
					@IsEMV,
					1)

			SELECT @ret = @@ERROR
			IF @ret <> 0
				GOTO RollBack_Handle

						
		 END
	 END --IF @Action = 2 ''remove the existing device

  END -- swap job

 ELSE

  --IMS Jobs
  BEGIN
	IF @Action = 1
	 BEGIN
		--get prev device
		SELECT @PrevNewSerial = Serial,
			@PrevNewMMD_ID = MMD_ID
		 FROM IMS_Job_Equipment
		WHERE JobID = @JobID
			AND MMD_ID = @NewMMD_ID
			AND ActionID = 1 --IN ('INSTALL', 'CONFIRM')

		--Add device IN if not exists
		IF @@ROWCOUNT = 1
		 BEGIN
			--delete not serialised device with the same MMD_ID
			DELETE IMS_Job_Equipment
			 WHERE JobID = @JobID
				AND MMD_ID = @PrevNewMMD_ID
				AND Serial = @PrevNewSerial
				AND ActionID = 1 -- IN ('INSTALL', 'CONFIRM')
				
	

			--get the device lastlocation/lastcondition
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
	
	
			 END	--IF EXISTS(SELECT 1 FROM Equipment_Inventory WHERE Serial = @PrevNewSerial AND MMD_ID = @PrevNewMMD_ID)
		 END --IF @@ROWCOUNT = 1

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
				1,
				1,
				@NewIs3DES,
				@NewIsEMV)

		SELECT @ret = @@ERROR
		IF @ret <> 0
			GOTO RollBack_Handle


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
		


	 END --IF @Action = 1  '' install a new device


	--The device to be added is a removal of existing device (Serial/MMD_ID is device out)
	IF @Action = 2
	 BEGIN
		--Add device if not exists
		IF NOT EXISTS(SELECT 1 FROM IMS_Job_Equipment
					WHERE JobID = @JobID
						AND Serial = @Serial
						AND MMD_ID = @MMD_ID
						AND ActionID = 2 ) -- IN ('REMOVE')
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
					2,
					1,
					@Is3DES,
					@IsEMV)

			SELECT @ret = @@ERROR
			IF @ret <> 0
				GOTO RollBack_Handle

		 END


		--delete not serialised device with the same MMD_ID
		IF @JobTypeID = 2 AND @DeviceType = 'BRANCH PICKUP' AND @ClientID = 'CBA'
			BEGIN
				DELETE IMS_Job_Equipment
				 WHERE JobID = @JobID
					AND MMD_ID = @MMD_ID
					AND dbo.fnIsSerialisedDevice(@Serial) = 0
					AND ActionID = 2 -- IN ('REMOVE')
			END
		ELSE
			BEGIN
				DELETE IMS_Job_Equipment
				 WHERE JobID = @JobID
					AND MMD_ID = @MMD_ID
					AND Serial <> @Serial
					AND ActionID = 2 -- IN ('REMOVE')
			END

	 END --@Action = 2  ''remove existing device

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

--Grant EXEC on spWebAddFSPJobEquipment to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebAddFSPJobEquipment 
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
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 17/10/03 11:25 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFSPJobEquipment.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebAddFSPJobEquipment @UserID = @UserID, 
					@JobID = @JobID,
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewSerial = @NewSerial,
					@NewMMD_ID = @NewMMD_ID,
					@Action = @Action
 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret
/*
declare @ret  int
exec @ret = dbo.spWebAddFSPJobEquipment @UserID = 199663, 
					@JobID = 310352,
					@Serial = 'TBA',
					@MMD_ID = 'WINP2',
					@NewSerial = '2027924',
					@NewMMD_ID = '',
					@Action = 2

select @ret

select * from webcams.dbo.tblUSer

select * from calls
 where assignedto = 3011

select * from ims_jobs
 where bookedinstaller = 3011



*/
Go

--Grant EXEC on spWebAddFSPJobEquipment to eCAMS_Role
Go


