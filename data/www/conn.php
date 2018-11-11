<?php
$connect = mysql_connect("mysql", "root", "123456") or die("Unable to connect to MySQL.");
mysql_select_db("mysql") or die("Could not open the database.");
$showtablequery = "SHOW TABLES FROM mysql;";
$query_result = mysql_query($showtablequery);

while ($row = mysql_fetch_array($query_result)) {
		    echo $row[0] . "<br />\n";
}
