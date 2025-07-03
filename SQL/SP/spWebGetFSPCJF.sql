use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPCJF' and type = 'p')
	drop proc spWebGetFSPCJF
go

create proc spWebGetFSPCJF (
	@UserID int)
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 1/02/06 3:38p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPCJF.sql $-->
--<!--$$NoKeywords: $-->
as
 DECLARE @FSPID int

 SELECT @FSPID = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID

 SELECT min(c.CJFFileName) as FileName,
	min(c.CreatedDateTime) as CreatedDateTime,
	count(cj.CJFID) as NumberOfJob,	
	'<A HREF=''../member/FSPCJFList.aspx?svr=download&id=' + cast(c.CJFID as varchar) + '&file=' + dbo.fnURLEncode(min(c.CJFFileName)) + '''>Download</A>' as Action
   FROM tblFSPCJF c JOIN tblFSPCJFJob cj ON c.CJFID = cj.CJFID
  WHERE c.FSPID = @FSPID
  GROUP BY c.CJFID
  ORDER BY c.CJFID DESC

/*
 EXEC spWebGetFSPCJF @UserID = 199805

*/
go

grant exec on spWebGetFSPCJF to CALLSYSUSERS, eCAMS_Role
go


use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPCJF' and type = 'p')
	drop proc spWebGetFSPCJF
go

create proc spWebGetFSPCJF(
	@UserID int)
as
 EXEC CAMS.dbo.spWebGetFSPCJF @UserID = @UserID
go

grant exec on spWebGetFSPCJF to eCAMS_Role
go
