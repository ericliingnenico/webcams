use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPDelegationList' and type = 'p')
	drop proc spWebGetFSPDelegationList
go

create proc spWebGetFSPDelegationList (
	@UserID int,
	@From tinyint,
	@FromDate datetime = null)
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 6/03/14 13:52 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPDelegationList.sql $-->
--<!--$$NoKeywords: $-->
as
 DECLARE @FSPID int,
		@HRef varchar(200),
		@IsFSPAdmin bit

 set @IsFSPAdmin = 0
 
 if exists(select * from webcams.dbo.tblUserModule where ModuleID = 2 and UserID = @UserID)
  begin
	set @IsFSPAdmin = 1
  end

 SELECT @FSPID = InstallerID
   FROM WebCAMS.dbo.tblUser
  WHERE UserID = @UserID



SELECT Location into #FSPChildren
 FROM dbo.fnGetLocationChildrenExt(@FSPID)

 select @FromDate = ISNULL(@FromDate, CAST(getdate() as DATE))
 select @HRef = case when @From = 1 then '<A HREF=''../member/FSPDelegation.aspx?id=' else '<A HREF=''../member/mpFSPDelegation.aspx?id=' end

 SELECT fd.FSP,	
		fd.FromDate,
		fd.ToDate,
		fd.AssignToFSP,
		fr.Reason,
		[Status] = case when fd.statusid = 4 then '<div style="color:Red">' else '' end + fs.[Status] + case when fd.statusid = 4 then '</div>' else '' end,
		fd.Note,
		[Action] = case when fd.FSP in (SELECT Location FROM #FSPChildren) 
								and (fd.AssignToFSP in (SELECT Location FROM #FSPChildren) 
										or fd.AssignToFSP is null
										or (@IsFSPAdmin = 1 and fd.AssignToFSP in (328, -1))
										)
								 then @HRef + cast(fd.LogID as varchar) + '''>Edit</A>' 
						else '' end,
		[UpdatedBy] = u.EmailAddress						
   FROM tblFSPDelegation fd JOIN tblFSPDelegationReason fr ON fd.ReasonID = fr.ReasonID
							join tblFSPDelegationStatus fs on fd.StatusID = fs.StatusID
							join webcams.dbo.tblUser u on fd.LoggedBy = u.UserID
  WHERE (fd.FSP in (SELECT Location FROM #FSPChildren)
			or fd.AssignToFSP in (SELECT Location FROM #FSPChildren))
	and (fd.FromDate>=@FromDate or fd.ToDate>=@FromDate)
  ORDER BY fd.FromDate

/*

 EXEC spWebGetFSPDelegationList @UserID = 199649, @From = 1, @FromDate='2013-11-27'

 EXEC spWebGetFSPDelegationList @UserID = 199649, @From = 2

*/
go

grant exec on spWebGetFSPDelegationList to CALLSYSUSERS, eCAMS_Role
go


use webCAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPDelegationList' and type = 'p')
	drop proc spWebGetFSPDelegationList
go

create proc spWebGetFSPDelegationList(
	@UserID int,
	@From tinyint,
	@FromDate datetime=null)
as
 EXEC CAMS.dbo.spWebGetFSPDelegationList @UserID = @UserID, @From = @From, @FromDate = @FromDate
go

grant exec on spWebGetFSPDelegationList to eCAMS_Role
go
