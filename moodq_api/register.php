<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include 'conn.php';

$name = $_POST['name'];
$email = $_POST['email'];
$password = $_POST['password']; // Password plain text sesuai request sebelumnya

// 1. Terima data goals (dikirim sebagai JSON String dari Flutter)
$goals = isset($_POST['goals']) ? json_decode($_POST['goals']) : [];

// 2. Cek Email Duplikat
$check = $connect->query("SELECT * FROM users WHERE email='$email'");

if($check->num_rows > 0){
    echo json_encode(["success" => false, "message" => "Email already exists"]);
} else {
    // 3. Insert User Baru
    $sql = "INSERT INTO users (name, email, password) VALUES ('$name', '$email', '$password')";
    
    if($connect->query($sql)){
        // 4. Ambil ID User yang baru saja dibuat
        $new_user_id = $connect->insert_id;

        // 5. Insert Goals ke tabel user_goals
        if (!empty($goals)) {
            foreach ($goals as $goal_title) {
                // Bersihkan string agar aman
                $safe_title = $connect->real_escape_string($goal_title);
                
                $sql_goal = "INSERT INTO user_goals (user_id, goal_title) VALUES ('$new_user_id', '$safe_title')";
                $connect->query($sql_goal);
            }
        }

        echo json_encode(["success" => true, "message" => "Registration & Goals saved!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Registration failed"]);
    }
}
?>