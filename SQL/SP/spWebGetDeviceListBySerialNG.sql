
Use CAMS
Go

if object_id('spWebGetDeviceListBySerialNG') is null
	exec ('create procedure dbo.spWebGetDeviceListBySerialNG as return 1')
go


Alter Procedure dbo.spWebGetDeviceListBySerialNG 
	(
		@UserID int,
		@ClientID varchar(3),
		@Serial varchar(32)
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 25/08/15 12:12 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetDeviceListBySerialNG.sql $-->
--<!--$$NoKeywords: $-->
DECLARE @MyClientList TABLE (ClientID varchar(3), MMD_ID varchar(5))

 --verify the clientid is under the user
 INSERT @MyClientList (ClientID, MMD_ID)
   SELECT ClientID, MMD_ID FROM vwUserClientMMD WHERE UserID = @UserID AND ClientID = @ClientID

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
	LTRIM(Serial) as Serial,
	e.MMD_ID,
	m.Maker,
	m.Model,
	m.Device,
	CASE  WHEN e.Condition = 164 THEN 'TRANS. TO OTHER SUPPLIER' 
		ELSE 'UNDER KYC CONTROL' END
	 as Status

	FROM Equipment_Inventory e WITH (NOLOCK) JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
				JOIN M_M_D m  WITH (NOLOCK) ON e.MMD_ID = m.MMD_ID
	WHERE Serial like @Serial
 UNION
 SELECT
	LTRIM(Serial) as Serial,
	e.MMD_ID,
	m.Maker,
	m.Model,
	m.Device,
	CASE  WHEN e.Condition = 164 THEN 'TRANS. TO OTHER SUPPLIER' 
		WHEN e.Condition IN (69, 70, 94, 98) THEN 'REMOVED FROM ASSET REGISTER'
		ELSE 'NO RECORD OR SERIAL' END
	 as Status

	FROM Equipment_Odds_and_Ends e  WITH (NOLOCK) JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
				JOIN M_M_D m  WITH (NOLOCK) ON e.MMD_ID = m.MMD_ID
	WHERE Serial like @Serial
 UNION
 SELECT 
	LTRIM(Serial) as Serial,
	e.MMD_ID,
	m.Maker,
	m.Model,
	m.Device,
	'INSTALLED & IN SERVICE' as Status

	FROM Site_Equipment e  WITH (NOLOCK) JOIN @MyClientList t ON e.ClientID = t.ClientID AND e.MMD_ID = ISNULL(t.MMD_ID, e.MMD_ID)
				JOIN M_M_D m  WITH (NOLOCK) ON e.MMD_ID = m.MMD_ID
	WHERE e.ClientID = @ClientID 
		AND Serial like @Serial


--Return
RETURN @@ERROR

GO

Grant EXEC on spWebGetDeviceListBySerialNG to eCAMS_Role
Go
