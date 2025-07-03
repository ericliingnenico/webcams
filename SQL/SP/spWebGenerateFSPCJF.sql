use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebGenerateFSPCJF' and type = 'p')
	drop proc spWebGenerateFSPCJF
go

create proc spWebGenerateFSPCJF (
	@UserID int,
	@CJFFileName varchar(100),
	@LogIDs varchar(8000),
	@CJFID int OUTPUT)
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 1/02/06 3:38p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGenerateFSPCJF.sql $-->
--<!--$$NoKeywords: $-->
as
 declare @FSPID int,
	@ret int

 --init
 SET NOCOUNT ON
 SET @ret = 0

 SELECT @FSPID = InstallerID 
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID


 --cache LogIDs
 SELECT * INTO #myLogID
   FROM dbo.fnConvertListToTable(@LogIDs)


 --No matching records, quit
 IF NOT EXISTS(SELECT 1 FROM tblFSPCJFPreJob j JOIN #myLogID l on j.LogID = l.f)
	GOTO Exit_Handle

 --Start Transaction
 DECLARE @bInCallerTransaction bit
 SET @bInCallerTransaction = @@TRANCOUNT
 IF @bInCallerTransaction = 0
	BEGIN TRAN


 --create CJF file record
 INSERT tblFSPCJF (CJFFileName, FSPID, CreatedDateTime)
	Values (@CJFFileName, @FSPID, GETDATE())
 
 SELECT @ret = @@ERROR
 IF @ret <> 0
	GOTO RollBack_Handle

 --get CJFID
 SELECT @CJFID = IDENT_CURRENT('tblFSPCJF')

 SELECT @ret = @@ERROR
 IF @ret <> 0 
	GOTO RollBack_Handle

 
 --bring over jobs from tblFSPCJFPreJob
 INSERT tblFSPCJFJob (CJFID,
		SourceID,
		JobID,
		FSPID)
  SELECT @CJFID,
	j.SourceID,
	j.JobID,
	j.FSPID
   FROM tblFSPCJFPreJob j JOIN #myLogID l on j.LogID = l.f


 SELECT @ret = @@ERROR
 IF @ret <> 0
	GOTO RollBack_Handle

 --delete jobs from tblFSPCJFPreJob
 DELETE j
   FROM tblFSPCJFPreJob j JOIN #myLogID l on j.LogID = l.f

 SELECT @ret = @@ERROR
 IF @ret <> 0
	GOTO RollBack_Handle

 --Commit
 IF @bInCallerTransaction = 0
	COMMIT TRAN

Exit_Handle:
 RETURN @ret

RollBack_Handle:
 IF @bInCallerTransaction = 0
	ROLLBACK TRAN

 GOTO Exit_Handle

/*
declare @CJFID int
 EXEC spWebGenerateFSPCJF @UserID = 199805,
			@CJFFileName = '3000-20060130',
			@LogIDs = '8,9',
			@CJFID = @CJFID OUTPUT

select * from cams.dbo.tblFSPCJFPreJob

select * from cams.dbo.tblFSPCJF

select * from cams.dbo.tblFSPCJFJob

*/

Go

GRANT EXEC ON spWebGenerateFSPCJF TO CALLSYSUSERS, eCAMS_Role
go

use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGenerateFSPCJF' and type = 'p')
	drop proc spWebGenerateFSPCJF
go

create proc spWebGenerateFSPCJF (
	@UserID int,
	@CJFFileName varchar(100),
	@LogIDs varchar(8000),
	@CJFID int OUTPUT)
as
DECLARE @ret int
 SET NOCOUNT ON
 EXEC @ret = CAMS.dbo.spWebGenerateFSPCJF @UserID = @UserID,
				@CJFFileName = @CJFFileName,
				@LogIDs = @LogIDs,
				@CJFID = @CJFID OUTPUT


 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
Go

GRANT EXEC ON spWebGenerateFSPCJF TO eCAMS_Role
go



