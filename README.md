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
    from http://npgsql.projects.pgfoundry.org/ and copy into the Bin folder

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
	
Examples
----------
Refer to: http://www.bostongis.com/blog/index.php?/archives/229-PostGIS-Minimalist-X3D-Viewer-for-PHP-and-ASP.NET.html

Use Geometry for these examples
--------------------------------
```
SELECT ST_Translate(
 ST_Extrude(
   ST_Buffer(
  (SELECT 
    ST_Collect( ST_Rotate('LINESTRING(10 20, 30 40, 50 65)'::geometry, pi()*i/2
     , ST_Point(10, 20)) ) 
      FROM generate_series(0,2,2) As i ), 1), 0, 0, 2), 0, 0,6);  --color 8f7a53
```

```
SELECT ST_Extrude(ST_Buffer(ST_Union(
    ST_Point(10, 20), ST_Point(5, 5)), 10, 'quad_segs=48'),
     0, 0, 10); -- color f2553d
```

```
SELECT ST_Translate(
   ST_Extrude(ST_Buffer(ST_Point(10, 20), 20, 'quad_segs=4'),
   0, 0, 2),0,0,10);  -- color this blue 287c80
```

```
SELECT ST_Translate(ST_Extrude(ST_Buffer(ST_Point(10, 20), 3), 
  0, 0, 2),0,0,11);
```
  
  
Use Raw mode for these examples
--------------------------------
Note for Raw mode, you need to escape single quotes ' with two single quotes ''.
Also the selected color in the color picker is ignored and its up to you to include in your raw if needed.

Set of rainbow triangles
```
SELECT  '<Shape>
<IndexedTriangleSet index=''0 1 2 3 4 5 6 7 8'' solid=''false'' ccw=''true'' colorPerVertex=''true'' normalPerVertex=''true'' containerField=''geometry''>
<Coordinate point=''-4 1 3 -2 2 1.5 -3 4 0.5 -2 3 1.5 0 4 0 2 3 1.5 5 5 -2.5 4 3 1.5 6 4 2''/>
<Color color=''0 0.8 0 0 1 1 1 0 0 1 0.5 0 0.8 0 1 1 1 0 0.6 0.3 0.1 1 0 0.5 0 1 0.5''/>
</IndexedTriangleSet>
</Shape>';
```

A pyramid
```
SELECT  '<Shape>
        <IndexedFaceSet coordIndex=''0 1 2 -1 1 3 2 -1 2 3 0 -1 3 1 0''>
          <Coordinate point=''0 0 0 10 0 0 5 0 8.3 5 8.3 2.8''/>
        </IndexedFaceSet>
        <Appearance>
          <Material diffuseColor=''0.8 0.8 0.2'' specularColor=''0 0 0.5''/>
        </Appearance>
      </Shape>'
```

Support
------------
If you have questions comments or run into issues, please post to the ([postgis-users][]) mailing list or the github issue tracker for this project.




[postgis-site]:   http://postgis.net/
[postgis-users]:  http://lists.osgeo.org/mailman/listinfo/postgis-users