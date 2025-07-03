Use WebCAMS
Go

Alter Procedure dbo.spWebGetDownloadsByURL 
(
	@DownloadURL varchar(500)
)
AS
--<!--$Author: Bo Li <bo.li@bambora.com>$-->
--<!--$Created: 2017-02-02 16:00:32$-->
--<!--$Modified: 2018-11-17 15:48:43$-->
--<!--$ModifiedBy: Andrew Falzon <andrew.falzon@bambora.com>$-->
--<!--$Comment: CAMS-776 Added functionality for archiving and unarchiving files. Additionally, cleaned up and refactored code.$-->
--<!--$Commit$-->

SET NOCOUNT ON

SELECT d.Seq, d.DownloadCategoryID, dc.CategoryName, d.DownloadDescription, d.DownloadURL, d.IsActive
FROM tblDownload d
INNER JOIN tblDownloadCategory dc on dc.DownloadCategoryID = d.DownloadCategoryID
WHERE DownloadURL = @DownloadURL

GO

Grant EXEC on spWebGetDownloadsByURL to eCAMS_Role
Go


