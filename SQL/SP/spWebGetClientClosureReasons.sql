USE WebCAMS
GO

ALTER PROCEDURE dbo.spWebGetClientClosureReasons 
(
	@UserID int,
	@ClientID varchar(3),
	@JobType varchar(20),
	@FixID int
)
AS
--<!--$Author$-->
--<!--$Created$-->
--<!--$Modified$-->
--<!--$ModifiedBy$-->
--<!--$Comment$-->
--<!--$Commit$-->

SET NOCOUNT ON

SELECT * FROM CAMS.dbo.tblWebClientClosureReason CR
INNER JOIN CAMS.dbo.tblJobType J on J.JobTypeID = CR.JobTypeID
WHERE CR.ClientID = @ClientID and CR.FixID = @FixID and J.JobType = @JobType

GO

Grant EXEC on spWebGetClientClosureReasons to eCAMS_Role
GO


