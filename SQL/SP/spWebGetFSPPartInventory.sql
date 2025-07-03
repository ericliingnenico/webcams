use CAMS
go

--if exists(select 1 from sysobjects where name = 'spWebGetFSPPartInventory')
--	drop proc spWebGetFSPPartInventory
--Go

Alter proc spWebGetFSPPartInventory (
	@UserID int,
	@Mode int)
--<!--$$Revision: 28 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/10/16 14:56 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetFSPPartInventory.sql $-->
--<!--$$NoKeywords: $-->
as
--Purpose: Get FSP Part Inventory
-- Mode: 1- for stock take
--		 2 - for parts ordering
---28/10/2011 Temp logic for CBA weekend stock 
---23/08/2013 Added PartOrder & PartInTransit
DECLARE @FSPID int
 SET NOCOUNT ON

 SELECT @FSPID = InstallerID
   FROM webCAMS.dbo.tblUser
  WHERE UserID = @UserID

 --cache FSP and its children
-- SELECT * INTO #MyLoc
--	FROM dbo.fnGetLocationChildrenExt(@FSPID)
 --return resultset
 
 if @Mode = 2
  begin
	 SELECT i.Location,
		PartID = i.PartNo, 
		PartDescription = i.[Description],
		SupplierPartNo = i.SupplierPartNo,
		i.QtyOnHand,
		QtyInTransit = (select SUM(QtyIssued) from tblPartRequest where StatusID = 13 and PartID = i.PartID and ToLocation = i.Location),
		QtyOnOrder = (select SUM(QtyRequired) from tblPartRequest where StatusID = 1 and PartID = i.PartID and ToLocation = i.Location),
		'<INPUT type="hidden" name="txtPartID" value="' + i.PartNo + '"><INPUT type="textbox" name="txtQtyOnHand" size=8 value="0">' AS QtyOrder,
		(SELECT MAX(LoggedDateTime) FROM tblPartMovementLog WHERE MovementID = 34 AND PartID = i.PartID AND [Location] = ABS(LoggedBy)) as FSPLastUpdated
	   FROM vwPartInventory i 
	  WHERE i.Location = @FSPID
		and i.IsInventoryActive = 1
	  ORDER BY i.[Description]
  end
 else
  begin
	 SELECT i.Location,
		i.PartID,
		p.PartDescription,
		SupplierPartNo = i.SupplierPartNo,
		i.QtyOnHand as OldQtyOnHand,
		'<INPUT type="hidden" name="txtPartID" value="' + i.PartID + '"><INPUT type="textbox" name="txtQtyOnHand" size=8 value="' + cast(i.QtyOnHand as varchar) + '">' AS NewQtyOnHand,
		(SELECT MAX(LoggedDateTime) FROM tblPartMovementLog WHERE MovementID = 34 AND PartID = part.PartID AND [Location] = ABS(LoggedBy)) as FSPLastUpdated
	   FROM vwIMSPartInventory i JOIN vwIMSPart p ON i.PartID = p.PartID 
	   JOIN tblPart part on part.PartNo = p.PartID
	  WHERE i.Location = @FSPID
	 -- and i.PartID in (
	 -- --stock take 2015-06-10
		--'CBX13','CBC27','CBC28','CBP07','CBA04','CBX28','CBP13','CBC36','CBC37','CBX18','CBC33','CBC34','CBX20','CBIMP','CC797','CC683','CC803','CC781','CC785',
		--'CC999', 'CC766', 'C4095'
	 -- )
	  ORDER BY p.PartDescription
  end
 
/*
exec spWebGetFSPPartInventory @UserID = 199623, @Mode = 2

*/
Go

--grant EXEC on spWebGetFSPPartInventory to CallSysUsers, eCAMS_Role
go


use webCAMS
go


--if exists(select 1 from sysobjects where name = 'spWebGetFSPPartInventory')
--	drop proc spWebGetFSPPartInventory
--Go


Alter proc spWebGetFSPPartInventory (
	@UserID int,
	@Mode int)
as
 EXEC CAMS.dbo.spWebGetFSPPartInventory @UserID= @UserID,
										@Mode = @Mode

GO

--grant EXEC on spWebGetFSPPartInventory to eCAMS_Role
go
