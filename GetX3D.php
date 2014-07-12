<?php
include_once('config.inc.php');
//header('Content-Type: application/x3d');

// validate parameters
foreach (array('sql', 'spatial_type', 'bvals') as $k) {
	if (!isset($_REQUEST[$k])) $_REQUEST[$k] = '';
	$_REQUEST[$k] = trim($_REQUEST[$k]);

	switch ($k) {
		case 'sql':
			if (!strlen($_REQUEST[$k])) {
				$_REQUEST[$k] = "ST_Buffer('MULTIPOINT((1 2),(3 4),(5 6))'::geometry,1)";
				$_REQUEST['spatial_type'] = 'geometry';
			}
			break;
		case 'bvals':
			$_REQUEST[$k] = explode(',', $_REQUEST[$k]);
			$fn = create_function('&$v', '$v = intval(trim($v));$v = ($v < 0 ? 0 : ($v > 255 ? 1 : $v/255.0));'); /**x3d colors are in rgb where intensity is on scale of 0 to 1 **/
			array_walk($_REQUEST[$k], $fn);
			break;
		case 'spatial_type':
			$_REQUEST[$k] = strtolower($_REQUEST[$k]);
			if (!in_array($_REQUEST[$k], array('raw', 'geometry')))
				$_REQUEST[$k] = 'geometry';
			break;
	}
}

// assemble connection string
$conn_str = array();
foreach ($conn as $k => $v) {
	if (!strlen(trim($v))) continue;
	$conn_str[] = $k . '=' . trim($v);
}
$conn_str = implode(' ', $conn_str);

$dbconn = pg_connect($conn_str);
if ($dbconn === false) return;

// do query
if ($_REQUEST['spatial_type'] != 'raw') {
	$sql = "SELECT postgis_viewer_x3d($1, $2, '{" . implode(',', $_REQUEST['bvals'] ) . "}'::float8[]);";
 // $result = pg_query_params($dbconn, $sql, array($_REQUEST['sql'], 'geometry',  '{' . implode(',', $_REQUEST['bvals'] ) . '}::float8[]') );
}
else {
	$sql = "SELECT postgis_viewer_x3d($1, $2);";
	
}
/** stripslahes may not be needed but for some reason output getting back on mine has slashes which is a problem for newer postgresql **/
$result = pg_query_params($dbconn, $sql, array(stripslashes($_REQUEST['sql']), $_REQUEST['spatial_type']) );
if ($result === false) return;

$row = pg_fetch_array($result);
pg_free_result($result);
if ($row === false) return;

echo $row[0];
?>
