<?php
// File: htdocs/moodq_api/add_mood.php

// 1. Header CORS & JSON
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
header("Content-Type: application/json; charset=UTF-8");

// Agar error PHP tidak muncul sebagai HTML (penyebab token '<')
error_reporting(0); 

include 'conn.php';

// 2. Ambil Data
$user_id = $_POST['user_id'] ?? '';
$mood_label = $_POST['mood_label'] ?? '';
$mood_intensity = $_POST['mood_intensity'] ?? '';
$note = $_POST['note'] ?? '';

// 3. Cek Koneksi DB
if (!$conn) {
    echo json_encode(["success" => false, "message" => "Koneksi Database Gagal"]);
    exit();
}

// 4. Validasi Input
if (empty($user_id) || empty($mood_label)) {
    echo json_encode(["success" => false, "message" => "Data tidak lengkap (User ID/Label kosong)"]);
    exit();
}

// 5. Query Insert
$sql = "INSERT INTO moods (user_id, mood_label, mood_intensity, note) VALUES (?, ?, ?, ?)";
$stmt = $conn->prepare($sql);

// --- BAGIAN PENTING: CEK ERROR SQL ---
if (!$stmt) {
    // Jika prepare gagal (biasanya karena NAMA KOLOM SALAH), kirim errornya sebagai JSON
    echo json_encode([
        "success" => false, 
        "message" => "SQL Error (Cek Nama Kolom): " . $conn->error
    ]);
    exit();
}

$stmt->bind_param("isds", $user_id, $mood_label, $mood_intensity, $note);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Mood berhasil disimpan"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal Simpan: " . $stmt->error]);
}

$stmt->close();
$conn->close();
?>