<?php
include_once('config.inc.php');
header('Content-Type: image/png');
$vals = array();
// validate parameters
foreach (array('sql', 'spatial_type', 'bvals') as $k) {
	if (!isset($_REQUEST[$k])) $_REQUEST[$k] = '';
	$_REQUEST[$k] = trim($_REQUEST[$k]);
	//print_r($_REQUEST);
	switch ($k) {
		case 'sql':
			if (!strlen($_REQUEST[$k])) {
				$vals[$k] = "ST_Buffer('MULTIPOINT((1 2),(3 4),(5 6))'::geometry,1)";
				$vals['spatial_type'] = 'geometry';
			}
			else {
				$vals[$k] = $_REQUEST[$k];
			}
			break;
		case 'bvals':
			$bvals = explode(',', $_REQUEST[$k]);
			$cvals = array();
			/**x3d colors are in rgb where intensity is on scale of 0 to 1 **/
			function map_to_1($v) { $v = floatval(trim($v));$v = ($v < 0 ? 0 : ($v > 255 ? 1 : $v/255.0));};
			for ($x = 0; $x <= 2; $x++) {
			  $v = floatval(trim($bvals[$x]));
			  $v = ($v < 0 ? 0 : ($v > 255 ? 1 : $v/255.0));
			  $cvals[$x] = $v;
			}  
			$vals[$k] = $cvals;
			break;
		case 'spatial_type':
			$vals[$k] = strtolower($_REQUEST[$k]);
			if (!in_array($vals[$k], array('raw', 'geometry')))
				$vals[$k] = 'geometry';
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
if ($vals['spatial_type'] != 'raw')
	$sql = "SELECT postgis_viewer_x3d('" . pg_escape_string($dbconn, $vals['sql']) . "', 'geometry', ARRAY[" . implode(',', $vals['bvals']) . "])";
else 
	$sql = "SELECT postgis_viewer_x3d('" . pg_escape_string($dbconn, $vals['sql']) . "', 'raw')";

//echo $sql;
$result = pg_query($sql);
if ($result === false) return;

$row = pg_fetch_row($result);
pg_free_result($result);
if ($row === false) return;

echo $row[0];
?>
