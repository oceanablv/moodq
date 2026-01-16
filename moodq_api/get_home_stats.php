<?php
// get_home_stats.php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json; charset=UTF-8");

include 'conn.php';

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(["success" => false, "message" => "User ID required"]);
    exit();
}

// 1. Hitung Total Entries
$sqlTotal = "SELECT COUNT(*) as total FROM moods WHERE user_id = ?";
$stmt = $conn->prepare($sqlTotal);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$resTotal = $stmt->get_result();
$rowTotal = $resTotal->fetch_assoc();
$totalEntries = $rowTotal['total'];

// 2. Ambil Mood Terakhir
$sqlLast = "SELECT mood_label, mood_intensity FROM moods WHERE user_id = ? ORDER BY created_at DESC LIMIT 1";
$stmtLast = $conn->prepare($sqlLast);
$stmtLast->bind_param("i", $user_id);
$stmtLast->execute();
$resLast = $stmtLast->get_result();

$lastLabel = "No Data";
$lastIntensity = 0.0;

if ($rowLast = $resLast->fetch_assoc()) {
    $lastLabel = $rowLast['mood_label'];
    $lastIntensity = (float)$rowLast['mood_intensity'];
}

// 3. Hitung Streak (Sederhana: Hitung hari unik)
// Logic streak bisa dikembangkan lebih lanjut, ini versi simple count hari unik
$sqlStreak = "SELECT COUNT(DISTINCT DATE(created_at)) as streak FROM moods WHERE user_id = ?";
$stmtStreak = $conn->prepare($sqlStreak);
$stmtStreak->bind_param("i", $user_id);
$stmtStreak->execute();
$resStreak = $stmtStreak->get_result();
$rowStreak = $resStreak->fetch_assoc();
$streak = $rowStreak['streak'];

// Return JSON sesuai format MoodModel di Flutter
echo json_encode([
    "user_id" => $user_id,
    "label" => $lastLabel,          // Sesuai MoodModel
    "intensity" => $lastIntensity,  // Sesuai MoodModel
    "totalEntries" => $totalEntries,// Sesuai MoodModel
    "streak" => $streak             // Sesuai MoodModel
]);

$conn->close();
?>