Use WebCAMS
Go

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spWebPutSurveyAnswer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	drop procedure [dbo].[spWebPutSurveyAnswer]
GO


Create Procedure dbo.spWebPutSurveyAnswer 
	(
		@UserID int,
		@JobID bigint,
		@SurveyResultXML xml
	)
	as
--<!--$$Revision: 5 $-->
--<!--$$Author: Bo $-->
--<!--$$Date: 30/05/11 17:21 $-->
--<!--$$Logfile: /eCAMSSource/SQL/SP/spWebPutSurveyAnswer.sql $-->
--<!--$$NoKeywords: $-->
/*
 Purpose: 
	save SurveySubmitted from FSP web portal. The SurveySubmitted as below xml format
	<root><survey><surveyid>1</surveyid><questionid>152</questionid><answer>YES</answer></survey>...</root>
	..
*/
 set nocount on
 set arithabort on
 --set quoted_identifier off
 
 declare @SurveyID int,
		@QuestionID int,
		@Text varchar(500)
		

 --check if user exists and active, otherwise, quit
 if exists(select 1 from tblUser where UserID = @UserID and IsActive = 1)
  begin
	--split the SurveySubmitted to process
	declare curSurvey cursor local fast_forward
		for select r.value('surveyid[1]', 'int') as SurveyID,
					r.value('questionid[1]', 'int') as QuestionID,
					r.value('answer[1]','varchar(500)') as Answer
				from @SurveyResultXML.nodes('(//root/survey)') as T(r);
				
	open curSurvey

	while (1 = 1)
	 begin
		fetch next from curSurvey
			into @SurveyID, @QuestionID, @Text
		
		if @@FETCH_STATUS <> 0
			break 

		if @SurveyID is not null and @QuestionID is not null
		 begin
			exec Cams.dbo.spPDAPutSurveyAnswer @JobID = @JobID,
								@SurveyID = @SurveyID,
								@QuestionID = @QuestionID,
								@Text = @Text
		 end
		
	 end

	close curSurvey
	deallocate curSurvey
		
  end  --if exists(select 1 from tblUser where UserID = @UserID and IsActive = 1)
  select @@error
  return @@error
  
/*
exec spWebPutSurveyAnswer @UserID=199649, @JobID=1, @SurveyResultXML='<root><survey><surveyid>1</surveyid><questionid>2</questionid><answer>YES</answer></survey></root>'

select * from Cams.dbo.tblSurveyAnswer
 where JobID = 1132014

select * from Cams.dbo.tblSurveyAnswerExt
 where JobID = 1132064
*/
Go

Grant EXEC on spWebPutSurveyAnswer to eCAMS_Role
Go





