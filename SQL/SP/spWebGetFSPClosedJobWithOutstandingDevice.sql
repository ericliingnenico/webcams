
Use CAMS
Go

Alter Procedure dbo.spWebGetFSPClosedJobWithOutstandingDevice 
	(
		@UserID int,
		@FSPID int,
		@FromDate datetime,
		@ToDate datetime,
		@From tinyint
	)
	AS
--<!--$$Revision: 11 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/02/09 4:02p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPClosedJobWithOutstandingDevice.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get FSP closed jobs with outstanding devices
--Parameter: @From - 1: From Desktop WebSite, 2: From PDA, 3: From Download
DECLARE @InstallerID int

 SET NOCOUNT ON
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 --init
 SELECT @ToDate = DATEADD(d, 1, @ToDate)

 SELECT	@InstallerID = InstallerID 
   FROM webCAMS.dbo.tblUser
  WHERE UserID = @UserID


 --cache my loc family
 SELECT * 
   INTO #myLocChildren
   FROM dbo.fnGetLocationChildrenExt(@InstallerID)

 IF EXISTS(SELECT 1 FROM #myLocChildren WHERE Location = @FSPID)
  BEGIN
	DELETE #myLocChildren

	INSERT #myLocChildren
	SELECT * 
   	  FROM dbo.fnGetLocationChildrenExt(@FSPID)
  END
 ELSE
  BEGIN
	DELETE #myLocChildren
  END

 --from web
 IF @From = 1
  BEGIN
	
	SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + cast(j.JobID as varchar) + ''')">' + cast(j.JobID as varchar) + '</A>' as JobID,
		j.ClientID,
		j.JobType,
		j.Name as MerchantName,
		j.BookedInstaller as FSP,
		je.Serial,
		ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '') as Device,
		j.ClosedDateTime
	  FROM IMS_Job_Equipment_History je JOIN vwIMSJobHistory j ON je.JobID= j.JobID
						JOIN M_M_D m ON je.MMD_ID = m.MMD_ID
						JOIN #myLocChildren l ON j.BookedInstaller = l.Location
	 WHERE je.StockReturnTypeID = 0
		AND je.ActionID = 2 --'REMOVE'
		AND dbo.fnIsSerialisedDevice(je.Serial) = 1
		AND j.ClosedDateTime between @FromDate and @ToDate
		
	UNION 

	SELECT 
		'<A HREF="#" onclick="javascript:popupwindow(''../Member/FSPJobSheetExt.aspx?JID=' + j.CallNumber + ''')">' + j.CallNumber + '</A>' as JobID,
		j.ClientID,
		'SWAP' as JobType,
		j.Name as MerchantName,
		j.AssignedTo as FSP,
		je.Serial,
		ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '') as Device,
		j.ClosedDateTime
	  FROM Call_Equipment_History je JOIN vwCallsHistory j ON je.CallNumber = j.CallNumber
						JOIN M_M_D m ON je.MMD_ID = m.MMD_ID
						JOIN #myLocChildren l ON j.AssignedTo = l.Location
	 WHERE je.StockReturnTypeID = 0
		AND dbo.fnIsSerialisedDevice(je.Serial) = 1
		AND j.ClosedDateTime between @FromDate and @ToDate
		AND ISNUMERIC(j.CallNumber) = 1

		
  END

 --from Download request
 IF @From = 3
  BEGIN
	
	SELECT 
		Cast(j.JobID as bigint) as JobID,
		j.ClientID,
		j.JobType,
		j.Name as MerchantName,
		j.BookedInstaller as FSP,
		je.Serial,
		ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '') as Device,
		j.ClosedDateTime
	  FROM IMS_Job_Equipment_History je JOIN vwIMSJobHistory j ON je.JobID= j.JobID
						JOIN M_M_D m ON je.MMD_ID = m.MMD_ID
						JOIN #myLocChildren l ON j.BookedInstaller = l.Location
	 WHERE je.StockReturnTypeID = 0
		AND je.ActionID = 2 --'REMOVE'
		AND dbo.fnIsSerialisedDevice(je.Serial) = 1
		AND j.ClosedDateTime between @FromDate and @ToDate
		
	UNION 

	SELECT 
		j.CallNumber as JobID,
		j.ClientID,
		'SWAP' as JobType,
		j.Name as MerchantName,
		j.AssignedTo as FSP,
		je.Serial,
		ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '') as Device,
		j.ClosedDateTime
	  FROM Call_Equipment_History je JOIN vwCallsHistory j ON je.CallNumber = j.CallNumber
						JOIN M_M_D m ON je.MMD_ID = m.MMD_ID
						JOIN #myLocChildren l ON j.AssignedTo = l.Location
	 WHERE je.StockReturnTypeID = 0
		AND dbo.fnIsSerialisedDevice(je.Serial) = 1
		AND j.ClosedDateTime between @FromDate and @ToDate
		AND ISNUMERIC(j.CallNumber) = 1

		
  END

GO

Grant EXEC on spWebGetFSPClosedJobWithOutstandingDevice to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPClosedJobWithOutstandingDevice 
	(
		@UserID int,
		@FSPID int,
		@FromDate datetime,
		@ToDate datetime,
		@From tinyint
	)
	AS
--<!--$$Revision: 9 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/05/04 2:22p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPClosedJobWithOutstandingDevice.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPClosedJobWithOutstandingDevice @UserID = @UserID, 
				@FSPID = @FSPID,
				@FromDate = @FromDate,
				@ToDate = @ToDate,
				@From = @From

/*

exec dbo.spWebGetFSPClosedJobWithOutstandingDevice @UserID = 199513, 
				@FSPID = 3003,
				@FromDate = '2005-10-01',
				@ToDate = '2005-11-01',
				@From =1

*/
GO

Grant EXEC on spWebGetFSPClosedJobWithOutstandingDevice to eCAMS_Role
Go
