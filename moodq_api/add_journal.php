<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
header("Content-Type: application/json; charset=UTF-8");
include 'conn.php';

// Ambil data POST
$user_id = $_POST['user_id'] ?? '';
$title   = $_POST['title'] ?? '';
$content = $_POST['content'] ?? '';
$tags    = $_POST['tags'] ?? ''; // Opsional

if (empty($user_id) || empty($title) || empty($content)) {
    echo json_encode(["success" => false, "message" => "Judul dan Isi tidak boleh kosong"]);
    exit();
}

// Insert ke tabel 'journals'
$sql = "INSERT INTO journals (user_id, title, content, tags) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($sql);

if ($stmt) {
    $stmt->bind_param("isss", $user_id, $title, $content, $tags);
    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "Jurnal berhasil disimpan"]);
    } else {
        echo json_encode(["success" => false, "message" => "Gagal Simpan: " . $stmt->error]);
    }
} else {
    echo json_encode(["success" => false, "message" => "SQL Error: " . $conn->error]);
}
$conn->close();
?>