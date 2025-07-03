#Region "vss"
'<!--$$Revision: 2 $-->
'<!--$$Author: Bo $-->
'<!--$$Date: 29/09/11 10:10 $-->
'<!--$$Logfile: /eCAMSSource2010/eCAMS/Class/GMapBase.vb $-->
'<!--$$NoKeywords: $-->
#End Region
Option Strict On

Namespace eCAMS
Public Class GMapBase
        Inherits MemberPageBase

        Protected m_latitude As string  = ""
        Protected m_longitude As string = ""
        Protected m_txt As string = ""
        Protected m_color As string = ""
        Protected m_qty As string = ""
        Protected m_doCircle As string = ""
        Protected m_radius As string = ""
        Protected svr As string = ""
        Protected m_myID As string = ""
        Protected m_exceptionMsg As string = "Incorrect query string"
        Protected m_boundary As string = ""
        Protected m_jobViewer As String
        Protected Overrides Sub GetContext()
            ''get inputs
            If Not Request.QueryString.GetValues("dc") is Nothing then
                m_doCircle = Request.QueryString.GetValues("dc")(0).ToString
            End If
            If Not Request.QueryString.GetValues("rd") is Nothing then
                m_radius = Request.QueryString.GetValues("rd")(0).ToString
            End If
            If Not Request.QueryString.GetValues("svr") is Nothing then
                svr = Request.QueryString.GetValues("svr")(0).ToString
            End If
            If Not Request.QueryString.GetValues("id") is Nothing then
                m_myID = Request.QueryString.GetValues("id")(0).ToString
            End If
            svr = svr.ToUpper()
        End Sub
        Protected Overrides Sub Process()
	        Dim ds As New DataSet()
	        'get recordset
	        Select Case svr
		        Case "FJ"
			        'FSP Job
			        if m_DataLayer.GMAPGetFSPJob(m_jobViewer) = DataLayerResult.Success then
                        ds = m_DataLayer.dsJob
                        If ds.Tables(0).Rows.Count=0 then
                            m_exceptionMsg = String.Format("No booked jobs found for this FSP")
                        End If
                    End If
			
			        Exit Select

		        'Case "JR"
		        '	'Job in m_radius
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGMapGetJob", m_myID, MyBase.EmptyToNull(m_radius))
		        '	m_exceptionMsg = String.Format("No jobs found in the m_radius of {0} KM to the job - {1}", m_radius, m_myID)
		        '	Exit Select

		        'Case "CF"
		        '	'closest FSP
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGMapGetClosestFSP", m_myID, m_radius)
		        '	m_exceptionMsg = String.Format("No FSP found in the m_radius of {0} KM to the job - {1}", m_radius, m_myID)
		        '	Exit Select

		        'Case "APMJ"
		        '	'APM Geo Monitor for Jobs
		        '	'can use ID to pass-in state
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGeoMonitorGetJob", "J", MyBase.EmptyToNull(m_myID))
		        '	m_exceptionMsg = "No today's booked jobs found for APM"
		        '	Exit Select

		        'Case "APMC"
		        '	'APM Geo Monitor for Calls
		        '	'can use ID to pass-in state
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGeoMonitorGetJob", "C", MyBase.EmptyToNull(m_myID))
		        '	m_exceptionMsg = "No calls found for APM"
		        '	Exit Select

		        'Case "APMDC"
		        '	'Due/OverDue Calls
		        '	'can use ID to pass-in state
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGeoMonitorGetJob", "DC", MyBase.EmptyToNull(m_myID))
		        '	m_exceptionMsg = "No due/overdue swap calls found for APM"
		        '	Exit Select

		        'Case "PDA"
		        '	'APM Geo Monitor
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGMapGetJobMobileURL", MyBase.EmptyToNull(m_myID))
		        '	m_exceptionMsg = String.Format("No today's booked jobs found for this FSP - {0}", m_myID)
		        '	Exit Select

		        'Case "SS"
		        '	'Surrounding Suburbs
		        '	'can use ID to pass-in City,state
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGetSurroundingSuburb", m_myID.Split(New Char() {","C})(0), m_myID.Split(New Char() {","C})(1), m_radius)
		        '	m_exceptionMsg = "No Surrounding Suburbs found"
		        '	Exit Select

		        'Case "FCS"
		        '	'FSP Coverage Suburb
		        '	'can use ID to pass-in ClientID, JobTypID, FSP
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGetFSPCoverageSuburb", m_myID.Split(New Char() {","C})(0), m_myID.Split(New Char() {","C})(1), m_myID.Split(New Char() {","C})(2))
		        '	m_exceptionMsg = "No Coverage Suburbs found"
		        '	Exit Select

		        'Case "SCBF"
		        '	'Suburb Covered By FSP
		        '	'can use ID to pass-in  ClientID, JobTypeID, City,state
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGetSuburbCoveredByFSP", m_myID.Split(New Char() {","C})(0), m_myID.Split(New Char() {","C})(1), m_myID.Split(New Char() {","C})(2), m_myID.Split(New Char() {","C})(3), _
		        '		m_radius)
		        '	m_exceptionMsg = "The area in the circle of " & m_radius & " km of " & m_myID.Split(New Char() {","C})(2).ToUpper() & ", " & m_myID.Split(New Char() {","C})(3).ToUpper() & ": Smart install/courier service area."
		        '	Exit Select

		        'Case "TOOL"
		        '	'Suburb Covered By FSP
		        '	'can use ID to pass-in  ClientID, JobTypeID, City,state
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spToolGetGeoData", m_myID)
		        '	m_exceptionMsg = ""
		        '	Exit Select

		        'Case "PLOT"
		        '	'Plot Suburb
		        '	'can use ID to pass-in  State, City
		        '	ds = SqlHelper.ExecuteDataset(dbConn, "spGetPostcodem_boundary", m_myID)
		        '	m_exceptionMsg = ""
		        '	Exit Select
		        Case Else
        	        Exit Select
	        End Select

		    If ds.Tables.Count > 0 Then
			    'build Google Map API parameter string
			    For Each dr As DataRow In ds.Tables(0).Rows
				    m_latitude += dr("latitude").ToString + ","
				    m_longitude += dr("longitude").ToString + ","
				    m_txt += dr("txt").ToString + ","
				    If isAPM() Then
					    m_color += dr("color").ToString + ","
				    End If
				    m_qty += dr("qty").ToString + ","

				    Try
					    m_boundary += dr("boundaryPoint").ToString + ":"
				    Catch ex As Exception
				    End Try

			    Next

			    If m_latitude.Length > 0 Then
				    'trim the last comma delimiter
				    Dim extraComma As Char() = {","C}
				    m_latitude = m_latitude.TrimEnd(extraComma)
				    m_longitude = m_longitude.TrimEnd(extraComma)
				    m_txt = m_txt.TrimEnd(extraComma)
				    m_color = m_color.TrimEnd(extraComma)
				    m_qty = m_qty.TrimEnd(extraComma)
			    End If

		    End If
	        'finally display page
	        DisplayPage((m_latitude.Length > 0))

        End Sub

        Protected Overridable Sub DisplayPage(showMap As Boolean)
	        AddClientScript(showMap)

        End Sub

        Protected Overloads Sub AddClientScript(showMap As Boolean)
	        'build java proxy
	        Dim jsScript As String = String.Format("<SCRIPT language='JavaScript'> function CreateMap(){{ {0}; }}</SCRIPT>", (If(Not showMap, "return true", (If(isAPM(), "drawMonitorMap('" & m_latitude & "','" & m_longitude & "','" & m_txt & "','" & m_color & "','" & m_qty & "', '" & m_doCircle & "', '" & m_radius & "', '" & m_boundary & "')", "drawMap('" & m_latitude & "','" & m_longitude & "','" & m_txt & "','" & m_qty & "', '" & m_doCircle & "', '" & m_radius & "', '" & m_boundary & "')")))))

	        If Not Me.Page.ClientScript.IsClientScriptBlockRegistered("jsCreateMap") Then
		        Me.Page.ClientScript.RegisterClientScriptBlock(Me.[GetType](), "jsCreateMap", jsScript)
	        End If

        End Sub

        Private Function isAPM() As Boolean
	        Return (svr.StartsWith("APM") OrElse svr = "FJ" OrElse svr = "SCBF" OrElse svr = "TOOL" OrElse svr = "PLOT")
        End Function

End Class
End Namespace