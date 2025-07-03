
Use CAMS
Go

Alter proc spPDAGetTechFix 
--<!--$$Revision: 3 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 24/10/06 10:52a $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAGetTechFix.sql $-->
--<!--$$NoKeywords: $-->
as
--retrieve TechFix related data
 
 SET NOCOUNT ON

 --get TechFix version
 SELECT A = AttrValue
   FROM CAMS.dbo.tblControl
  WHERE Attribute = 'TechFixVersion'

 --tblTechFix
 SELECT 
	A = t.JobType,
	B = l.TechFixID,
	C = f.TechFix,
	D = l.TechFixActionID,
	E = l.DisplayOrder
   FROM tblTechFixList l JOIN tblTechFix f ON l.TechFixID = f.TechFixID 
			JOIN vwJobType t ON l.JobTypeID = t.JobTypeID

go
Grant EXEC on spPDAGetTechFix to eCAMS_Role
Go

Use WebCAMS
Go

Alter Procedure dbo.spPDAGetTechFix 
 AS
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAGetTechFix
/*
spPDAGetTechFix
*/
Go

Grant EXEC on spPDAGetTechFix to eCAMS_Role
Go
