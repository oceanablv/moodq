<?php
header("Content-Type: application/json");
include 'conn.php';

$queryResult = $connect->query("SELECT * FROM mood_entries ORDER BY date DESC");
$result = array();

while($fetchData = $queryResult->fetch_assoc()){
    $result[] = $fetchData;
}

echo json_encode($result);
?>