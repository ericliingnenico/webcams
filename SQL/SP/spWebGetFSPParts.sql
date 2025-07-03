Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPParts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetFSPParts]
GO


Create Procedure dbo.spWebGetFSPParts 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 18 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 10/10/11 18:01 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPParts.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetFSPParts @UserID = @UserID, @JobID = @JobID
/*
spWebGetFSPParts 199663, 20050303172
spWebGetFSPParts 199663, 505646

312691
*/
Go

Grant EXEC on spWebGetFSPParts to eCAMS_Role
Go

Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetFSPParts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetFSPParts]
GO


Create Procedure dbo.spWebGetFSPParts 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/03/03 17:02 $-->
--<!--$$Logfile: /eCAMSSource/eCAMS/SQL/SP/spWebGetFSPParts.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Get Job Equipment
 DECLARE 
	@Location int,
	@JobFSP int,
	@ClientID varchar(3),
	@DeviceType	varchar(40),
	@JobTypeID tinyint
	

 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID


 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)


 --create temp table 
 SELECT PartID = PartID,
		Device = PartDescription
	into #Parts
	FROM vwIMSPart
	where 1 = 2
 
 IF LEN(@JobID) = 11
  BEGIN
	--get call info
	SELECT @JobFSP = AssignedTo,
			@ClientID = ClientID,
			@DeviceType = CallType,
			@JobTypeID = 4
	  FROM vwCalls
	 WHERE CallNumber = @JobID



  END
 ELSE
  BEGIN
	SELECT @JobFSP = BookedInstaller,
			@ClientID = ClientID,
			@DeviceType = DeviceType,
			@JobTypeID = JobTypeID
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

  END

 --verify the job is belong to this user
 IF EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
   BEGIN
	if @JobTypeID = 3
	 begin
		  insert #Parts (PartID, Device)
			select distinct PartID = PartID,
				Device = PartDescription
				from tblJobMMDPartDefault jp join vwIMSPart p on jp.MMD=p.PartID
				where jp.DefaultType = 'P' 
						and jp.DeviceType = @DeviceType 
						and jp.ClientID = @ClientID 
						and JobTypeID in (1,2)
				order by PartDescription
	 end
	else
	 begin
		  insert #Parts (PartID, Device)
			select distinct PartID = PartID,
				Device = PartDescription
				from tblJobMMDPartDefault jp join vwIMSPart p on jp.MMD=p.PartID
				where jp.DefaultType = 'P' 
						and jp.DeviceType = @DeviceType 
						and jp.ClientID = @ClientID 
						and JobTypeID = @JobTypeID
				order by PartDescription
	 end

	if @@ROWCOUNT = 0
	 begin
	  insert #Parts (PartID, Device)
		SELECT PartID = PartID,
			Device = PartDescription
			FROM vwIMSPart
			WHERE ClientID = @ClientID AND IsActive = 1 and IsLoosePart=1
			order by PartDescription
	 end 
   END

 --return
 select * from #Parts
/*
dbo.spWebGetFSPParts 
		@UserID =199649,
		@JobID =1362795

*/

GO
Grant EXEC on spWebGetFSPParts to eCAMS_Role
Go

