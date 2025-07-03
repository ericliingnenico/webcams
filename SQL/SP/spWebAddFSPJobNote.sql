Use CAMS
Go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebAddFSPJobNote]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spWebAddFSPJobNote]
GO

create Procedure dbo.spWebAddFSPJobNote 
	(
		@UserID int,
		@JobID bigint,
		@Notes varchar(500)
	)
	AS
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/02/14 15:34 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebAddFSPJobNote.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: FSP add job note via web

DECLARE @ret int,
	@Location int,
	@JobFSP int,
	@JobExist bit,
	@JobNotes varchar(600),
	@FSPNotes varchar(600),
	@FSPOperatorNumber int,
	@JobIDString varchar(11)


 SET NOCOUNT ON


 --init
 SELECT @JobIDString = CAST(@JobID as varchar(11)),
	@ret = 0
	
 SELECT @Location = InstallerID FROM WebCAMS.dbo.tblUser WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@Location



 --cache Location Family
 SELECT * 
   INTO #myLocFamily
   FROM dbo.fnGetLocationFamilyExt(@Location)


 --validation
 IF rtrim(ISNULL(@Notes, '')) = ''
  BEGIN
	RAISERROR('No Job Notes specified. Abort', 16, 1, @JobIDString)
	SELECT @ret = -1
	GOTO Exit_Handle
  END

 IF dbo.fnIsSwapCall(@JobID) = 1
  --Swap Calls
  BEGIN
	--get call info
	SELECT @JobFSP = AssignedTo
	  FROM Calls
	 WHERE CallNumber = @JobID


	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

   END
 ELSE
   BEGIN
	SELECT @JobFSP = BookedInstaller
	  FROM IMS_Jobs 
 	 WHERE JobID = @JobID

	--set JobExist flag
	SELECT @JobExist = CASE WHEN @@ROWCOUNT = 1 THEN 1 ELSE 0 END

   END

 --verify the job is belong to this user
 IF NOT EXISTS(SELECT 1 FROM #myLocFamily WHERE Location = @JobFSP)
  BEGIN
	IF @JobExist = 1
	 BEGIN
		RAISERROR('Job [%s] is not assigned to FSP (%d) group. Abort', 16, 1, @JobIDString, @Location)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END
	ELSE
	 BEGIN
		RAISERROR('Job [%s] does not exist. Abort', 16, 1, @JobIDString)
		SELECT @ret = -1
		GOTO Exit_Handle
	 END

  END
  
  

 --process
 --add notes to fsp notes
 SELECT @JobNotes = dbo.fnCRLF() + 'FSP Added Notes: ' + @Notes  + dbo.fnGetOperatorStamp(@FSPOperatorNumber) + dbo.fnCRLF()
 SELECT @FSPNotes = dbo.fnCRLF() + 'FSP Added Notes: ' + @Notes  + dbo.fnGetOperatorStamp(@FSPOperatorNumber) + dbo.fnCRLF()

 if dbo.fnIsSwapCall(@JobID) = 1
  begin
	--append to CallMemo
	EXEC @ret = dbo.spAddNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @JobNotes ,
			@OperatorName = @FSPOperatorNumber
	--append to FaultMemo as well
	EXEC @ret = dbo.spAddFaultNotesToCall
			@CallNumber = @JobID,
			@NewNotes = @FSPNotes ,
			@OperatorName = @FSPOperatorNumber
	
  end
 else
  begin
	--append to Notes
	EXEC @ret = dbo.spAddNotesToIMSJob
			@JobID = @JobID,
			@NewNotes = @JobNotes ,
			@OperatorName = @FSPOperatorNumber

	--append to InstallerNotes
	EXEC @ret = dbo.spAddInstallerNotesToIMSJob
			@JobID = @JobID,
			@NewNotes = @FSPNotes ,
			@OperatorName = @FSPOperatorNumber
  end 


Exit_Handle:
  RETURN @ret
GO

Grant EXEC on spWebAddFSPJobNote to eCAMS_Role
Go

Use WebCAMS
Go
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spWebAddFSPJobNote]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spWebAddFSPJobNote]
GO

Create Procedure dbo.spWebAddFSPJobNote 
	(
		@UserID int,
		@JobID bigint,
		@Notes varchar(500)
	)
	AS
--<!--$$Revision: 19 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/06/04 3:50p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spWebAddFSPJobNote.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 DECLARE @ret int
 EXEC @ret = Cams.dbo.spWebAddFSPJobNote @UserID = @UserID,
		@JobID = @JobID,
		@Notes = @Notes

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret
/*

spWebAddFSPJobNote @UserID = 199516,
		@JobID = 221895,
		@Notes = 'test'

*/
Go

Grant EXEC on spWebAddFSPJobNote to eCAMS_Role
Go
