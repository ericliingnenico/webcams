use CAMS
go

ALTER PROC spWebGetFSPDeviceListBySerial (
	@UserID int,
	@Serial varchar(32),
	@From tinyint)
as
--<!--$$Revision: 11 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/03/15 14:10 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPDeviceListBySerial.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Get device list for the given FSP and Serial number
*/
DECLARE @FSPID int

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

 --init
 SELECT @FSPID = InstallerID 
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 --handle exception first - only proceed the search if it is fsp
 if @FSPID is null
  begin
	SELECT ei.ClientID,
		ei.Serial,
		ei.MMD_ID,
		Device = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, ''),
		Location = CAST(ei.Location as varchar),
		Status = dbo.fnParseFSPStockCondition(ei.Condition),
		SoftwareVer = ei.SoftwareVersion,
		HardwareVer = ei.HardwareRevision,
		ei.DateIn,
		ei.Note
	  FROM Equipment_Inventory ei JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
	 WHERE 1 = 2
	
	return
  end

 SELECT * 
	INTO #myLocFamily
	FROM dbo.fnGetLocationFamily(@FSPID)

 SELECT @Serial = dbo.fnLeftPadSerial(@Serial)

 --search inventory and site equipment
 IF @From = 1 --from desktop
  BEGIN
	--inventory
	SELECT ei.ClientID,
		ei.Serial,
		ei.MMD_ID,
		Device = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, ''),
		Location = CAST(ei.Location as varchar),
		Status = dbo.fnParseFSPStockCondition(ei.Condition),
		SoftwareVer = ei.SoftwareVersion,
		HardwareVer = ei.HardwareRevision,
		ei.DateIn,
		ei.Note
	  FROM Equipment_Inventory ei LEFT OUTER JOIN #myLocFamily l ON ei.Location = l.Location
					JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
	 WHERE ei.Serial = @Serial
	UNION
	SELECT se.ClientID,
		se.Serial,
		se.MMD_ID,
		Device = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, ''),
		Location = se.ClientID + ' ' + se.TerminalID,
		Status = 'INSTALLED',
		SoftwareVer = se.SoftwareVersion,
		HardwareVer = se.HardwareRevision,
		DateIn = se.LastChanged,
		Note = 'Merchant: ' + s.[Name]
	  FROM Site_Equipment se JOIN Sites s ON se.ClientID = s.ClientID and se.TerminalID = s.TerminalID
				JOIN M_M_D m on se.MMD_ID = m.MMD_ID
	 WHERE se.Serial = @Serial	
  END

 IF @From = 2 --from PDA
  BEGIN
	--inventory
	SELECT ei.Serial,
		Device = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, ''),
		Location = CAST(ei.Location as varchar),
		Status = dbo.fnParseFSPStockCondition(ei.Condition),
		SoftwareVer = ei.SoftwareVersion,
		HardwareVer = ei.HardwareRevision,
		ei.DateIn,
		ei.Note
	  FROM Equipment_Inventory ei LEFT OUTER JOIN #myLocFamily l ON ei.Location = l.Location
					JOIN M_M_D m on ei.MMD_ID = m.MMD_ID
	 WHERE ei.Serial = @Serial
	UNION
	SELECT se.Serial,
		Device = ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, ''),
		Location = se.ClientID + ' ' + se.TerminalID,
		Status = 'INSTALLED',
		SoftwareVer = se.SoftwareVersion,
		HardwareVer = se.HardwareRevision,
		DateIn = se.LastChanged,
		Note = 'Merchant: ' + s.[Name]
	  FROM Site_Equipment se JOIN Sites s ON se.ClientID = s.ClientID and se.TerminalID = s.TerminalID
				JOIN M_M_D m on se.MMD_ID = m.MMD_ID
	 WHERE se.Serial = @Serial	
  END

/*
 EXEC spWebGetFSPDeviceListBySerial @UserID = 199513, 
					@Serial = '41101623',
					@From = 1

 EXEC spWebGetFSPDeviceListBySerial @UserID = 199513,
					@Serial = '2322416',
					@From = 1

--select top 30 * from Site_Equipment where clientid = 'wbc'
 EXEC spWebGetFSPDeviceListBySerial @UserID = 199513, 
					@Serial = '41101623',
					@From = 2

 EXEC spWebGetFSPDeviceListBySerial @UserID = 199513,
					@Serial = '2322416',
					@From = 2


*/
Go

GRANT EXEC on spWebGetFSPDeviceListBySerial to eCAMS_Role
Go



USE webCAMS
go

ALTER proc spWebGetFSPDeviceListBySerial (
	@UserID int,
	@Serial varchar(32),
	@From tinyint)
as
 EXEC CAMS.dbo.spWebGetFSPDeviceListBySerial @UserID = @UserID,
						@Serial = @Serial,
						@From = @From

Go

GRANT EXEC on spWebGetFSPDeviceListBySerial to eCAMS_Role
Go

				

