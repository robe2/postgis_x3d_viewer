--version 0.1 --
CREATE OR REPLACE FUNCTION postgis_viewer_x3d(param_sql text, param_spatial_type text DEFAULT 'geometry'::text, param_rgb float8[] DEFAULT '{0,0,0}'::float8[])
  RETURNS text AS
$$
  DECLARE var_result text;
  DECLARE var_geom geometry;
  DECLARE var_sql text := trim(trim(param_sql), ';'); --get rid of trailing spaces and ;
  BEGIN
      IF param_spatial_type = 'geometry' THEN
		EXECUTE 'WITH data AS (SELECT (' || var_sql || ') AS geom ) SELECT geom FROM data;' INTO STRICT var_geom;
		
        SELECT '<Transform>
<Shape><Appearance containerField=''appearance''>
   <Material 
    containerField=''material''
    ambientIntensity=''0.200''
    shininess=''0.200''
    diffuseColor=''' || array_to_string(param_rgb,' ') || '''/>
  </Appearance> ' || ST_AsX3D(var_geom) ||
'</Shape>
</Transform>' INTO STRICT var_result ;
	  ELSE -- assume raw
		EXECUTE var_sql INTO STRICT var_result;
      END IF;
      RETURN var_result;
 END ;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;



/** SELECt postgis_viewer_x3d('SELECT ST_Buffer(''MULTIPOINT((1 2),(3 4),(5 6))''::geometry,1)');

SELECt postgis_viewer_x3d('SELECT ST_Extrude(ST_Buffer(''MULTIPOINT((1 2),(3 4),(5 6))''::geometry,20),0,0,50)');

SELECT ST_Extrude(ST_Buffer('MULTIPOINT((1 2),(3 4),(5 6))'::geometry,20),0,0,50);  **/


