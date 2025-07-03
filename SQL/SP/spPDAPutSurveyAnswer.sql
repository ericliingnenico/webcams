Use CAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spPDAPutSurveyAnswer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spPDAPutSurveyAnswer]
GO

create proc spPDAPutSurveyAnswer 
	(
		@JobID bigint,
		@SurveyID int,
		@QuestionID int,
		@Text varchar(500)
	)
--<!--$$Revision: 4 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 8/02/13 13:57 $-->
--<!--$$Logfile: /pCAMSSource/SQL/SP/spPDAPutSurveyAnswer.sql $-->
--<!--$$NoKeywords: $-->
as
--Save Survey Answer. If the same survey on the same job has been conducted more than one, the answer will be saved into tblSurveyAnswerExt
declare @IsEncrypted bit

 SET NOCOUNT ON
 --init
 select @IsEncrypted = isnull(IsEncrypted,0)
   from tblSurveyQuestion 
   where QuestionID = @QuestionID
   
 --process  
 IF EXISTS(SELECT 1 FROM tblSurveyAnswer WHERE JobID = @JobID AND SurveyID = @SurveyID AND QuestionID = @QuestionID)
  BEGIN
	--the same survey on the same job has been conducted before, capture the answer into tblSurveyAnswerExt
	if @IsEncrypted = 0
	 begin
		insert tblSurveyAnswerExt (JobID, SurveyID, QuestionID, [Text]) 
			Values(@JobID, @SurveyID, @QuestionID, @Text)
	 end
	else
	 begin
		insert tblSurveyAnswerExt (JobID, SurveyID, QuestionID, [Text], TextExt) 
			Values(@JobID, @SurveyID, @QuestionID, '', dbo.fnEncryptData(@Text))
	 end
	
  END
 ELSE
  BEGIN
	if @IsEncrypted = 0
	 begin
		insert tblSurveyAnswer (JobID, SurveyID, QuestionID, [Text]) 
			Values(@JobID, @SurveyID, @QuestionID, @Text)
	 end
	else
	 begin
		insert tblSurveyAnswer (JobID, SurveyID, QuestionID, [Text], TextExt) 
			Values(@JobID, @SurveyID, @QuestionID, '', dbo.fnEncryptData(@Text))
	 end

  END


go
Grant EXEC on spPDAPutSurveyAnswer to eCAMS_Role
Go



Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spPDAPutSurveyAnswer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spPDAPutSurveyAnswer]
GO


Create Procedure dbo.spPDAPutSurveyAnswer 
	(
		@JobID bigint,
		@SurveyID int,
		@QuestionID int,
		@Text varchar(500)
	)
	AS
 SET NOCOUNT ON
 EXEC Cams.dbo.spPDAPutSurveyAnswer @JobID = @JobID,
					@SurveyID = @SurveyID,
					@QuestionID = @QuestionID,
					@Text = @Text

/*
spPDAPutSurveyAnswer @JobID = 199516, 
			@SurveyID = 1,
			@QuestionID = 1, 
			@Text = 'No'

select * from Cams.dbo.tblSurveyAnswer
*/
Go

Grant EXEC on spPDAPutSurveyAnswer to eCAMS_Role
Go
