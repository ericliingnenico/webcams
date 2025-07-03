use CAMS
go

if exists(select 1 from sysobjects where name = 'spWebGetFSPPartTran')
	drop proc spWebGetFSPPartTran
Go


Create proc spWebGetFSPPartTran (
	@UserID int)
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/05/11 11:43 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPPartTran.sql $-->
--<!--$$NoKeywords: $-->
as
--Purpose: Get FSP Part In Tran
DECLARE @FSPID int
 SET NOCOUNT ON

 SELECT @FSPID = InstallerID
   FROM webCAMS.dbo.tblUser
  WHERE UserID = @UserID

 --cache FSP and its children
-- SELECT * INTO #MyLoc
--	FROM dbo.fnGetLocationChildrenExt(@FSPID)


 --return resultset
 SELECT t.RequestID,
	p.PartNo,
	p.Description,
	t.Location AS [From],
	t.ToLocation AS [To],
	t.QtyIssued AS Qty,
	t.StatusDateTime as DespatchedDateTime,
	'<INPUT type="checkbox" name="chkBulk"  value="' + cast(t.RequestID as varchar) + '" onclick="highlightRowViaCheckBox(this, ''#fff4c2'')">' as AcknowledgeReceived,
	'<INPUT type="textbox" id="txtQtyReceived' + cast(t.RequestID as varchar) + '" name="txtQtyReceived' + cast(t.RequestID as varchar) + '" size=8 value="' + cast(t.QtyIssued as varchar) + '">' AS QtyReceived
   FROM tblPartRequest t JOIN tblPart p ON t.PartID = p.PartID
  WHERE t.ToLocation = @FSPID 
		AND t.QtyIssued > 0
		and t.StatusID = 13 --Despatched



/*
exec spWebGetFSPPartTran @UserID = 199805

select * from tblFSPCJFPreJob

*/
Go

grant EXEC on spWebGetFSPPartTran to CallSysUsers, eCAMS_Role
go


use webCAMS
go


if exists(select 1 from sysobjects where name = 'spWebGetFSPPartTran')
	drop proc spWebGetFSPPartTran
Go


Create proc spWebGetFSPPartTran (
	@UserID int)
as
 EXEC CAMS.dbo.spWebGetFSPPartTran @UserID= @UserID

GO

grant EXEC on spWebGetFSPPartTran to eCAMS_Role
go
