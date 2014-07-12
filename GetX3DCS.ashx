<%@ WebHandler Language="C#" Class="GetRasterCS" %>
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
//-- Author: Regina Obe (Paragon Corporation) lr@pcorp.us
//-- PostGIS in Action: http://www.postgis.us
//-- Released under the MIT
//-- version 0.2
using System.Web;
using Npgsql;

public class GetRasterCS : IHttpHandler
{
	public void ProcessRequest(HttpContext context)
	{
		//If (Not IsNothing(context.Request("sql"))) Then
        context.Response.ContentType = "application/x3d";

		if ((context.Request["sql"] != null)) {
			context.Response.Write(GetResults(context, context.Request["sql"], context.Request["bvals"], context.Request["spatial_type"]));
		} else {
			context.Response.Write(GetResults(context, "ST_Buffer(ST_Point(1,2),10)", "10,100,10", "geometry"));
		}
	}

	public bool IsReusable {
		get { return false; }
	}

	public String GetResults(HttpContext context, String aquery, String bvals, String spatial_type)
	{
	    String result = null;
		NpgsqlCommand command = default(NpgsqlCommand);
		String geomtext = "ST_Buffer('MULTIPOINT((1 2),(3 4),(5 6))'::geometry,1)";
		String[] arybvals = bvals.Split(',');
        Double[] x3dcolor  = {0, 0, 0.56}; //default to a bluish color 

		string sql = null;
		using (NpgsqlConnection conn = new NpgsqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["DSN"].ConnectionString)) {
			conn.Open();
			if (aquery.Length > 0) {
				geomtext = aquery;
			}
			if (spatial_type == "raw") {
                sql = "SELECT postgis_viewer_x3d(:spatial_expression, :spatial_type)";
				//for raster color values are encoded in the raster so no need to pass band color values
			} else {
                sql = "SELECT postgis_viewer_x3d(:spatial_expression, :spatial_type, :color)";
			}


			command = new NpgsqlCommand(sql, conn);
            command.Parameters.Add(new NpgsqlParameter("spatial_expression", aquery));
            command.Parameters.Add(new NpgsqlParameter("spatial_type", spatial_type));
			

			if (spatial_type == "geometry") {
                x3dcolor = (new double[] { Convert.ToDouble(arybvals[0]) / 255, Convert.ToDouble(arybvals[1]) / 255, Convert.ToDouble(arybvals[2]) / 255 });
				command.Parameters.Add(new NpgsqlParameter("color", x3dcolor));
			}



			try {
				result = (String) command.ExecuteScalar();
			} catch (Exception ex) {
				result = null;
				context.Response.Write(ex.Message.Trim());
			}
			conn.Close();

		}
		return result;
	}

}
