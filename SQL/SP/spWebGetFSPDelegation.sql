use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPDelegation' and type = 'p')
	drop proc spWebGetFSPDelegation
go

create proc spWebGetFSPDelegation (
	@UserID int,
	@LogID int)
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/02/14 15:26 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPDelegation.sql $-->
--<!--$$NoKeywords: $-->
as
 DECLARE @FSPID int,
		@IsFSPAdmin bit

 set @IsFSPAdmin = 0
 
 SELECT @FSPID = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 if exists(select * from webcams.dbo.tblUserModule where ModuleID = 2 and UserID = @UserID)
  begin
	set @IsFSPAdmin = 1
  end

 if @IsFSPAdmin = 1
  begin
	 SELECT fd.*
	   FROM tblFSPDelegation fd
	  WHERE fd.LogID = @LogID
  end
 else
  begin
	 SELECT fd.*
	   FROM tblFSPDelegation fd
	  WHERE fd.FSP in  (select Location from dbo.fngetLocationChildrenExt(@FSPID))
		and fd.LogID = @LogID
  end

/*
 EXEC spWebGetFSPDelegation @UserID = 199649, @LogID = 15
 EXEC spWebGetFSPDelegation @UserID = 199649, @LogID = 613

*/
go

grant exec on spWebGetFSPDelegation to CALLSYSUSERS, eCAMS_Role
go


use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPDelegation' and type = 'p')
	drop proc spWebGetFSPDelegation
go

create proc spWebGetFSPDelegation(
	@UserID int,
	@LogID int)
as
 EXEC CAMS.dbo.spWebGetFSPDelegation @UserID = @UserID, @LogID = @LogID
go

grant exec on spWebGetFSPDelegation to eCAMS_Role
go
