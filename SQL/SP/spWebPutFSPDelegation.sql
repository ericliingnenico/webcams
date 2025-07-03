use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebPutFSPDelegation' and type = 'p')
	drop proc spWebPutFSPDelegation
go


create proc spWebPutFSPDelegation (
	@UserID int,
	@FSP int,
	@FromDate datetime,
	@ToDate datetime,
	@AssignToFSP int,
	@Note varchar(400),
	@ReasonID smallint,
	@StatusID smallint,
	@LogID int OUTPUT)
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 19/03/14 14:16 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutFSPDelegation.sql $-->
--<!--$$NoKeywords: $-->
as
 declare @FSPID int,
	@ret int,
	@IsFSPAdmin bit

 --init
 SET NOCOUNT ON

 set @IsFSPAdmin = 0

 if exists(select * from webcams.dbo.tblUserModule where ModuleID = 2 and UserID = @UserID)
  begin
	set @IsFSPAdmin = 1
  end	

 select @ret = 0,
	@LogID = case when @LogID < 0 then null else @LogID end

 SELECT @FSPID = InstallerID 
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID


SELECT Location into #FSPFamily
 FROM dbo.fnGetLocationFamily(@FSPID)


 --validation
 if @FSP = @AssignToFSP
  begin
	raiserror ('Error - Invalid AssignToFSP. Aborted',16,1)
	GOTO Exit_Handle
  end

 if @FromDate >= @ToDate
  begin
	raiserror ('Error - Invalid FromDate & ToDate. Aborted',16,1)
	GOTO Exit_Handle
  end

 if cast(@FromDate as date) < cast(GETDATE() as date)
  begin
	raiserror ('Error - Invalid FromDate (must be current/future date) . Aborted',16,1)
	GOTO Exit_Handle
  end
 
 if @FSP is null
	or NOT EXISTS(SELECT 1 FROM #FSPFamily where Location=@FSP)
  begin
	raiserror ('Error - Invalid FSP. Aborted',16,1)
	GOTO Exit_Handle
  end

 if @AssignToFSP is not null
	and @AssignToFSP not in (328, -1)
	and NOT EXISTS(SELECT 1 FROM #FSPFamily where Location=@AssignToFSP)
  begin
	raiserror ('Error - Invalid AssignToFSP. Aborted',16,1)
	GOTO Exit_Handle
  end

 --verify if single depot and FSP Not Available must be marked 72 hours earlier
 if not exists(select COUNT(*) from #FSPFamily having COUNT(*)>1)
	and @AssignToFSP is null
	and datediff(hour,getdate(), @FromDate) < 72
	and @IsFSPAdmin = 0
  begin
	raiserror ('Error - FSP-unavailable must be booked 72 hours in advance. Aborted',16,1)
	GOTO Exit_Handle
  end

 if @LogID is not null
	and NOT EXISTS(SELECT 1 FROM tblFSPDelegation where LogID = @LogID and FSP in (select Location from #FSPFamily))
  begin
	raiserror ('Error - Invalid FSP. Aborted',16,1)
	GOTO Exit_Handle
  end

 --process
 if @LogID is not null
  begin
	update tblFSPDelegation
		set FSP = @FSP,
			FromDate = @FromDate,
			ToDate = @ToDate,
			AssignToFSP = @AssignToFSP,
			Note = @Note,
			ReasonID = @ReasonID,
			StatusID = @StatusID,
			LoggedBy = @UserID,
			LoggedDateTime = GETDATE()
		where LogID = @LogID
  end
 else
  begin
	insert tblFSPDelegation (FSP, FromDate, ToDate,AssignToFSP, Note, ReasonID, StatusID, LoggedBy, LoggedDateTime)
		select @FSP, @FromDate, @ToDate, @AssignToFSP, @Note, @ReasonID, @StatusID, @UserID, GETDATE()

	select @LogID = IDENT_CURRENT('tblFSPDelegation')
		
  end
 
Exit_Handle:
 RETURN @ret

/*
declare @CJFID int
 EXEC spWebPutFSPDelegation @UserID = 199805,

*/

Go

GRANT EXEC ON spWebPutFSPDelegation TO CALLSYSUSERS, eCAMS_Role
go

use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebPutFSPDelegation' and type = 'p')
	drop proc spWebPutFSPDelegation
go

create proc spWebPutFSPDelegation (
	@UserID int,
	@FSP int,
	@FromDate datetime,
	@ToDate datetime,
	@AssignToFSP int,
	@Note varchar(400),
	@ReasonID smallint,
	@StatusID smallint,
	@LogID int OUTPUT)
as
DECLARE @ret int
 SET NOCOUNT ON
 EXEC @ret = CAMS.dbo.spWebPutFSPDelegation @UserID = @UserID,
				@FSP = @FSP,
				@FromDate = @FromDate,
				@ToDate = @ToDate,
				@AssignToFSP = @AssignToFSP,
				@Note = @Note,
				@ReasonID = @ReasonID,
				@StatusID = @StatusID,
				@LogID = @LogID OUTPUT

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret
Go

GRANT EXEC ON spWebPutFSPDelegation TO eCAMS_Role
go



