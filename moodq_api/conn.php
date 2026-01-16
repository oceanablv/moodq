<?php
// conn.php - koneksi universal, jangan keluarkan HTML atau whitespace

// Nonaktifkan tampilan error HTML (tapi tetap bisa log)
ini_set('display_errors', '0');
error_reporting(0);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$host = "localhost";
$user = "root";
$pass = "";
$db   = "moodq_db";

$connect = new mysqli($host, $user, $pass, $db);
$conn = $connect;

if ($connect->connect_error) {
    // kembalikan JSON dan exit — jangan keluarkan HTML
    echo json_encode(["success" => false, "message" => "Koneksi Gagal: " . $connect->connect_error]);
    exit;
}

// pastikan charset
$connect->set_charset('utf8mb4');