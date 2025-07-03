Use CAMS
Go

Alter proc spPDAGetIMSPart 
--<!--$$Revision: 7 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/06/11 10:34 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetIMSPart.sql $-->
--<!--$$NoKeywords: $-->
as
--retrieve MMD data for caching at PDA
 
 SET NOCOUNT ON

 --get Survey version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'IMSPartVersion'

 --M_M_D
 SELECT 
	A = PartID,
	B = left(PartDescription, 50)
   FROM vwIMSPart 
  where IsActive = 1

go
Grant EXEC on spPDAGetIMSPart to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spPDAGetIMSPart 
 AS
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetIMSPart
/*
spPDAGetIMSPart
*/
Go

Grant EXEC on spPDAGetIMSPart to eCAMS_Role
Go
