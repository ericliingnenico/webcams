Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPJobEquipment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetFSPJobEquipment]
GO


Create Procedure dbo.spWebGetFSPJobEquipment 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 20/09/11 14:52 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPJobEquipment.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPJobEquipment @UserID = @UserID, @JobID = @JobID
/*
spWebGetFSPJobEquipment 199663, 20050303172
spWebGetFSPJobEquipment 199663, 505646

312691
*/
Go

Grant EXEC on spWebGetFSPJobEquipment to eCAMS_Role
Go

Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPJobEquipment]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetFSPJobEquipment]
GO


Create Procedure dbo.spWebGetFSPJobEquipment 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/03/03 17:02 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetFSPJobEquipment.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get Job Equipment
 DECLARE 
	@Location int,
	@JobFSP int
	



 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID


 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)


 
 IF LEN(@JobID) = 11
  BEGIN
	--get call info
	SELECT @JobFSP = AssignedTo
	  FROM Calls
	 WHERE CallNumber = @JobID


	--verify the job is belong to this user
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN
		SELECT Keys = 'REMOVE^' + je.MMD_ID + '^' + je.Serial,
			[Action] = 'OUT',
			MMD_ID = je.MMD_ID,
			Serial = je.Serial,
			Device = m.Maker + ' ' + m.Model + ' ' + m.Device,
			Damaged = case when IsMerchantDamaged = 1 then 'Yes' else '' end,
			SW=je.SoftwareVersion,
			HW=je.HardwareRevision
			FROM Call_Equipment je JOIN M_M_D m ON je.MMD_ID = m.MMD_ID
			WHERE CallNumber = @JobID
		UNION
		SELECT Keys = 'INSTALL^' + je.NewMMD_ID + '^' + je.NewSerial,
			[Action] = 'IN',
			MMD_ID = je.NewMMD_ID,
			Serial = je.NewSerial,
			Device = m.Maker + ' ' + m.Model + ' ' + m.Device,
			Damaged = case when IsMerchantDamaged = 1 then 'Yes' else '' end,
			SW=je.NewSoftwareVersion,
			HW=je.NewHardwareRevision
			FROM Call_Equipment je JOIN M_M_D m ON je.MMD_ID = m.MMD_ID
			WHERE CallNumber = @JobID
		ORDER By [Action] DESC			

	 END

  END
 ELSE
  BEGIN
	SELECT @JobFSP = BookedInstaller
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	--verify the job is belong to this user
	IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
	 BEGIN
		 SELECT Keys = je.[Action] + '^' + je.MMD_ID + '^' + je.Serial,
			[Action] = CASE WHEN je.ActionID = 2 THEN 'OUT' ELSE 'IN' END,
			je.MMD_ID,
			je.Serial,
			Device = [Description],
			Damaged = case when IsMerchantDamaged = 1 and ActionID = 2 then 'Yes' else '' end,
			SW=ei.SoftwareVersion,
			HW=ei.HardwareRevision
			FROM vwIMSJobEquipment je left outer join Equipment_Inventory ei with (nolock) on je.Serial = ei.Serial and je.MMD_ID = ei.MMD_ID
			WHERE JobID = @JobID and ActionID = 1
		union
		 SELECT Keys = je.[Action] + '^' + je.MMD_ID + '^' + je.Serial,
			[Action] = CASE WHEN je.ActionID = 2 THEN 'OUT' ELSE 'IN' END,
			je.MMD_ID,
			je.Serial,
			Device = [Description],
			Damaged = case when IsMerchantDamaged = 1 and ActionID = 2 then 'Yes' else '' end,
			SW=ei.SoftwareVersion,
			HW=ei.HardwareRevision
			FROM vwIMSJobEquipment je left outer join Site_Equipment ei with (nolock) on je.Serial = ei.Serial and je.MMD_ID = ei.MMD_ID
			WHERE JobID = @JobID and ActionID = 2
					
		ORDER By [Action] DESC			
	 END
  END

GO
Grant EXEC on spWebGetFSPJobEquipment to eCAMS_Role
Go


