Use CAMS
Go

Alter Procedure dbo.spWebGetFSPJobCount 
	(
		@FSPID int
	)
	AS
--<!--$$Revision: 23 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 2/02/12 16:51 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobCount.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Get job/stock summary info for a FSP
*/

 set nocount on
 DECLARE 	@SwapJobCount int,
		@InstallJobCount int,
		@DeinstallJobCount int,
		@UpgradeJobCount int,
		@PickPackTaskCount int,
		@StockInTransitCount int,
		@FSPExceptionCount int,
		@StockReturnedCount int,
		@StockTakeDate datetime


 --get each category job count
 SELECT @SwapJobCount = ISNULL(Count(*), 0)
	FROM vwCalls with (nolock)
	WHERE AssignedTo = @FSPID
			AND AllowFSPWebAccess = 1

 SELECT @InstallJobCount = ISNULL(Count(*), 0)
	FROM vwIMSJob with (nolock)
	WHERE BookedInstaller = @FSPID
		AND JobType = 'INSTALL'
			AND AllowFSPWebAccess = 1

 SELECT @DeinstallJobCount = ISNULL(Count(*), 0)
	FROM vwIMSJob with (nolock)
	WHERE BookedInstaller = @FSPID
		AND JobType = 'DEINSTALL'
			AND AllowFSPWebAccess = 1

 SELECT @UpgradeJobCount = ISNULL(Count(*), 0)
	FROM vwIMSJob with (nolock)
	WHERE BookedInstaller = @FSPID
		AND JobType = 'UPGRADE'
			AND AllowFSPWebAccess = 1

 SELECT @PickPackTaskCount = ISNULL(Count(*), 0)
	FROM tblTask with (nolock)
	WHERE AssignedTo = @FSPID
		AND TaskTypeID = 1

 
 SELECT @StockInTransitCount = Count(*)
	FROM Equipment_Inventory with (nolock)
	WHERE Location IN (SELECT * FROM dbo.fnGetLocationChildrenExt(@FSPID))
		AND Condition = 2


 SELECT @FSPExceptionCount = COUNT(*)
	FROM IMS_Jobs with (nolock)
	WHERE StatusID = 7 --'FSP EXCEPTION'
		AND BookedInstaller IN (SELECT * FROM dbo.fnGetLocationChildrenExt(@FSPID))

 SELECT @FSPExceptionCount = @FSPExceptionCount + COUNT(*)
	FROM Calls with (nolock)
	WHERE StatusID = 7 --'FSP EXCEPTION'
		AND AssignedTo IN (SELECT * FROM dbo.fnGetLocationChildrenExt(@FSPID))



 SELECT @StockReturnedCount = COUNT(*)
	FROM Equipment_Inventory with (nolock)
	WHERE Condition in (31,37,58,59,53,1)
		AND Location in  (SELECT * FROM dbo.fnGetLocationChildrenExt(@FSPID))

 SELECT @StockTakeDate = StockTakeDate
	FROM tblFSPStockTakeTarget
	where (FSP = @FSPID OR FSP = -1)
		and StockTakeDate >= GETDATE()
		and StockTakeDate not in (select StockTakeDate from tblFSPStockTake where Depot = @FSPID)
		

 --return the job counts as a recordset
 SELECT SwapJobCount = @SwapJobCount, 
	InstallJobCount = @InstallJobCount, 
	DeinstallJobCount = @DeinstallJobCount,
	UpgradeJobCount = @UpgradeJobCount,
	PickPackTaskCount = @PickPackTaskCount,
	StockInTransitCount = @StockInTransitCount,
	FSPExceptionCount = @FSPExceptionCount,
	StockReturnedCount = @StockReturnedCount,
	StockTakeDate = @StockTakeDate 


GO

Grant EXEC on spWebGetFSPJobCount to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spWebGetFSPJobCount 
	(
		@FSPID int
	)
	AS
--<!--$$Revision: 11 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 11/02/05 2:19p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobCount.sql $-->
--<!--$$NoKeywords: $-->
 set nocount on
 EXEC Cams.dbo.spWebGetFSPJobCount @FSPID = @FSPID

/*
 spWebGetFSPJobCount 3000
spWebGetFSPJobCount 2300

*/

Go

Grant EXEC on spWebGetFSPJobCount to eCAMS_Role
Go
