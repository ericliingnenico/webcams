Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetSymptomFault]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetSymptomFault]
GO


Create Procedure dbo.spWebGetSymptomFault 
	(
		@UserID int,
		@SymptomID int
	)
	AS
--<!--$$Revision: 6 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 22/10/12 11:30 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetSymptomFault.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: Proxy sp at WebCAMS
*/
 SET NOCOUNT ON
 CREATE TABLE #tmpFault (Fault varchar(50) collate database_default, 
					FaultID int)

 --validate user
 IF EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1)
  BEGIN
 	INSERT INTO #tmpFault EXEC Cams.dbo.spGetSymptomFault @SymptomID = @SymptomID
 	--more selection, add empty one as default
 	if @@ROWCOUNT > 1
 	 begin
 		insert #tmpFault (Fault, FaultID) 
 			values ('',0)
 	 end

  END


  --return
  SELECT * 
	FROM #tmpFault 
	WHERE FaultID <> 2225
	ORDER BY Fault

/*
spWebGetSymptomFault 199635, 229

spWebGetSymptomFault 1, '1999100057E'
sp_help calls

select * from 


*/
Go

Grant EXEC on spWebGetSymptomFault to eCAMS_Role
Go

Use CAMS
Go

Grant EXEC on spGetSymptomFault to eCAMS_Role
Go




