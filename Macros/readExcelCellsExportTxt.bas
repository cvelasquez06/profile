Attribute VB_Name = "Módulo1"
Function generarQuerysInsert()
Dim col As Integer
Dim row As Integer
Dim filePath As String
Dim strDate As String
Dim DesProd As String
Dim data As String

strDate = Format(Date, "DD") & Format(Date, "MM") & Format(Date, "YYYY") & Format(Time, "HH") & Format(Time, "NN") & Format(Time, "SS")
filePath = "C:\"
col = 1
row = 2
Do While (Hoja3.Cells(row, col) <> "")
    DesProd = Hoja3.Cells(row, col + 3)
    If DesProd = "NULL" Then
        DesProd = ""
    End If
    data = data & "SQL SENTENCE" & vbCrLf
    row = row + 1
Loop
Open filePath & strDate & "_InsertQrys.sql" For Output As #2
Write #2, data
Close #2
End Function

Function generarQueryUpdate()

Dim col As Integer
Dim row As Integer
Dim filePath As String
Dim strDate As String
Dim DesProd As String
Dim data As String

strDate = Format(Date, "DD") & Format(Date, "MM") & Format(Date, "YYYY") & Format(Time, "HH") & Format(Time, "NN") & Format(Time, "SS")
filePath = "C:\"
col = 1
row = 2
Do While (Hoja4.Cells(row, col) <> "")
    DesProd = Hoja4.Cells(row, col + 3)
    If DesProd = "NULL" Then
        DesProd = ""
    End If
    data = data & "SENTENCE SQL" & vbCrLf
    row = row + 1
Loop
Open filePath & strDate & "_UpdateQrys.sql" For Output As #2
Write #2, data
Close #2

End Function



