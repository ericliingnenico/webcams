Use WebCAMS
Go

Alter Procedure dbo.spWebGetDeviceListBySerial 
	(
		@UserID int,
		@ClientID varchar(3),
		@Serial varchar(32)
	)
	AS
--<!--$$Revision: 12 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 4/10/16 16:14 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetDeviceListBySerial.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC CAMS.dbo.spWebGetDeviceListBySerial @UserID = @UserID, @ClientID = @ClientID, @Serial = @Serial
/*
spWebGetDeviceListBySerial 199511, 'wbc', '21999853'
*/
GO

Grant EXEC on spWebGetDeviceListBySerial to eCAMS_Role
Go


Use CAMS
Go

Alter Procedure dbo.spWebGetDeviceListBySerial 
	(
		@UserID int,
		@ClientID varchar(3),
		@Serial varchar(32)
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 31/03/03 11:39 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetDeviceListBySerial.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @MyClientList TABLE (ClientID varchar(3), MMD_ID varchar(5))

 --verify the clientid is under the user
 INSERT @MyClientList (ClientID, MMD_ID)
   SELECT ClientID, MMD_ID FROM WebCams.dbo.vwUserClientMMD WHERE UserID = @UserID AND ClientID = @ClientID

 --add extra clientID
 IF @@ROWCOUNT > 0 AND NOT EXISTS(SELECT 1 FROM @MyClientList WHERE ClientID = dbo.fnGetDeviceClientIDFromSiteClientID (@ClientID))
   INSERT @MyClientList (ClientID, MMD_ID) 
		SELECT dbo.fnGetDeviceClientIDFromSiteClientID (@ClientID), MMD_ID FROM @MyClientList WHERE ClientID = @ClientID

 --Left pad serial number only when no wildcard passed in
 select @Serial = LTRIM(rtrim(@Serial))
 if not(left(@Serial,1) = '%' or RIGHT(@Serial,1) = '%')
 	select @Serial = dbo.fnLeftPadSerial(@Serial)

 --limit no of records to 20
 set rowcount  20
 

 SELECT 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/DeviceView.aspx?SN=' + LTRIM(Serial) + '&CID=' + e.ClientID + '&From=EI'')">' + LTRIM(Serial) + '</A>' as Serial,
	e.MMD_ID,
	m.Maker,
	m.Model,
	m.Device,
	CASE  WHEN e.Condition = 164 THEN 'TRANS. TO OTHER SUPPLIER' 
		ELSE 'UNDER KYC CONTROL' END
	 as Status,
	 Jobs = case when isnull(e.TerminalID, '') <> '' then '<A HREF="../Member/TerminalList.aspx?CID=' + e.ClientID + '&TID=' + e.TerminalID + '">ViewJobs</A>' else '' end

	FROM Equipment_Inventory e WITH (NOLOCK) JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
				JOIN M_M_D m  WITH (NOLOCK) ON e.MMD_ID = m.MMD_ID
	WHERE Serial like @Serial
 UNION
 SELECT
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/DeviceView.aspx?SN=' + LTRIM(Serial) + '&CID=' + e.ClientID + '&From=OE'')">' + LTRIM(Serial) + '</A>' as Serial,
	e.MMD_ID,
	m.Maker,
	m.Model,
	m.Device,
	CASE  WHEN e.Condition = 164 THEN 'TRANS. TO OTHER SUPPLIER' 
		WHEN e.Condition IN (69, 70, 94, 98) THEN 'REMOVED FROM ASSET REGISTER'
		ELSE 'NO RECORD OR SERIAL' END
	 as Status,
	 Jobs = case when isnull(e.TerminalID, '') <> '' then '<A HREF="../Member/TerminalList.aspx?CID=' + e.ClientID + '&TID=' + e.TerminalID + '">ViewJobs</A>' else '' end

	FROM Equipment_Odds_and_Ends e  WITH (NOLOCK) JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
				JOIN M_M_D m  WITH (NOLOCK) ON e.MMD_ID = m.MMD_ID
	WHERE Serial like @Serial
 UNION
 SELECT 
	'<A HREF="#" onclick="javascript:popupwindow(''../Member/DeviceView.aspx?SN=' + LTRIM(Serial) + '&CID=' + e.ClientID + '&From=SE'')">' + LTRIM(Serial) + '</A>' as Serial,
	e.MMD_ID,
	m.Maker,
	m.Model,
	m.Device,
	'INSTALLED & IN SERVICE' as Status,
	 Jobs = case when isnull(e.TerminalID, '') <> '' then '<A HREF="../Member/TerminalList.aspx?CID=' + e.ClientID + '&TID=' + e.TerminalID + '">ViewJobs</A>' else '' end

	FROM Site_Equipment e  WITH (NOLOCK) JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
				JOIN M_M_D m  WITH (NOLOCK) ON e.MMD_ID = m.MMD_ID
	WHERE e.ClientID = @ClientID 
		AND Serial like @Serial


--Return
RETURN @@ERROR

GO

Grant EXEC on spWebGetDeviceListBySerial to eCAMS_Role
Go
