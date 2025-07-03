use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebCancelFSPDelegation' and type = 'p')
	drop proc spWebCancelFSPDelegation
go

create proc spWebCancelFSPDelegation (
	@UserID int,
	@LogID int)
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 14/02/14 15:34 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebCancelFSPDelegation.sql $-->
--<!--$$NoKeywords: $-->
as
 DECLARE @FSPID int,
		@IsFSPAdmin bit

 set @IsFSPAdmin = 0
 
 SELECT @FSPID = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 
 update tblFSPDelegation
  set StatusID = 4 --Cancelled
  WHERE FSP in (select * from dbo.fnGetLocationChildrenExt( @FSPID))
	and LogID = @LogID

 
/*
 EXEC spWebCancelFSPDelegation @UserID = 199649, @LogID = 2
 EXEC spWebCancelFSPDelegation @UserID = 199649, @LogID = 613

*/
go

grant exec on spWebCancelFSPDelegation to CALLSYSUSERS, eCAMS_Role
go


use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebCancelFSPDelegation' and type = 'p')
	drop proc spWebCancelFSPDelegation
go

create proc spWebCancelFSPDelegation(
	@UserID int,
	@LogID int)
as
 declare @ret int
 EXEC @ret = CAMS.dbo.spWebCancelFSPDelegation @UserID = @UserID, @LogID = @LogID

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar
 RETURN @ret 
go

grant exec on spWebCancelFSPDelegation to eCAMS_Role
go
