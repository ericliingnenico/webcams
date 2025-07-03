
Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetJobExceptionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetJobExceptionList]
GO

CREATE Procedure dbo.spWebGetJobExceptionList 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 1 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 28/10/05 2:18p $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobExceptionList.sql $-->
--<!--$$NoKeywords: $-->
---Get job exception list

 SELECT p.PDASerial, 
	p.PDAMMD_ID,
	ISNULL(m.Maker, '') + ' ' + ISNULL(m.Model, '') + ' ' + ISNULL(m.Device, '') as Device,
	t.Type
   FROM tblPDAException p JOIN tblPDAExceptionType t ON p.TypeID = t.TypeID
			LEFT OUTER JOIN M_M_D m ON p.PDAMMD_ID = m.MMD_ID
  WHERE p.JobID = @JobID


GO

Grant EXEC on spWebGetJobExceptionList to eCAMS_Role
Go

Use WebCAMS
Go


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetJobExceptionList]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebGetJobExceptionList]
GO


Create Procedure dbo.spWebGetJobExceptionList 
	(
		@UserID int,
		@JobID bigint
	)
	AS
--<!--$$Revision: 8 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 15/06/04 11:41a $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobExceptionList.sql $-->
--<!--$$NoKeywords: $-->
 SET NOCOUNT ON
 EXEC Cams.dbo.spWebGetJobExceptionList 
			@UserID = @UserID, 
			@JobID = @JobID

/*
select * from webcams.dbo.tblUser

spWebGetJobExceptionList 199512, 399940
*/
Go

Grant EXEC on spWebGetJobExceptionList to eCAMS_Role
Go
