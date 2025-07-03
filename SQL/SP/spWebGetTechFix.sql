Use CAMS
Go


Alter Procedure dbo.spWebGetTechFix  
	(
		@JobType varchar(15)
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 24/10/06 3:20p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetTechFix.sql $-->
--<!--$$NoKeywords: $-->
SET NOCOUNT ON

SELECT tf.TechFixID,
	tf.TechFix
  FROM tblTechFixList fl
	  JOIN tblTechFix tf ON (tf.TechFixID = fl.TechFixID)
	  JOIN vwJobType jt ON jt.JobTypeID = fl.JobTypeID
  WHERE jt.JobType = @JobType AND tf.IsActive = 1
	
  ORDER BY fl.DisplayOrder

/*
EXEC spWebGetTechFix 'INSTALL'
EXEC spWebGetTechFix 'SWAP'
*/

GO

GRANT EXEC ON spWebGetTechFix to eCAMS_Role
Go

USE WebCAMS
Go

Alter proc spWebGetTechFix
	(
		@JobType varchar(15)
	)
as
SET NOCOUNT ON
EXEC CAMS.dbo.spWebGetTechFix @JobType = @JobType
Go

Grant Exec on spWebGetTechFix to eCAMS_Role
go

