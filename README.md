PostGIS Minimialist X3D Viewer 
================
This viewer is a viewer for viewing PostGIS http://postgis.net geometry queries utilizing PostGIS 2.0+,
 X3DOM http://www.x3dom.org/
, JQuery http://jquery.com, color picker JQuery plugin and a Web server that supports your language of choice (ASP.NET w. npgsql.net utilizing C# or VB.Net)
or PHP.  It is a loose wrapper around the PostGIS ST_AsX3D function ([http://postgis.net/docs/ST_AsX3D.html]) .

Requirements
--------------
 1. PostGIS 2.0+ (PostGIS 2.1+ with SFCGAL is preferred).  
    Note: if you are on windows, we do have http://postgis.net/windows_downloads for upcoming PostGIS 2.2
	that have SFCGAL https://github.com/Oslandia/SFCGAL built-in.
 2. A webserver supporting PHP or ASP.NET 2+.
 
Getting started
---------------
 1. Download the source for this.
 2. In your database that already has PostGIS installed, run the tox3d.sql script.
 3. If you are using ASP.Net, you'll need to get Npgsql.net driver 
    from http://npgsql.projects.pgfoundry.org/

	If you are using PHP, make sure to have the PostgreSQL drivers enabled in your ini
 4. There are 3 server side query handler helper files GetX3D.php, GetX3DCS.ashx, GetX3D.ashx
    Depending on which one you want to use, edit the postgis_x3d_viewer.htm file and replace 
	``var postgis_handler = "GetX3D.php";``  
	 
	 with the one you want to use.
	
 5. Edit the config.inc.php (if using PHP) or the web.config (if using ASP.NET) filling in your database credentials
 6. Once you have made the changes you should be able to launch the postgis_x3d_viewer.htm on your web server and should be good to go.

Caveats
--------------- 
 1. The viewer handles only two types of queries -- Geometry which means the query results in a single geometry back
    or raw  which means the query returns a chunk of X3D that can be stuffed into a scene.
 2. Only 3D types are handled at the moment.  There will be more in future.  This is because of current limitation in ST_AsX3D
    which I have documented here: http://trac.osgeo.org/postgis/ticket/2838 and is sort of detailed in Manual
	http://postgis.net/docs/ST_AsX3D.html
	

Support
------------
If you have questions comments or run into issues, please post to the ([postgis-users][]) mailing list.




[postgis-site]:   http://postgis.net/
[postgis-users]:  http://lists.osgeo.org/mailman/listinfo/postgis-users