<?php
include_once('config.inc.php');
header('Content-Type: image/png');

// validate parameters
foreach (array('sql', 'spatial_type', 'bvals') as $k) {
	if (!isset($_GET[$k])) $_GET[$k] = '';
	$_GET[$k] = trim($_GET[$k]);

	switch ($k) {
		case 'sql':
			if (!strlen($_GET[$k])) {
				$_GET[$k] = "ST_Buffer('MULTIPOINT((1 2),(3 4),(5 6))'::geometry,1)";
				$_GET['spatial_type'] = 'geometry';
			}
			break;
		case 'bvals':
			$_GET[$k] = explode(',', $_GET[$k]);
			$fn = create_function('&$v', '$v = intval(trim($v));$v = ($v < 0 ? 0 : ($v > 255 ? 1 : $v/255.0));'); /**x3d colors are in rgb where intensity is on scale of 0 to 1 **/
			array_walk($_GET[$k], $fn);
			break;
		case 'spatial_type':
			$_GET[$k] = strtolower($_GET[$k]);
			if (!in_array($_GET[$k], array('raw', 'geometry')))
				$_GET[$k] = 'geometry';
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
if ($_GET['spatial_type'] != 'raw')
	$sql = "SELECT postgis_viewer_x3d('" . pg_escape_string($dbconn, $_GET['sql']) . "', 'geometry', ARRAY[" . implode(',', $_GET['bvals']) . "])";
else
	$sql = "SELECT postgis_viewer_x3d('" . pg_escape_string($dbconn, $_GET['sql']) . "', 'raw')";
$result = pg_query($sql);
if ($result === false) return;

$row = pg_fetch_row($result);
pg_free_result($result);
if ($row === false) return;

echo $row[0];
?>
