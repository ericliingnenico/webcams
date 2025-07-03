Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebGetJobFSPDownload]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spWebGetJobFSPDownload]
GO


Create Procedure dbo.spWebGetJobFSPDownload 
	(
		@UserID int,
		@JobID bigint,
		@From tinyint
	)
	AS
--<!--$$Revision: 2 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 16/09/13 11:13 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebGetJobFSPDownload.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: 
	Get List of KB Document related to a job
	@From : 1 - From Web, 2 - From Mobile Device
*/
 SET NOCOUNT ON
 declare @EquipmentCode varchar(10)

 --validate user
 --only show the Bulletin for the FSP web users
 IF EXISTS(SELECT 1 FROM tblUser WHERE UserID = @UserID AND IsActive = 1 and ISNULL(InstallerID,0) <>0)
  begin
	if LEN(@JobID) = 11
	 begin
		select @EquipmentCode = EquipmentCodes
			from CAMS.dbo.Calls with (nolock)
			where CallNumber = CAST(@JobID as varchar)
	 end
	else
	 begin
		select @EquipmentCode = de.EquipmentCode
			from CAMS.dbo.ims_jobs jb with (nolock)  join CAMS.dbo.tblDefaultMaintAndEqCode de with (nolock) on de.ClientID = jb.ClientID 
													and de.DeviceType = jb.DeviceType
			where jb.JobID = @JobID
	 
	 end
 end


 if @From = 2
  BEGIN
	 SELECT 
		dl.Seq,
		dl.DownloadDescription as [Description],
		FileType = dbo.fnGetFileExtension(dl.DownloadURL),
		dl.FileSize,
		dl.UpdateDateTime as EffectiveDate
	  FROM tblDeviceDownload dd join tblDownload dl on dd.Seq = dl.Seq
	  WHERE dd.EquipmentCode = @EquipmentCode
		and  dl.IsActive = 1
	  Order By dl.DownloadDescription
  END
 ELSE
  --only get one download details
  BEGIN
	 SELECT 
		dl.DownloadDescription as [Description],
		'<A HREF="../Member/FSPDownload.aspx?DLID=' + CAST(dl.Seq as varchar) + '">' + case when dl.DownloadCategoryID = 16 then 'View' else 'Download' end + '</A>' as [Action],
		FileType = dbo.fnGetFileExtension(dl.DownloadURL),
		dl.FileSize,
		dl.UpdateDateTime as EffectiveDate
	  FROM tblDeviceDownload dd join tblDownload dl on dd.Seq = dl.Seq
	  WHERE dd.EquipmentCode = @EquipmentCode
		and  dl.IsActive = 1
	  Order By dl.DownloadDescription
   END

/*

exec spWebGetJobFSPDownload @UserID=199649,@JobID = 1586542, @From = 1

exec spWebGetJobFSPDownload @UserID=199649,@JobID = 1586542, @From = 2

exec spWebGetJobFSPDownload @UserID=199649,@JobID =20130521720, @From = 1

exec spWebGetJobFSPDownload @UserID=199649,@JobID =20130521720, @From = 2

exec spWebGetJobFSPDownload @UserID=19964977,@JobID =20130521720, @From = 2

*/
Go

Grant EXEC on spWebGetJobFSPDownload to eCAMS_Role
Go





