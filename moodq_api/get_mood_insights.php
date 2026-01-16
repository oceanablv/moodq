<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'conn.php';

$user_id = $_GET['user_id'] ?? '';
$period  = strtolower($_GET['period'] ?? 'all');

if ($user_id === '') {
    echo json_encode([]);
    exit;
}

$sql = "SELECT 
            id,
            user_id,
            mood_label AS mood_label,
            mood_intensity AS mood_intensity,
            note,
            created_at
        FROM moods
        WHERE user_id = ?";

if ($period === 'week') {
    $sql .= " AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
} elseif ($period === 'month') {
    $sql .= " AND created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)";
} elseif ($period === 'year') {
    $sql .= " AND created_at >= DATE_SUB(NOW(), INTERVAL 1 YEAR)";
}

$sql .= " ORDER BY created_at ASC";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["error" => $conn->error]);
    exit;
}

$stmt->bind_param("i", $user_id);

if (!$stmt->execute()) {
    echo json_encode(["error" => $stmt->error]);
    exit;
}

$result = $stmt->get_result();
$moods = [];

while ($row = $result->fetch_assoc()) {
    $moods[] = $row;
}

echo json_encode($moods);
$conn->close();