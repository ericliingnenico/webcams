Option Strict On

Imports System.IO

Namespace eCAMS
    Public Class FSPDownloadMaintenanceBasePage
        Inherits MemberPageBase

        Protected ReadOnly RootPath As String = ConfigurationManager.AppSettings("Download.RootPath").ToString()
        Protected ReadOnly ServerRootPath As String = Server.MapPath("~" + RootPath)
        Protected ReadOnly ArchivePath As String = ServerRootPath + ARCHIVE_FOLDER + "\"

        Protected Const ARCHIVE_FOLDER As String = "Archive"
        Protected Const DISABLED_CATEGORY As String = "-1"
        Protected Const NO_FILE As String = "0"

        Private SelectedNode As TreeNode

        Protected Function UploadFile(ByVal pOverwrite As Boolean, ByVal pDirectory As String, ByRef pFileUpload As FileUpload, ByRef pStatusLabel As Label) As Boolean
            Try
                Dim filename As String = Path.GetFileName(pFileUpload.PostedFile.FileName)
                Dim filePath As String = Path.Combine(pDirectory, filename)
                Dim allowedFileTypes As String() = ConfigurationManager.AppSettings("Download.AllowedFileTypes").Split(","c)
                Dim maxFileSize As Double = CDbl(ConfigurationManager.AppSettings("Download.MaxFileSizeMB")) * 1024

                If File.Exists(filePath) And Not pOverwrite Then
                    Throw New Exception("File Exists")
                ElseIf Not (allowedFileTypes.Contains(Path.GetExtension(filename).TrimStart("."c))) Then
                    Throw New Exception("File format not allowed")
                ElseIf ((pFileUpload.PostedFile.ContentLength / 1024) > maxFileSize) Then
                    Throw New Exception("File too large")
                End If

                pFileUpload.SaveAs(filePath)

                Return True
            Catch ex As Exception
                pStatusLabel.CssClass = "FormDEError"
                pStatusLabel.Text = "The file could not be uploaded. The following error occured: " + ex.Message
            End Try

            Return False
        End Function

        Protected Function SaveDownload(ByRef pSeq As Int16, ByVal pDownloadCategoryID As Int16, ByVal pDownloadDescription As String, ByVal pFilePath As String, ByVal pIsActive As Boolean, ByRef pStatusLabel As Label) As Boolean
            Try
                If pFilePath = NO_FILE Then
                    Throw New Exception("No file selected")
                ElseIf pDownloadDescription = "" Then
                    Throw New Exception("No description entered")
                End If

                Dim fileInfo As FileInfo = New FileInfo(pFilePath)

                m_DataLayer.PutDownload(pSeq,
                                    pDownloadCategoryID,
                                    pDownloadDescription,
                                    GetDownloadURL(pFilePath),
                                    Math.Round(fileInfo.Length / 1024, 0).ToString() + "KB",
                                    pIsActive)

                Return True
            Catch ex As Exception
                If Not pStatusLabel Is Nothing Then
                    pStatusLabel.CssClass = "FormDEError"
                    pStatusLabel.Text = "The download could not be added. The following error occured: " + ex.Message
                Else
                    Throw ex
                End If
            End Try

            Return False
        End Function

        Protected Function AddDirectory(ByVal pDirectoryPath As String, ByRef pStatusLabel As Label) As Boolean
            Try
                If Directory.Exists(pDirectoryPath) Then
                    Throw New Exception("Directory Exists!")
                End If

                Directory.CreateDirectory(pDirectoryPath)

                Return True
            Catch ex As Exception
                pStatusLabel.CssClass = "FormDEError"
                pStatusLabel.Text = "The directory could not be added. The following error occured: " + ex.Message
            End Try

            Return False
        End Function

        Protected Function ArchiveFile(ByVal pFile As String, ByRef pStatusLabel As Label, Optional ByVal pUnarchivePath As String = "") As Boolean
            Dim fileName As String = Path.GetFileName(pFile)
            Dim movePath As String = GetArchivePath(pFile)
            Dim isActive As Boolean = False
            Dim exceptionMessages As String = ""

            Try
                If pUnarchivePath <> "" Then
                    isActive = True
                    movePath = pUnarchivePath + Path.GetExtension(fileName)

                    If File.Exists(movePath) Then
                        Throw New Exception("The file already exists!")
                    End If
                Else
                    If File.Exists(movePath) Then
                        Dim name As String = Path.GetFileNameWithoutExtension(fileName)
                        fileName = fileName.Replace(name, name + "--" + Date.Now.ToString("ddMMyyhhmmss"))

                        Dim newPath As String = Path.Combine(Path.GetDirectoryName(pFile), fileName)
                        Rename(pFile, newPath)

                        pFile = newPath
                        movePath = GetArchivePath(pFile)
                    End If
                End If

                Directory.CreateDirectory(Path.GetDirectoryName(movePath))
                File.Move(pFile, movePath)

                Dim downloads As DataSet = GetDownloads(pFile)

                If (downloads IsNot Nothing AndAlso downloads.Tables.Count > 0) Then
                    For Each row As DataRow In m_DataLayer.dsDownloads.Tables(0).Rows
                        SaveDownload(CShort(row("Seq")),
                                 CShort(row("DownloadCategoryID")),
                                 row("DownloadDescription").ToString(),
                                 movePath,
                                 isActive,
                                 Nothing)
                    Next
                End If

                Return True
            Catch ex As Exception
                exceptionMessages += ex.Message + " "
            End Try

            If exceptionMessages <> "" Then
                pStatusLabel.CssClass = "FormDEError"
                pStatusLabel.Text = "The file could not be archived/unarchived. The following error/s occured: " + exceptionMessages
            End If

            Return False
        End Function

        Protected Sub GetCategories(ByRef pCboCategories As DropDownList)
            Dim ds As DataSet = Nothing
            
            If m_DataLayer.GetDownloadCategoryAll() = DataLayerResult.Success Then
                ds = m_DataLayer.dsDownloads.Copy()
                ds.Tables(0).Rows.RemoveAt(0) 'Remove Videos Category
            End If

            pCboCategories.DataSource = ds
            pCboCategories.DataTextField = "CategoryName"
            pCboCategories.DataValueField = "DownloadCategoryID"
            pCboCategories.DataBind()
        End Sub

        Protected Sub GetFiles(ByRef pCboFiles As DropDownList, ByVal pDirectory As String)
            Dim files() As String = Directory.GetFiles(pDirectory)
            Array.Sort(files)

            pCboFiles.Items.Clear()
            pCboFiles.Items.Add(New ListItem("Select File...", NO_FILE))

            For Each file As String In files
                pCboFiles.Items.Add(New ListItem(Path.GetFileName(file), file))
            Next
        End Sub

        Protected Sub GetDirectories(ByRef pTreeDirectory As TreeView, Optional ByVal pRootPath As String = "", Optional ByVal pSelectedDirectory As String = "")
            If pRootPath = "" Then
                pRootPath = ServerRootPath
            End If

            Dim rootDirectoryNode As TreeNode = New TreeNode(New DirectoryInfo(pRootPath).Name, pRootPath)
            
            pTreeDirectory.Nodes.Clear()
            pTreeDirectory.Nodes.Add(rootDirectoryNode)

            rootDirectoryNode.Select()
            rootDirectoryNode.Expand()

            Call BuildDirectoryNodes(rootDirectoryNode, pRootPath, pSelectedDirectory)

            If SelectedNode IsNot Nothing Then
                Call ExpandParentNodes(SelectedNode)
                SelectedNode.Select()
                SelectedNode = Nothing
            End If
        End Sub

        Protected Function GetDownloads(ByRef pFile As String) As DataSet
            If m_DataLayer.GetDownloadsByURL(GetDownloadURL(pFile)) = DataLayerResult.Success Then
                Return m_DataLayer.dsDownloads
            End If

            Return Nothing
        End Function

        Protected Sub GetDownloads(ByRef pCboDownloads As DropDownList, ByVal pCategoryID As String)
            If m_DataLayer.GetDownload("", "-" + pCategoryID, RenderingStyleType.PDA) = DataLayerResult.Success Then
                Dim ds As DataSet = m_DataLayer.dsDownloads.Copy()
                Dim row As DataRow = ds.Tables(0).NewRow()

                row("Seq") = "0"
                row("Description") = "<New>"

                ds.Tables(0).Rows.InsertAt(row, 0)

                pCboDownloads.DataSource = ds
                pCboDownloads.DataTextField = "Description"
                pCboDownloads.DataValueField = "Seq"
                pCboDownloads.DataBind()
            End If
        End Sub

        Private Sub BuildDirectoryNodes(ByRef pTreeNode As TreeNode, ByVal pDirectory As String, Optional ByVal pSelectedDirectory As String = "")
            Dim directories As String() = Directory.GetDirectories(pDirectory)

            For Each directory As String In directories
                Dim directoryInfo As DirectoryInfo = New DirectoryInfo(directory)
                Dim childNode As TreeNode = New TreeNode(directoryInfo.Name, directory + "\")

                If directoryInfo.Name <> ARCHIVE_FOLDER Then
                    pTreeNode.ChildNodes.Add(childNode)

                    If pSelectedDirectory <> "" AndAlso GetDownloadURL(directory) = GetDownloadURL(pSelectedDirectory) Then
                        SelectedNode = childNode
                    End If
                End If

                BuildDirectoryNodes(childNode, directory, pSelectedDirectory)
            Next
        End Sub

        Private Sub ExpandParentNodes(ByRef pTreeNode As TreeNode)
            If pTreeNode.Parent IsNot Nothing Then
                pTreeNode.Parent.Expand()
                ExpandParentNodes(pTreeNode.Parent)
            End If
        End Sub

        Private Function GetDownloadURL(ByVal pFilePath As String) As String
            Dim parts As String() = pFilePath.Replace("\", "/").Split({RootPath}, StringSplitOptions.None)
            Dim directory As String = Path.GetDirectoryName(Path.Combine(RootPath, parts(1)))

            Return Path.Combine(directory, Path.GetFileName(pFilePath)).Replace("\", "/")
        End Function

        Private Function GetArchivePath(ByVal pFilePath As String) As String
            Return pFilePath.Replace(ServerRootPath, ServerRootPath + ARCHIVE_FOLDER + "\")
        End Function
    End Class
End Namespace
