<%@ WebHandler Language="VB" Class="GetX3DVB" %>
'-- Author: Regina Obe (Paragon Corporation) lr@pcorp.us
'-- PostGIS in Action: http://www.postgis.us
'-- Released under the MIT
'-- Version: 0.1
Imports System
Imports System.Web
Imports Npgsql

Public Class GetX3DVB : Implements IHttpHandler
    Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
        context.Response.ContentType = "application/x3d"
        
        If Not IsNothing(context.Request("sql")) Then
            context.Response.Write(GetResults(context, context.Request("sql"), context.Request("bvals"), context.Request("spatial_type")))
        Else
            context.Response.Write(GetResults(context, "ST_Buffer(ST_Point(1,2),10)", "10,100,10", "geometry"))
        End If
    End Sub
 
    Public ReadOnly Property IsReusable() As Boolean Implements IHttpHandler.IsReusable
        Get
            Return False
        End Get
    End Property
    
    Public Function GetResults(context As HttpContext, ByVal aquery As String, bvals As String, spatial_type As String) As String
        Dim result As String
        Dim command As NpgsqlCommand
        Dim geomtext As String = "ST_Buffer('MULTIPOINT((1 2),(3 4),(5 6))'::geometry,1)"
        Dim arybvals As String() = bvals.Split(",")
        Dim x3dcolor As Double() = {0, 0, 0.56} 'default to a bluish color 
        
        'Dim nParam As NpgsqlParameter = New Npgsql.NpgsqlParameter(
        Dim sql As String
        Using conn As NpgsqlConnection = New NpgsqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings("DSN").ConnectionString)
            conn.Open()
            If aquery.Trim().Length > 0 Then
                geomtext = aquery
            End If
            If spatial_type = "raw" Then
                sql = "SELECT postgis_viewer_x3d(:spatial_expression, :spatial_type)" 'for x3d color values are encoded in the raster
            Else
                sql = "SELECT postgis_viewer_x3d(:spatial_expression, :spatial_type, :color)"
            End If
        

            command = New NpgsqlCommand(sql, conn)
            
            command.Parameters.Add(New NpgsqlParameter("spatial_expression", aquery))
            command.Parameters.Add(New NpgsqlParameter("spatial_type", spatial_type))
            
            If spatial_type = "geometry" Then
                If arybvals.GetUpperBound(0) > 0 Then 'a color was set convert to float between 0 and 1 for each band
                    x3dcolor = {Convert.ToDouble(arybvals(0)) / 255, Convert.ToDouble(arybvals(1)) / 255, Convert.ToDouble(arybvals(2)) / 255}
                End If

                command.Parameters.Add(New NpgsqlParameter("color", New Double() {x3dcolor(0), x3dcolor(1), x3dcolor(2)}))
            End If

            Try
                result = command.ExecuteScalar()
            Catch ex As Exception
                result = Nothing
                context.Response.Write(ex.Message.Trim & " " & aquery)
            End Try
            conn.Close()

        End Using
        Return result
    End Function

End Class

