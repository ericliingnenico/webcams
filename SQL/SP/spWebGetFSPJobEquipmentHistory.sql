use CAMS
go

Alter proc spWebGetFSPJobEquipmentHistory (
	@UserID int,
	@JobID bigint)
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 13/11/06 2:16p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobEquipmentHistory.sql $-->
--<!--$$NoKeywords: $-->
as
 Declare @FSPID int

 SET NOCOUNT ON
 SELECT @FSPID = InstallerID
   FROM webCAMS.dbo.tblUser
  WHERE UserID = @UserID

 --cache FSP children
 SELECT * INTO #myLoc
   FROM dbo.fnGetLocationChildrenExt(@FSPID)

 --retrieve resultset
 IF Len(@JobID) = 11
  BEGIN
	--it is a call
	IF EXISTS(SELECT 1 FROM Call_History j JOIN #myLoc l ON j.AssignedTo = l.Location
				WHERE j.CallNumber = CAST(@JobID as varchar))
	 BEGIN
		SELECT j.Serial,
			ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '') as Device,
			s.StockReturnType as StockReturned,
			j.StockReturnedDateTime as ReturnedDate,
			ISNULL(CAST(e.Location as varchar(10)), 'UNKNOWN')  as Location,
			ISNULL(dbo.fnParseFSPStockCondition(e.Condition), 'UNKNOWN')  as Status,
			ISNULL(CAST(e.LastLocation as varchar(10)), 'UNKNOWN')  as LastLocation
		  FROM Call_Equipment_History j JOIN M_M_D m ON j.MMD_ID = m.MMD_ID
						JOIN tblStockReturnType s ON j.StockReturnTypeID = s.StockReturnTypeID
						LEFT OUTER JOIN Equipment_Inventory e ON j.Serial = e.Serial AND j.MMD_ID = e.MMD_ID
		  WHERE j.CallNumber = CAST(@JobID as varchar)
			AND dbo.fnIsSerialisedDevice(j.Serial) = 1
	 END
  END
 ELSE
  BEGIN
	--it is an IMS Job
	IF EXISTS(SELECT 1 FROM IMS_Jobs_History j JOIN #myLoc l ON j.BookedInstaller = l.Location
				WHERE j.JobID = @JobID)
	 BEGIN
		SELECT j.Serial,
			ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '') as Device,
			s.StockReturnType as StockReturned,
			j.StockReturnedDateTime as ReturnedDate,
			ISNULL(CAST(e.Location as varchar(10)), 'UNKNOWN')  as Location,
			ISNULL(dbo.fnParseFSPStockCondition(e.Condition), 'UNKNOWN')  as Status,
			ISNULL(CAST(e.LastLocation as varchar(10)), 'UNKNOWN')  as LastLocation
		  FROM IMS_Job_Equipment_History j JOIN M_M_D m ON j.MMD_ID = m.MMD_ID
						JOIN tblStockReturnType s ON j.StockReturnTypeID = s.StockReturnTypeID
						LEFT OUTER JOIN Equipment_Inventory e ON j.Serial = e.Serial AND j.MMD_ID = e.MMD_ID
		 WHERE j.JobID = @JobID
			AND dbo.fnIsSerialisedDevice(j.Serial) = 1
			AND j.ActionID = 2 --'REMOVE'
	 END
  END

/*

EXEC spWebGetFSPJobEquipmentHistory @UserID = 199805, @JobID = 418918

*/

GO

grant exec on spWebGetFSPJobEquipmentHistory to CALLSYSUSERS, eCAMS_Role
go


use webCAMS
go

Alter proc spWebGetFSPJobEquipmentHistory (
	@UserID int,
	@JobID bigint)
as
 EXEC CAMS.dbo.spWebGetFSPJobEquipmentHistory @UserID = @UserID, @JobID = @JobID

go

grant exec on spWebGetFSPJobEquipmentHistory to eCAMS_Role
go

			
	
