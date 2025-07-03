Option Strict On
Imports System.IO

Namespace eCAMS
    Public Class AdminFSPDownload
        Inherits FSPDownloadMaintenanceBasePage

        Protected AcceptedFileTypes As String

        Protected Overrides Sub Process()
            Me.RestrictModuleName = "AdminDownload"
            Me.PageTitle = "Download Admin"

            Dim allowedFileTypes As String() = ConfigurationManager.AppSettings("Download.AllowedFileTypes").Split(","c)
            Dim acceptAttirbuteValue = String.Join(",", allowedFileTypes.Select(Function(t As String) "." + t))

            fuFile.Attributes.Add("accept", acceptAttirbuteValue)
            
            Call ResetControls()
            Call GetCategories(cboCategories)
            
            Dim seq As String = Request.QueryString("Seq")
            If seq <> "" Then
                Call HandleDownloadUpdate(seq)
            End If
        End Sub

        Private Sub treeDirectory_SelectedNodeChanged(sender As Object, e As EventArgs) Handles treeDirectory.SelectedNodeChanged
            Call GetAllFiles()
        End Sub

        Private Sub treeArchiveDirectory_SelectedNodeChanged(sender As Object, e As EventArgs) Handles treeArchiveDirectory.SelectedNodeChanged
            Call GetFiles(cboFilesUnarchive, treeArchiveDirectory.SelectedValue)
        End Sub

        Private Sub cboCategories_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboCategories.SelectedIndexChanged
            lbtnMaintainDownload_Click(Nothing, Nothing)
        End Sub

        Private Sub cboDownloads_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboDownloads.SelectedIndexChanged
            If (cboDownloads.SelectedValue <> "0") Then
                HandleDownloadUpdate(cboDownloads.SelectedValue)
            Else
                lbtnMaintainDownload_Click(Nothing, Nothing)
            End If
        End Sub

        Private Sub HandleDownloadUpdate(ByVal pSeq As String)
            txtSeq.Value = pSeq

            If m_DataLayer.GetDownload(pSeq, Nothing, RenderingStyleType.DeskTop) = DataLayerResult.Success Then
                If (m_DataLayer.dsDownloads.Tables.Count > 0 AndAlso m_DataLayer.dsDownloads.Tables(0).Rows.Count > 0) Then
                    Dim download As DataRow = m_DataLayer.dsDownloads.Tables(0).Rows(0)
                    Dim downloadURL As String = download.Item("DownloadURL").ToString()
                    Dim directory As String = Path.GetDirectoryName(downloadURL)
                    Dim filePath As String = Server.MapPath("~" + downloadURL)
                    Dim isArchived As Boolean = False

                    If (directory.Contains(ARCHIVE_FOLDER)) Then
                        directory = RootPath
                        isArchived = True
                    End If

                    Call GetDirectories(treeDirectory, "", directory)
                    Call GetFiles(cboFiles, Server.MapPath("~" + directory))

                    If (isArchived = False And File.Exists(filePath) = True)
                        cboFiles.SelectedValue = Server.MapPath("~" + downloadURL)
                    End If

                    cboCategories.SelectedValue = download.Item("DownloadCategoryID").ToString()
                    txtDescription.Text = download.Item("DownloadDescription").ToString()
                    chkIsActive.Checked = CBool(download.Item("IsActive"))

                    Call GetDownloads(cboDownloads, cboCategories.SelectedValue)
                    cboDownloads.SelectedValue = pSeq
                End If
            End If
            
            panelDownloads.Visible = True
            panelDirectory.Visible = True
            panelSelectFile.Visible = True

            btnSave.Visible = True
        End Sub

        Private Sub HandleSaveFile()
            If UploadFile(chkOverwrite.Checked, treeDirectory.SelectedValue, fuFile, lblStatus) Then
                lblStatus.CssClass = "FormDESuccess"
                lblStatus.Text = "The file has been added/updated successfully!"

                GetAllFiles()
            End If
        End Sub

        Private Sub HandleSaveDownload()
            Dim seqNumber As Int16 = -1
            Dim isUpdate As Boolean = False

            If txtSeq.Value <> "" Then
                seqNumber = CShort(txtSeq.Value)
                isUpdate = True
            End If

            If SaveDownload(seqNumber, CShort(cboCategories.SelectedValue), txtDescription.Text, cboFiles.SelectedValue, chkIsActive.Checked, lblStatus) Then
                If isUpdate = True Then
                    lblStatus.Text = "The file has been updated successfully!"
                Else
                    Call HandleDownloadUpdate(seqNumber.ToString())
                    lblStatus.Text = "The file has been added successfully!"
                End If

                lblStatus.CssClass = "FormDESuccess"
            End If
        End Sub

        Private Sub HandleArchiveFile()
            If ArchiveFile(cboFiles.SelectedValue, lblStatus) Then
                lblStatus.CssClass = "FormDESuccess"
                lblStatus.Text = "The file has been archived successfully!"

                GetAllFiles()
            End If
        End Sub

        Private Sub HandleUnarchiveFile()
            If ArchiveFile(cboFilesUnarchive.SelectedValue, lblStatus, Path.Combine(treeDirectory.SelectedValue, txtUnarchiveName.Text)) Then
                lblStatus.CssClass = "FormDESuccess"
                lblStatus.Text = "The file has been unarchived successfully!"

                txtUnarchiveName.Text = ""
                lblUnarchiveNameExt.Text = ""

                GetFiles(cboFilesUnarchive, ArchivePath)
            End If
        End Sub

        Private Sub btnAddDirectory_Click(sender As Object, e As EventArgs) Handles btnAddDirectory.Click
            Dim newDirectoryPath = Path.Combine(treeDirectory.SelectedValue, txtDirectoryName.Text)

            If txtDirectoryName.Text = "" Then
                lblStatus.CssClass = "FormDEError"
                lblStatus.Text = "You must specify a directory name!"
            ElseIf AddDirectory(newDirectoryPath, lblStatus) Then
                lblStatus.CssClass = "FormDESuccess"
                lblStatus.Text = "The directory has been added successfully!"

                txtDirectoryName.Text = ""

                Call GetDirectories(treeDirectory, "", newDirectoryPath)
            End If
        End Sub

        Private Sub btnSave_Click(sender As Object, e As EventArgs) Handles btnSave.Click
            If panelUnarchiveFile.Visible = True Then
                Call HandleUnarchiveFile()
            ElseIf panelDownloads.Visible = True Then
                Call HandleSaveDownload()
            End If
        End Sub

        Private Sub btnSaveWithPostback_Click(sender As Object, e As EventArgs) Handles btnSaveWithPostback.Click
            If panelFiles.Visible = True Then
                Call HandleSaveFile()
            ElseIf panelArchiveFile.Visible = True Then
                Call HandleArchiveFile()
            End If
        End Sub

        Private Sub lbtnUploadFile_Click(sender As Object, e As EventArgs) Handles lbtnUploadFile.Click
            ResetControls()

            lbtnUploadFile.ForeColor = Drawing.Color.Purple

            Call GetDirectories(treeDirectory)

            panelDirectory.Visible = True
            panelAddSubdirectory.Visible = True
            panelFiles.Visible = True

            btnSaveWithPostback.Visible = True

            lblDirectoryTitle.Text = "Upload File"
        End Sub

        Private Sub lbtnMaintainDownload_Click(sender As Object, e As EventArgs) Handles lbtnMaintainDownload.Click
            ResetControls()

            lbtnMaintainDownload.ForeColor = Drawing.Color.Purple

            txtSeq.Value = ""
            txtDescription.Text = ""

            Call GetDirectories(treeDirectory)
            Call GetFiles(cboFiles, treeDirectory.SelectedValue)
            Call GetDownloads(cboDownloads, cboCategories.SelectedValue)

            panelDirectory.Visible = True
            panelSelectFile.Visible = True
            panelDownloads.Visible = True

            btnSave.Visible = True

            lblDirectoryTitle.Text = ""
            lblDirectory.Text = "File"
        End Sub

        Private Sub lbtnArchiveFile_Click(sender As Object, e As EventArgs) Handles lbtnArchiveFile.Click
            ResetControls()

            lbtnArchiveFile.ForeColor = Drawing.Color.Purple

            Call GetDirectories(treeDirectory)
            Call GetFiles(cboFiles, treeDirectory.SelectedValue)

            panelDirectory.Visible = True
            panelSelectFile.Visible = True
            panelArchiveFile.Visible = True
            panelAssociatedDownloads.Visible = True

            btnSaveWithPostback.OnClientClick = "return confirm('Downloads associated with this file will be disabled, continue?')"
            btnSaveWithPostback.Visible = True

            lblDirectoryTitle.Text = "Archive File"
            lblDirectory.Text = "File"
        End Sub

        Private Sub lbtnUnarchiveFile_Click(sender As Object, e As EventArgs) Handles lbtnUnarchiveFile.Click
            ResetControls()

            lbtnUnarchiveFile.ForeColor = Drawing.Color.Purple

            Call GetDirectories(treeArchiveDirectory, ArchivePath)
            Call GetDirectories(treeDirectory)
            Call GetFiles(cboFilesUnarchive, treeArchiveDirectory.SelectedValue)

            lblDirectoryTitle.Text = "Unarchive File Destination"

            panelUnarchiveFile.Visible = True
            panelDirectory.Visible = True
            panelAddSubdirectory.Visible = True
            panelAssociatedDownloads.Visible = True

            btnSave.OnClientClick = "return confirm('Downloads previously associated with this file will be re-enabled, continue?')"
            btnSave.Visible = True
        End Sub

        Private Sub ResetControls()
            panelUnarchiveFile.Visible = False
            panelDirectory.Visible = False
            panelAddSubdirectory.Visible = False
            panelSelectFile.Visible = False
            panelArchiveFile.Visible = False
            panelFiles.Visible = False
            panelDownloads.Visible = False
            panelAssociatedDownloads.Visible = False

            btnSaveWithPostback.Visible = False
            btnSave.Visible = False

            btnSaveWithPostback.OnClientClick = ""
            btnSave.OnClientClick = ""

            lblStatus.CssClass = ""
            lblStatus.Text = ""

            lblDirectory.Text = "Directory"

            lbtnUploadFile.ForeColor = Drawing.Color.Blue
            lbtnMaintainDownload.ForeColor = Drawing.Color.Blue
            lbtnArchiveFile.ForeColor = Drawing.Color.Blue
            lbtnUnarchiveFile.ForeColor = Drawing.Color.Blue

            grdDownloads.DataSource = Nothing
            grdDownloads.DataBind()
        End Sub

        Private Sub GetAllFiles()
            Call GetFiles(cboFiles, treeDirectory.SelectedValue)
        End Sub

        Private Sub cboFilesUnarchive_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboFilesUnarchive.SelectedIndexChanged
            Dim file As String = cboFilesUnarchive.SelectedValue

            txtUnarchiveName.Text = Path.GetFileNameWithoutExtension(file)
            lblUnarchiveNameExt.Text = Path.GetExtension(file)

            BindDownloads(file)
        End Sub

        Private Sub cboFiles_SelectedIndexChanged(sender As Object, e As EventArgs) Handles cboFiles.SelectedIndexChanged
            If panelArchiveFile.Visible = True Then
                BindDownloads(cboFiles.SelectedValue)
            End If
        End Sub

        Private Sub BindDownloads(pFile As String)
            Dim downloads As DataSet = GetDownloads(pFile)

            If (downloads IsNot Nothing AndAlso downloads.Tables.Count > 0) Then
                Dim dv As DataView = New DataView(downloads.Tables(0))

                dv.Table.Columns.Remove("Seq")
                dv.Table.Columns.Remove("DownloadCategoryID")

                grdDownloads.DataSource = dv
                grdDownloads.DataBind()
            End If
        End Sub
    End Class
End Namespace