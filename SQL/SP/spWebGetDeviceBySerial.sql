Use WebCAMS
Go

Alter Procedure dbo.spWebGetDeviceBySerial 
	(
		@UserID int,
		@ClientID varchar(3),
		@Serial varchar(32),
		@From varchar(3)
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-05-03 14:59:27$-->
--<!--$ModifiedBy: Andrew Falzon <andrew.falzon@bambora.com>$-->
--<!--$Comment: CAMS-559 Additional serial length fixes.$-->
--<!--$Commit$-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebGetDeviceBySerial @UserID = @UserID, @ClientID = @ClientID, @Serial = @Serial, @From = @From
/*
spWebGetDeviceBySerial 199514, 'wbc', '         1909661', 'SE'
*/
GO

Grant EXEC on spWebGetDeviceBySerial to eCAMS_Role
Go

Use CAMS
Go

Alter Procedure dbo.spWebGetDeviceBySerial 
	(
		@UserID int,
		@ClientID varchar(3),
		@Serial varchar(32),
		@From varchar(3)
	)
	AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-05-03 14:59:27$-->
--<!--$ModifiedBy: Andrew Falzon <andrew.falzon@bambora.com>$-->
--<!--$Comment: CAMS-559 Additional serial length fixes.$-->
--<!--$Commit$-->
--Purpose: Get device details for the given serial number. The location of the device can be from:
--		Equipment Inventory, Equipment Odds and Ends, Site Equipment.
--		The consumer of this proc is the DeviceView web form in eCAMS.

DECLARE @MyClientList TABLE (ClientID varchar(3), MMD_ID varchar(5));
declare @Note varchar(100),
	@OrgMMD_ID varchar(10),
	@ParentBOMID int,
	@OriginalSerial varchar(32),
	@OriginalClientID varchar(3),
	@OriginalPackNumber varchar(20)



--init
select @Note = ''

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 --verify the clientid is under the user
 INSERT @MyClientList (ClientID, MMD_ID)
   SELECT ClientID, MMD_ID FROM WebCams.dbo.vwUserClientMMD u JOIN dbo.fnGetSiteClientIDFromDeviceClientID (@ClientID)  s ON u.ClientID = s.SiteClientID
   WHERE UserID = @UserID


 --add extra clientID
 IF @@ROWCOUNT > 0 AND NOT EXISTS(SELECT 1 FROM @MyClientList WHERE ClientID = dbo.fnGetDeviceClientIDFromSiteClientID (@ClientID))
   INSERT @MyClientList (ClientID, MMD_ID) 
		SELECT dbo.fnGetDeviceClientIDFromSiteClientID (@ClientID), MMD_ID FROM @MyClientList WHERE ClientID = @ClientID


 
 --Left pad serial number
 SELECT @Serial = dbo.fnLeftPadSerial(@Serial)

 --show Albert SIM card for CBA Albert Device
 --get BOM OrgMMD if exists
 select @OrgMMD_ID = bs.MMD_ID from tblBOMStructure bs join tblBOMMMDExt be on bs.MMD_ID = be.MMD_ID and bs.ParentMMD_ID is null
				join M_M_D m on be.OrgMMD_ID = m.MMD_ID and m.Clientid = @ClientID

 if @OrgMMD_ID is not null
  begin
	select @ParentBOMID = BOMID 
		from tblBOM 
		where MMD_ID = @OrgMMD_ID and Serial = @Serial
	if @ParentBOMID is not null
	 begin
		select @Note = @Note + isnull(m.Device, '') + ':' + ltrim(b.Serial) + ' .'
			from tblBOM b join M_M_D m on b.MMD_ID = m.MMD_ID
			where ParentBOMID = @ParentBOMID and m.Device like '%SIM%'
	 end
  end

 --bundle
 if @From = 'EI'
  begin
	select @OriginalSerial = e.OriginalSerial,
		@OriginalClientID = e.ClientID
	 from Equipment_Inventory e JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
	 where e.Serial = @Serial
  end

 if @From = 'OE'
  begin
	select @OriginalSerial = e.OriginalSerial,
		@OriginalClientID = e.ClientID
	 from Equipment_Odds_and_Ends e JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
	 where e.Serial = @Serial
   end

 if @From = 'SE'
  begin
	select @OriginalSerial = e.OriginalSerial,
		@OriginalClientID = e.ClientID
	 from Equipment_History e JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
	 where e.Serial = @Serial
			and e.Location = 999
			and e.Condition = 99
			and e.DateOut is null
  end


 if @OriginalSerial is not null
  begin
	select @OriginalPackNumber = PacketNumber
		from Equipment_Inventory e join M_M_D m on e.MMD_ID = m.MMD_ID and m.Device like '%SIM%'
		where e.Serial = @OriginalSerial and e.ClientID = @OriginalClientID	

	if len(isnull(@OriginalPackNumber,'')) between 8 and 12
	 begin
		select @Note = @Note + 'SIMCardNo: ' + @OriginalPackNumber
	 end

  end


 ---****In Equipment_Inventory
 IF @From = 'EI'
  BEGIN

	SELECT TOP 1
		LTRIM(e.Serial) as Serial,
		e.MMD_ID,
		m.Maker,
		m.Model,
		m.Device,
		CASE  WHEN e.Condition = 164 THEN 'TRANS. TO OTHER SUPPLIER' 
			ELSE 'UNDER KYC CONTROL' END
		 as Status,
		eh.TerminalID as TerminalID,
		dbo.fnFormatDateTimeWD(eh.DateIn) as eqDateIn,
		dbo.fnFormatDateTimeWD(eh.DateOut) As eqDateOut,
		s.MerchantID + ' ' + CASE WHEN s.ClientID <> e.ClientID THEN s.ClientID ELSE '' END as MerchantID,
		s.[Name],
		tzDI.TimeZone as DateInTimeZone,
		tzDO.TimeZone as DateOutTimeZone,
		Note = @Note + CASE 
						WHEN m.Device LIKE '%SIM%' AND ISNULL(e.PacketNumber, '')<>'' THEN 'SIMCardNo: ' + e.PacketNumber
						WHEN m.MMD_ID = 'CMV52' and m.[ClientID]='CBA' THEN  (Select 'SIM CARD TELSTRA:' + tss.TelstraSimSerial + ', SIM CARD OPTUS:' + tss.OptusSimSerial From tblTerminalSerialSim tss Where tss.ClientID = 'CBA' And tss.TerminalSerial = @Serial)
						ELSE ''
				END
		FROM Equipment_Inventory e JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
					JOIN M_M_D m ON e.MMD_ID = m.MMD_ID
					LEFT OUTER JOIN Equipment_History eh ON e.Serial = eh.Serial 
										AND e.ClientID = eh.ClientID
										AND eh.Location = 999
										AND eh.Condition = 99
					LEFT OUTER JOIN Sites s ON s.ClientID IN (SELECT ClientID FROM @MyClientList)
									AND eh.TerminalID = s.TerminalID
					LEFT OUTER JOIN tblTimeZone tzDI ON tzDI.State = 'VIC'  ---melbourne local time
										AND eh.DateIn >= tzDI.FromDate
										AND eh.DateIn <= tzDI.ToDate
					LEFT OUTER JOIN tblTimeZone tzDO ON tzDO.State = 'VIC'  ---melbourne local time
										AND eh.DateOut >= tzDO.FromDate
										AND eh.DateOut <= tzDO.ToDate

		WHERE e.Serial = @Serial
		ORDER By eh.DateIn DESC		
  END --IF @From = 'EI', In Equipment_Inventory

 ---****In Equipment_Odds_and_Ends
 IF @From = 'OE'
  BEGIN
	 SELECT TOP 1
		LTRIM(e.Serial) as Serial,
		e.MMD_ID,
		m.Maker,
		m.Model,
		m.Device,
		CASE  WHEN e.Condition = 164 THEN 'TRANS. TO OTHER SUPPLIER' 
			WHEN e.Condition IN (69, 70, 94, 98) THEN 'REMOVED FROM ASSET REGISTER'
			ELSE 'NO RECORD OR SERIAL' END
		 as Status,
		eh.TerminalID as TerminalID,
		dbo.fnFormatDateTimeWD(eh.DateIn) as eqDateIn,
		dbo.fnFormatDateTimeWD(eh.DateOut) As eqDateOut,
		s.MerchantID + ' ' + CASE WHEN s.ClientID <> e.ClientID THEN s.ClientID ELSE '' END as MerchantID,
		s.[Name],
		tzDI.TimeZone as DateInTimeZone,
		tzDO.TimeZone as DateOutTimeZone,
		Note = @Note + CASE 
						WHEN m.Device LIKE '%SIM%' AND ISNULL(eh.PacketNumber, '')<>'' THEN 'SIMCardNo: ' + eh.PacketNumber
						WHEN m.MMD_ID = 'CMV52' and m.[ClientID]='CBA' THEN  (Select 'SIM CARD TELSTRA:' + tss.TelstraSimSerial + ', SIM CARD OPTUS:' + tss.OptusSimSerial From tblTerminalSerialSim tss Where tss.ClientID = 'CBA' And tss.TerminalSerial = @Serial)
						ELSE ''
				END
		FROM Equipment_Odds_and_Ends e JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
					JOIN M_M_D m ON e.MMD_ID = m.MMD_ID
					LEFT OUTER JOIN Equipment_History eh ON e.Serial = eh.Serial 
										AND e.ClientID = eh.ClientID
										AND eh.Location = 999
										AND eh.Condition = 99
					LEFT OUTER JOIN Sites s ON  s.ClientID IN (SELECT ClientID FROM @MyClientList)
									AND eh.TerminalID = s.TerminalID
					LEFT OUTER JOIN tblTimeZone tzDI ON tzDI.State = 'VIC'  ---melbourne local time
										AND eh.DateIn >= tzDI.FromDate
										AND eh.DateIn <= tzDI.ToDate
					LEFT OUTER JOIN tblTimeZone tzDO ON tzDO.State = 'VIC'  ---melbourne local time
										AND eh.DateOut >= tzDO.FromDate
										AND eh.DateOut <= tzDO.ToDate

		WHERE e.Serial = @Serial
		ORDER By eh.DateIn DESC		
		
  END --IF @From = 'OE', in Equipment_Odds_and_Ends

 ---****In Site_Equipment
 IF @From = 'SE'
  BEGIN
	 SELECT TOP 1
		LTRIM(e.Serial) as Serial,
		e.MMD_ID,
		m.Maker,
		m.Model,
		m.Device,
		'INSTALLED & IN SERVICE' as Status,
		e.TerminalID,
		dbo.fnFormatDateTimeWD(eh.DateIn) as eqDateIn,
		dbo.fnFormatDateTimeWD(eh.DateOut) As eqDateOut,
		s.MerchantID,
		s.[Name],
		tzDI.TimeZone as DateInTimeZone,
		tzDO.TimeZone as DateOutTimeZone,
		Note = @Note + CASE 
					WHEN m.Device LIKE '%SIM%' AND ISNULL(eh.PacketNumber, '')<>'' THEN 'SIMCardNo: ' + eh.PacketNumber
					WHEN m.MMD_ID = 'CMV52' and m.[ClientID]='CBA' THEN  (Select 'SIM CARD TELSTRA:' + tss.TelstraSimSerial + ', SIM CARD OPTUS:' + tss.OptusSimSerial From tblTerminalSerialSim tss Where tss.ClientID = 'CBA' And tss.TerminalSerial = @Serial)
					ELSE ''
				END
		FROM Site_Equipment e  JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
					join Sites s ON e.ClientID = s.ClientID
									and e.TerminalID = s.TerminalID
					JOIN M_M_D m ON e.MMD_ID = m.MMD_ID
					LEFT OUTER JOIN Equipment_History eh ON e.Serial = eh.Serial 
										AND e.MMD_ID = eh.MMD_ID
										AND eh.Location = 999
										AND eh.Condition = 99
										and eh.DateOut is null
					LEFT OUTER JOIN tblTimeZone tzDI ON tzDI.State = 'VIC'  ---melbourne local time
										AND eh.DateIn >= tzDI.FromDate
										AND eh.DateIn <= tzDI.ToDate
					LEFT OUTER JOIN tblTimeZone tzDO ON tzDO.State = 'VIC'  ---melbourne local time
										AND eh.DateOut >= tzDO.FromDate
										AND eh.DateOut <= tzDO.ToDate
		WHERE e.Serial = @Serial
		ORDER By eh.DateIn DESC		
  END --IF @From = 'SE', in Site_Equipment


--Return error code
RETURN @@ERROR

GO

Grant EXEC on spWebGetDeviceBySerial to eCAMS_Role
Go


