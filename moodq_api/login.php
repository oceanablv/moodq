<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

// Handle preflight request (Penting untuk Flutter Web)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}include 'conn.php';

$email = $_POST['email'];
$password = $_POST['password'];

$sql = "SELECT * FROM users WHERE email='$email'";
$result = $connect->query($sql);

if($result->num_rows > 0){
    $row = $result->fetch_assoc();
    if($password == $row['password']){ 
    echo json_encode([
        "success" => true, 
        "message" => "Login successful",
        "user" => [
            "id" => $row['id'],
            "name" => $row['name'],
            "email" => $row['email']
        ]
    ]);
    } else {
        echo json_encode(["success" => false, "message" => "Wrong password"]);
    }
    
} else {
    echo json_encode(["success" => false, "message" => "Email not found"]);
}
?>