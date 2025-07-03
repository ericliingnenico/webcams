Use CAMS
Go

IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebAddFSPStockTakeLog' and type = 'p')
	drop procedure dbo.spWebAddFSPStockTakeLog
go

Create Procedure dbo.spWebAddFSPStockTakeLog 
	(
		@UserID int,
		@BatchID int,
		@Serial varchar(32)
	)
	AS
--<!--$$Revision: 36 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 9/06/15 9:30 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFSPStockTakeLog.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add FSP stocktake to tblFSPStockTakeLog
---Check device in CAMS as the following sequence:
---		1. Inventory
---		2. Odds & Ends
---		3. Site

DECLARE @ret int,
	@MMD_ID varchar(5),
	@CaseID tinyint,
	@Condition int,
	@Location int,
	@LastCondition int,
	@LastLocation int,
	@FSPLocation int,
	@Count int,
	@FSPOperatorNumber int,
	@StockTakeDate datetime,
	@Depot int,
	@SiteClientID varchar(3),
	@SiteName varchar(50),
	@TerminalID varchar(20),
	@NewCondition int,
	@NewInvNote varchar(65),
	@DeviceName varchar(150),
	@CurDateTime datetime,
	@dt datetime,
	@TerminalNumber varchar(2),
	@QUARANTINE_STOCK_TAKE smallint,
	@QuarantineMsg varchar(2000)



 --init
 SELECT @ret = 0,
	@NewInvNote = NULL,
 	@CurDateTime = dbo.fnGetDate(),
 	@QUARANTINE_STOCK_TAKE = 13



 --Get Location for the user
 SELECT @FSPLocation = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = case when @FSPLocation = 300 then 300 else -@FSPLocation end

 SELECT @Serial = UPPER(dbo.fnLeftPadSerial(@Serial))

 --get StockTake Batch details
 SELECT @Depot = Depot,
		@StockTakeDate = StockTakeDate
   FROM tblFSPStockTake
  WHERE BatchID = @BatchID

 --cache FSP Location family
 SELECT *
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamily(@FSPLocation)


 --cache Stock MMD List
  select MMD_ID 
    into #StockTakeMMD
    from tblStockTakeDevice
    where StockTakeDate = @StockTakeDate



 ---*********************
 --check inventory first
 ---*********************
 SELECT @MMD_ID = ei.MMD_ID,
	@Condition = ei.Condition,
	@Location = ei.Location,
	@LastCondition = ei.LastCondition,
	@LastLocation = ei.LastLocation,
	@DeviceName = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '')
   FROM Equipment_Inventory ei
   			JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
  WHERE ei.Serial = @Serial

 SELECT @Count = @@ROWCOUNT

 IF @Count > 1
  BEGIN
	--multiple devices found on this serial, now narrow the search to FSP group
	 SELECT @MMD_ID = ei.MMD_ID,
		@Condition = ei.Condition,
		@Location = ei.Location,
		@LastCondition = ei.LastCondition,
		@LastLocation = ei.LastLocation,
		@DeviceName = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '')
	   FROM Equipment_Inventory ei
   				JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
	  WHERE ei.Serial = @Serial
		AND Location IN (SELECT Location FROM #myLocFamily)
	
	
	SELECT @Count = @@ROWCOUNT

  END

 --unique record
 if @Count = 1
  begin
    --case-6: Device not on the stock-take list
	if not exists(select 1 from #StockTakeMMD where (MMD_ID = @MMD_ID OR MMD_ID = 'ALL'))
	 begin
		raiserror('<b>Serial %s - %s <br>not expected:<br><br>Device is NOT on the stock take list</b><br>', 16, 1, @Serial, @DeviceName)
		select @CaseID = 6;
		goto Exit_Handle;
	 end    

	--case 9, Device is already scanned not with CaseID of 7,8
	if exists(select 1 from tblFSPStockTakeLog where BatchID = @BatchID and Serial = @Serial and MMD_ID = @MMD_ID and CaseID not in (7,8))
	 begin
		raiserror('<b>Serial %s - %s <br>not expected:<br><br>Device is already scanned as stock-take</b><br>', 16, 1, @Serial, @DeviceName)
		select @CaseID = 9;
		goto Exit_Handle;
	 end    

    
    
	--update to Depot/100 and back to Depot/Condition    
    exec @ret=dbo.spChangeInventoryConditionLocationTwice @Serial = @Serial
		, @MMD_ID = @MMD_ID
		, @IntermediateCondition = 100
		, @IntermediateLocation = @Depot
		, @FinalCondition = @Condition
		, @FinalLocation = @Depot
		, @Note = @NewInvNote
		, @AddedBy = @FSPOperatorNumber
		, @FinalDate = @dt OUTPUT

	if exists(select 1 from #myLocFamily where Location = @Location)
	 begin
		select @CaseID = 1  --1: Found in Inventory with correction location	OK
	 end
	else
	 begin
		select @CaseID = 2  -- 2	Found in Inventory with wrong location	OK
	 end

	 select c.f as Condition
	 into #WarehouseExceptions
	 from dbo.fnConvertListToTable((select AttrValue from tblControl where Attribute = 'StocktakeWarehouseExceptionCondtions')) c

	 select c.f as Condition
	 into #FieldExceptions
	 from dbo.fnConvertListToTable((select AttrValue from tblControl where Attribute = 'StocktakeFieldExceptionCondtions')) c

	if @FSPLocation = 300 --KYC warehouse
	 begin
		if @CaseID = 1
		 begin
			if @Condition in (select Condition from #WarehouseExceptions)
			 begin
				EXEC dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = 31,
					@NewLocation = @Depot,
					@Note = null,
					@AddedBy = @FSPOperatorNumber
			 end
			--raiserror('<b>Serial %s - %s <br>expected:<br><br>*******CONDITION %d******<br></b><br>', 16, 1, @Serial, @DeviceName,@Condition)
		 end --		if @CaseID = 1


		--not in EE warehouse updated to 300/31	
		if @CaseID = 2  -- 2	Found in Inventory with wrong location	OK
		 begin
			if not exists(select 1 from Equipment_Inventory where Serial = @Serial and MMD_ID = @MMD_ID and Location = 300 and Condition = 31)
			 begin
				EXEC dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = 31,
					@NewLocation = @Depot,
					@Note = null,
					@AddedBy = @FSPOperatorNumber

			 end
		 end 
		 
		--check quarantine if need
		if exists(select 1 from tblFSPStockTakeQuarantine where StockTakeDate = @StockTakeDate and (FSP = @FSPLocation OR FSP = -1))
		 begin
			select @QuarantineMsg = q.Message
				from tblQuarantineDevice qd join tblQuarantine q on qd.QuarantineID = q.QuarantineID
				where Serial = @Serial 
						and MMD_ID = @MMD_ID
						and qd.QuarantineID in (select QuarantineID from tblFSPStockTakeQuarantine where StockTakeDate = @StockTakeDate and (FSP = @FSPLocation OR FSP = -1))
						
			if @@ROWCOUNT >0
			 begin
				raiserror('<b>Serial %s - %s <br>expected:<br><br>*******QUARANTINE APPLIED ******<br> %s</b><br>', 16, 1, @Serial, @DeviceName,@QuarantineMsg)
			 end	
		 end		 
		 
	 end  --if @FSPLocation = 300 --KYC warehouse
	else
	 begin
		if @CaseID = 1
		 begin
			if @Condition in (select Condition from #FieldExceptions)
			 begin
				EXEC dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = 31, --100,
					@NewLocation = @Depot,
					@Note = null,
					@AddedBy = @FSPOperatorNumber
			 end

			if @Condition in (2,3)
			 begin
				EXEC dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = @LastCondition,
					@NewLocation = @Depot,
					@Note = null,
					@AddedBy = @FSPOperatorNumber
			 end
			 
			if @Condition in (53)
			 begin
				EXEC dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = @Condition,
					@NewLocation = @Depot,
					@Note = null,
					@AddedBy = @FSPOperatorNumber
			 end

		 end --		if @CaseID = 1
	 
		--not in FSP Location/Family updated to FSP/20
		if @CaseID = 2  -- 2	Found in Inventory with wrong location	OK
		 begin
			if not exists(select 1 from Equipment_Inventory where Serial = @Serial and MMD_ID = @MMD_ID and Location = @Depot and Condition = 20)
			 begin
				EXEC dbo.spChangeInventoryConditionLocation 
					@Serial = @Serial,
					@MMD_ID = @MMD_ID,
					@NewCondition = 31,
					@NewLocation = @Depot,
					@Note = null,
					@AddedBy = @FSPOperatorNumber

			 end
		 end
		--##23/03/2012 FDI stocktake new rule

		--device to be returned
		if @Condition in (31,37, 53, 58, 59)
		 begin
			raiserror('<b>Serial %s - %s <br>expected:<br><br>Device must be returned to KYC.</b><br>', 16, 1, @Serial, @DeviceName)
		 end
	 end --FSP warehouse
	
	 
	goto Exit_Handle
   end -- if @Count = 1
	


 ---*********************
 --check Odds and Ends
 ---*********************
 SELECT @MMD_ID = ei.MMD_ID,
	@Condition = ei.Condition,
	@Location = ei.Location,
	@LastCondition = ei.LastCondition,
	@LastLocation = ei.LastLocation,
	@DeviceName = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '')
   FROM Equipment_Odds_and_Ends ei
   			JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
  WHERE ei.Serial = @Serial

 SELECT @Count = @@ROWCOUNT

 IF @Count > 1
  BEGIN
	--multiple devices found on this serial, now narrow the search to FSP group
	 SELECT @MMD_ID = ei.MMD_ID,
		@Condition = ei.Condition,
		@Location = ei.Location,
		@LastCondition = ei.LastCondition,
		@LastLocation = ei.LastLocation,
		@DeviceName = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '')
	   FROM Equipment_Odds_and_Ends ei
   				JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
	  WHERE ei.Serial = @Serial
		AND Location IN (SELECT Location FROM #myLocFamily)
	
	
	SELECT @Count = @@ROWCOUNT

  END

 --unique record
 if @Count = 1
  begin
	--case 7, 'Found in Odds and Ends-1st scanned'
	if not exists(select 1 from tblFSPStockTakeLog where BatchID = @BatchID and Serial = @Serial and MMD_ID = @MMD_ID and CaseID in (7,8))
	 begin
		raiserror('<b>Serial %s - %s <br> in doubt:<br><br>PLEASE SCAN SERIAL NUMBER AGAIN.</b><br>', 16, 1, @Serial, @DeviceName)
		select @CaseID = 7;
		goto Exit_Handle;
	 end    

    
    --relocate device from odds and ends to inventory
    exec spTransferBetweenInventoryAndOddsandEnds @Serial = @Serial, @MMD_ID = @MMD_ID;
    
	--update to Depot/100 and back to Depot/Condition    
    exec @ret=dbo.spChangeInventoryConditionLocationTwice @Serial = @Serial
		, @MMD_ID = @MMD_ID
		, @IntermediateCondition = 100
		, @IntermediateLocation = @Depot
		, @FinalCondition = @Condition
		, @FinalLocation = @Depot
		, @Note = @NewInvNote
		, @AddedBy = @FSPOperatorNumber
		, @FinalDate = @dt OUTPUT
		

	
	
	select @CaseID = 3	--Found in Odds and Ends	OK
	

	if @FSPLocation = 300 --KYC warehouse
	 begin
		--if @Condition in (2) ---not in (30, 49, 34)
		-- begin
		--	raiserror('<b>Serial %s - %s <br>expected:<br><br>*******CONDITION %d******<br><br>', 16, 1, @Serial, @DeviceName, @Condition)
		-- end
	 
		raiserror('<b>Serial %s - %s <br>expected:<br><br>Device was transferred back from Odds and Ends.</b><br>', 16, 1, @Serial, @DeviceName)

		--check quarantine if need
		if exists(select 1 from tblFSPStockTakeQuarantine where StockTakeDate = @StockTakeDate and (FSP = @FSPLocation OR FSP = -1))
		 begin
			select @QuarantineMsg = q.Message
				from tblQuarantineDevice qd join tblQuarantine q on qd.QuarantineID = q.QuarantineID
				where Serial = @Serial 
						and MMD_ID = @MMD_ID
						and qd.QuarantineID in (select QuarantineID from tblFSPStockTakeQuarantine where StockTakeDate = @StockTakeDate and (FSP = @FSPLocation OR FSP = -1))
						
			if @@ROWCOUNT >0
			 begin
				raiserror('<b>Serial %s - %s <br>expected:<br><br>*******QUARANTINE APPLIED ******<br> %s</b><br>', 16, 1, @Serial, @DeviceName,@QuarantineMsg)
			 end	
		 end		 

	 end
	else
	 begin
		--Add to QuarantineDevice
		IF NOT EXISTS(SELECT 1 FROM tblQuarantineDevice 
								WHERE QuarantineID = @QUARANTINE_STOCK_TAKE
										AND MMD_ID = @MMD_ID 
										AND Serial = @Serial)
		 BEGIN
			INSERT tblQuarantineDevice(QuarantineID, Serial, MMD_ID, AddedBy, AddedDate, ExpireDate)
				SELECT @QUARANTINE_STOCK_TAKE, @Serial, @MMD_ID, @FSPOperatorNumber, dbo.fnGetDate(), null
		 END	

		raiserror('<b>Serial %s - %s <br>expected:<br><br>Quarantine this device and await instructions from Keycorp Stock Control</b><br>', 16, 1, @Serial, @DeviceName)
	 end --FSP warehouse
	 
	goto Exit_Handle
   end -- if @Count = 1


 ---*********************
 --check Site Equipment
 ---*********************
 SELECT @SiteClientID = se.ClientID,
	@MMD_ID = se.MMD_ID,
	@SiteName = ISNULL(s.Name, ''),
	@TerminalID = s.TerminalID,
	@TerminalNumber = TerminalNumber,
	@DeviceName = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '')
  FROM Site_Equipment se JOIN Sites s ON se.ClientID = s.ClientID
					AND se.TerminalID = s.TerminalID
			JOIN M_M_D m on se.MMD_ID = m.MMD_ID
  WHERE se.Serial = @Serial 


 SELECT @Count = @@ROWCOUNT


 --unique record
 if @Count = 1
  begin

	--case 8, 'Found in Site Equipment-1st scanned'
	if not exists(select 1 from tblFSPStockTakeLog where BatchID = @BatchID and Serial = @Serial and MMD_ID = @MMD_ID and CaseID in (7,8))
	 begin
		raiserror('<b>Serial %s - %s <br> in doubt:<br><br>PLEASE SCAN SERIAL NUMBER AGAIN.</b><br>', 16, 1, @Serial, @DeviceName)
		select @CaseID = 8;
		goto Exit_Handle;
	 end    

    
    --deinstall device from site and added to inventory
    exec spRemoveDeviceFromSite 
			@ClientID = @SiteClientID,
			@TerminalID = @TerminalID,
			@TerminalNumber = @TerminalNumber,
			@MMD_ID = @MMD_ID,
			@Serial = @Serial,
			@Operator = @FSPOperatorNumber

    
	--update to Depot/100 and back to Depot/Condition    
    exec @ret=dbo.spChangeInventoryConditionLocationTwice @Serial = @Serial
		, @MMD_ID = @MMD_ID
		, @IntermediateCondition = 100
		, @IntermediateLocation = @Depot
		, @FinalCondition = 42
		, @FinalLocation = @Depot
		, @Note = @NewInvNote
		, @AddedBy = @FSPOperatorNumber
		, @FinalDate = @dt OUTPUT
		

	
	select @CaseID = 4	--Found on Site Equipment	OK
	

	if @FSPLocation = 300 --KYC warehouse
	 begin

--		raiserror('<b>Serial %s - %s <br>expected:<br><br>*******CONDITION %d******<br><br>', 16, 1, @Serial, @DeviceName, 42)

		raiserror('<b>Serial %s - %s <br>expected:<br><br>Device was removed from site.</b><br>', 16, 1, @Serial, @DeviceName)

		--check quarantine if need
		if exists(select 1 from tblFSPStockTakeQuarantine where StockTakeDate = @StockTakeDate and (FSP = @FSPLocation OR FSP = -1))
		 begin
			select @QuarantineMsg = q.Message
				from tblQuarantineDevice qd join tblQuarantine q on qd.QuarantineID = q.QuarantineID
				where Serial = @Serial 
						and MMD_ID = @MMD_ID
						and qd.QuarantineID in (select QuarantineID from tblFSPStockTakeQuarantine where StockTakeDate = @StockTakeDate and (FSP = @FSPLocation OR FSP = -1))
						
			if @@ROWCOUNT >0
			 begin
				raiserror('<b>Serial %s - %s <br>expected:<br><br>*******QUARANTINE APPLIED ******<br> %s</b><br>', 16, 1, @Serial, @DeviceName,@QuarantineMsg)
			 end	
		 end		 
		
	 end
	else
	 begin
		--Add to QuarantineDevice
		IF NOT EXISTS(SELECT 1 FROM tblQuarantineDevice 
								WHERE QuarantineID = @QUARANTINE_STOCK_TAKE
										AND MMD_ID = @MMD_ID 
										AND Serial = @Serial)
		 BEGIN
			INSERT tblQuarantineDevice(QuarantineID, Serial, MMD_ID, AddedBy, AddedDate, ExpireDate)
				SELECT @QUARANTINE_STOCK_TAKE, @Serial, @MMD_ID, @FSPOperatorNumber, dbo.fnGetDate(), null
		 END	
		

		raiserror('<b>Serial %s - %s <br>No Expected:<br><br>Quarantine this device and await instructions from Keycorp Stock Control</b><br>', 16, 1, @Serial, @DeviceName)
	 end --FSP warehouse
	 
	goto Exit_Handle
   end -- if @Count = 1


  --Case 5      Not found in CAMS	Exception
  SELECT @DeviceName = ISNULL(@DeviceName, '')
  RAISERROR('<b>Serial %s  <br>not expected:<br><br>Device not not found</b><br>', 16, 1, @Serial)
  SELECT @CaseID = 5


Exit_Handle:
 --if device scanned in 2nd times for case 3,4 (Odds and Ends, Site Equipment), overwrite the 1st scan
 if exists(select 1 from tblFSPStockTakeLog where BatchID = @BatchID and Serial = @Serial and MMD_ID = @MMD_ID and CaseID in (7,8))
	and @CaseID in (3,4)
  begin
	update tblFSPStockTakeLog
		set CaseID = @CaseID
	where BatchID = @BatchID 
		and Serial = @Serial 
		and MMD_ID = @MMD_ID 
		and CaseID in (7,8)
  end
 else
  begin
	 INSERT tblFSPStockTakeLog (BatchID, Serial, MMD_ID, CaseID, ScannedDateTime)
		Values (@BatchID, @Serial, @MMD_ID, @CaseID, @CurDateTime)
  end
 RETURN @@ERROR

GO

Grant EXEC on spWebAddFSPStockTakeLog to eCAMS_Role
Go


Use WebCAMS
Go


IF EXISTS(SELECT 1 FROM sysobjects where name = 'spWebAddFSPStockTakeLog' and type = 'p')
	drop procedure dbo.spWebAddFSPStockTakeLog
go

Create Procedure dbo.spWebAddFSPStockTakeLog 
	(
		@UserID int,
		@BatchID int,
		@Serial varchar(32)
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDACloseJob.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebAddFSPStockTakeLog 
		@UserID = @UserID,
		@BatchID = @BatchID,
		@Serial = @Serial

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret

/*

spWebAddFSPStockTakeLog @UserID = 199649,
		@BatchID = 14,
		@Serial = '       A79661195'
		
*/
Go

Grant EXEC on spWebAddFSPStockTakeLog to eCAMS_Role
Go

