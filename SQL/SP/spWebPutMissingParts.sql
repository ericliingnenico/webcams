USE WebCAMS
GO

ALTER PROCEDURE dbo.spWebPutMissingParts 
(
	@JobID bigint,
	@PartsList varchar(500),
	@UserID int
)
AS
--<!--$Author$-->
--<!--$Created$-->
--<!--$Modified$-->
--<!--$ModifiedBy$-->
--<!--$Comment$-->
--<!--$Commit$-->

SET NOCOUNT ON

DECLARE @ret int = 0

INSERT INTO CAMS.dbo.tblJobPartsMissing (JobID, PartName, UserID, LoggedDateTime)
	SELECT @JobID, P.f, @UserID, GETDATE() FROM CAMS.dbo.fnConvertListToTable(@PartsList) P

SELECT @ret = @@ERROR

SELECT @ret
RETURN @ret

GO

Grant EXEC on spWebPutMissingParts to eCAMS_Role
GO


