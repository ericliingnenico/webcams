USE CAMS
GO

ALTER PROCEDURE dbo.spWebCloseDeinstallJob
(
		@UserID int,
		@JobID int,
		@FixID int,
		@Notes varchar(250)
)
AS
--<!--$Author$-->
--<!--$Created$-->
--<!--$Modified$-->
--<!--$ModifiedBy$-->
--<!--$Comment$-->
--<!--$Commit$-->

SET NOCOUNT ON

DECLARE @ret int = 0,
		@OnSiteDate datetime = GETDATE(),
		@OnSiteTime datetime,
		@OffSiteDate datetime,
		@OffSiteTime datetime,
		@ClosedBy smallint,
		@JobNotes varchar(200),
		@Serial varchar(32),
		@MMD_ID varchar(5)

-- INIT
SELECT @OnSiteTime = @OnSiteDate, @OffSiteDate = @OnSiteDate, @OffSiteTime = @OnSiteDate
SELECT @ClosedBy = CAMS.dbo.fnToggleWebUserID(@UserID)

IF @FixID = 3
	BEGIN
		-- REMOVE ANY EQUIPMENT
		DELETE FROM IMS_Job_Equipment WHERE JobID = @JobID
	END
ELSE
	BEGIN
		-- USE NO DEVICE IN OUT
		UPDATE IMS_Jobs SET SpecInstruct = 'NODEVICEINOUT' WHERE JobID = @JobID

		-- BOOK THE JOB
		EXEC spBookInstallerForJob @JobID, 9345, @OnSiteDate, @OnSiteDate, @ClosedBy

		-- POPULATE SERIALS
		EXEC spPopulateDeviceOutSerials @JobID = @JobID

		-- FIX UP EQUIPMENT
		INSERT INTO IMS_Job_Equipment (JobID, MMD_ID, Serial, IsValid, ActionID)
		SELECT J.JobID, SE.MMD_ID, SE.Serial, 1, 2 FROM IMS_Jobs J
		INNER JOIN IMS_Job_Equipment JE on J.JobID = JE.JobID
		INNER JOIN tblJobMMDPartAlternate A on A.ClientID = J.ClientID and A.DeviceType = J.DeviceType and A.DefaultMMD = JE.MMD_ID
		INNER JOIN Site_Equipment SE on SE.ClientID = J.ClientID and SE.TerminalID = J.TerminalID and SE.MMD_ID = A.AlternateMMD
		WHERE J.JobID = @JobID and dbo.fnIsSerialisedDevice(JE.Serial) = 0

		DELETE FROM IMS_Job_Equipment WHERE JobID = @JobID and dbo.fnIsSerialisedDevice(Serial) = 0
	END

-- UPDATE STAT NOTE
UPDATE IMS_Jobs SET StatusNote = @Notes WHERE JobID = @JobID

-- ADD NOTES
SELECT @JobNotes = dbo.fnCRLF() + 'Closed via WebCAMS By: ' + dbo.fnGetOperatorStamp(@ClosedBy) + dbo.fnCRLF()
EXEC dbo.spAddNotesToIMSJob @JobID, @JobNotes, @ClosedBy

-- CLOSE THE JOB
EXEC @ret = dbo.spCloseIMSDeInstallJob
			@JobID = @JobID,
			@OnSiteDate = @OnSiteDate,
			@OnSiteTime = @OnSiteTime,
			@OffSiteDate = @OffSiteDate,
			@OffSiteTime = @OffSiteTime,
			@ClosedBy = -9,
			@CloseComment = @Notes,
			@FixID = @FixID,
			@IsPurgeJob = 1

-- UPDATE ASSETS
DECLARE the_cursor CURSOR FAST_FORWARD
FOR (
	SELECT Serial, MMD_ID FROM IMS_Job_Equipment_History WHERE JobID = @JobID
)

OPEN the_cursor
FETCH NEXT FROM the_cursor INTO @Serial, @MMD_ID

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC spUpdateInventoryLocationCondition
		@Serial = @Serial,
		@MMD_ID = @MMD_ID,
		@Location = 9345,
		@Condition = 53,
		@CurrentDateTime = @OnSiteDate,
		@Note = @Notes,
		@Operator = @ClosedBy

	FETCH NEXT FROM the_cursor INTO @Serial, @MMD_ID
END

CLOSE the_cursor
DEALLOCATE the_cursor

SELECT @ret
RETURN @ret

GO

Grant EXEC on spWebCloseDeinstallJob to eCAMS_Role
GO

Use WebCAMS
Go

ALTER PROCEDURE dbo.spWebCloseDeinstallJob 
(
	@UserID int,
	@JobID int,
	@FixID int,
	@Notes varchar(250)
)
AS
--<!--$Author$-->
--<!--$Created$-->
--<!--$Modified$-->
--<!--$ModifiedBy$-->
--<!--$Comment$-->
--<!--$Commit$-->

 SET NOCOUNT ON

 DECLARE @ret int

 EXEC @ret = CAMS.dbo.spWebCloseDeinstallJob 
		@UserID = @UserID,
		@JobID = @JobID,
		@FixID = @FixID,
		@Notes = @Notes

 SELECT @ret  --buble up to SqlHelper.ExecuteScalar

 RETURN @ret

/*

spWebCloseDeinstallJob	@UserID = 199516,
						@JobID = 221895,
						@Notes = ''

*/
Go

Grant EXEC on spWebCloseDeinstallJob to eCAMS_Role


