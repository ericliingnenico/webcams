Use CAMS
Go

alter Procedure dbo.spPDAAddJobNotes 
	(
		@UserID int,
		@JobID bigint,
		@Notes varchar(255)
	)
	AS
--<!--$$Revision: 12 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 5/04/06 2:11p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAAddJobNotes.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: Add notes to ims jobs/calls
DECLARE @ret int,
	@Location int,
	@FSPOperatorNumber int


 --Get Location for the user
 SELECT @Location = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT @FSPOperatorNumber = -@Location

 --Add CRLF as prefix to Notes, and PDA stamp
 SELECT @Notes = CHAR(13) + CHAR(10) 
		+ @Notes 
		+ ' added at '
		+ convert(varchar(20), getdate(), 103) 
		+ ' by FSP[' 
		+ CAST(@Location as varchar)
		+ '] from PDA'
		+ char(13) + char(10)

 IF LEN(@JobID) = 11 
  --Swap Calls
  BEGIN
	--verify if the job is belong to this user
	IF EXISTS(SELECT 1 FROM Calls WHERE AssignedTo IN (SELECT * FROM dbo.fnGetLocationFamily(@Location)) AND CallNumber = @JobID)
		OR EXISTS(SELECT 1 FROM Call_History  WHERE AssignedTo IN (SELECT * FROM dbo.fnGetLocationFamily(@Location)) AND CallNumber = CAST(@JobID as varchar(11)))
	 BEGIN
		--append to CallMemo
		EXEC @ret = dbo.spAddNotesToCall
				@CallNumber = @JobID,
				@NewNotes = @Notes,
				@OperatorName = @FSPOperatorNumber
		--append to FaultMemo as well
		EXEC @ret = dbo.spAddFaultNotesToCall
				@CallNumber = @JobID,
				@NewNotes = @Notes,
				@OperatorName = @FSPOperatorNumber

	 END
  END
 ELSE
  --IMS Jobs
  BEGIN
	--verify if the job is belong to this user
	IF EXISTS(SELECT 1 FROM IMS_Jobs WHERE BookedInstaller IN (SELECT * FROM dbo.fnGetLocationFamily(@Location)) AND JobID = @JobID)
		OR EXISTS(SELECT 1 FROM IMS_Jobs_History WHERE BookedInstaller IN (SELECT * FROM dbo.fnGetLocationFamily(@Location)) AND JobID = @JobID)
	 BEGIN
		--append to Notes
		EXEC @ret = dbo.spAddNotesToIMSJob
				@JobID = @JobID,
				@NewNotes = @Notes,
				@OperatorName = @FSPOperatorNumber

		--append to InstallerNotes
		EXEC @ret = dbo.spAddInstallerNotesToIMSJob
				@JobID = @JobID,
				@NewNotes = @Notes,
				@OperatorName = @FSPOperatorNumber
	 END
  END


GO

Grant EXEC on spPDAAddJobNotes to eCAMS_Role
Go

Use WebCAMS
Go

alter Procedure dbo.spPDAAddJobNotes 
	(
		@UserID int,
		@JobID bigint,
		@Notes varchar(255)
	)
	AS
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 3/05/04 2:25p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAAddJobNotes.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAAddJobNotes @UserID = @UserID,
				@JobID = @JobID,
				@Notes = @Notes
/*
spPDAAddJobNotes 199516
*/
Go

Grant EXEC on spPDAAddJobNotes to eCAMS_Role
Go
