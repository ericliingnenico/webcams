Use CAMS
Go

Alter Procedure dbo.spPDAGetLookup 
	AS
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 3/03/06 2:14p $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetLookup.sql $-->
--<!--$$NoKeywords: $-->
--Purpose: get look up data for PDA
 SET NOCOUNT ON

 --get Survey version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'LookUpVersion'


 --tblPDAJobEquipmentUpdateReason
  SELECT 
	A = ReasonID,
	B = Reason
	
	FROM tblPDAJobEquipmentUpdateReason
	Order By Reason



GO

Grant EXEC on spPDAGetLookup to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spPDAGetLookup 
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 6/01/04 16:37 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetLookup.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetLookup
/*
spPDAGetLookup 
*/
Go

Grant EXEC on spPDAGetLookup to eCAMS_Role
Go
