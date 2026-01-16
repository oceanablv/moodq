<?php
include 'conn.php';
$user_id = $_POST['user_id'];
$practice_name = $_POST['practice_name'];
$duration = $_POST['duration_seconds'];
$status = $_POST['status'];

$sql = "INSERT INTO practice_logs (user_id, practice_name, duration_seconds, status) VALUES ('$user_id', '$practice_name', '$duration', '$status')";
if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false]);
}
?>