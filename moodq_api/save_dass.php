<?php
include 'conn.php';
$user_id = $_POST['user_id'];
$score = $_POST['score'];
$category = $_POST['category'];

$sql = "INSERT INTO dass_results (user_id, score, category) VALUES ('$user_id', '$score', '$category')";
if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false]);
}
?>