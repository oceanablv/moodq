<?php
include_once __DIR__ . '/conn.php';
ini_set('display_errors', '0');
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$user_id    = $_POST['user_id']    ?? null;
$mood_id    = $_POST['mood_id']    ?? null;
$label      = $_POST['mood_label'] ?? ($_POST['label'] ?? '');
$intensity  = isset($_POST['mood_intensity']) ? floatval($_POST['mood_intensity']) : null;
$note       = $_POST['note']       ?? '';

if (!$user_id || !$mood_id || $intensity === null) {
    echo json_encode(['success'=>false, 'message'=>'Missing parameters']);
    exit;
}

$sql = "UPDATE moods SET mood_label = ?, mood_intensity = ?, note = ? WHERE id = ? AND user_id = ?";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(['success'=>false, 'message'=>'Prepare failed: '.$conn->error]);
    exit;
}
$stmt->bind_param('sdsii', $label, $intensity, $note, $mood_id, $user_id);
if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(['success'=>true, 'message'=>'Mood updated']);
    } else {
        echo json_encode(['success'=>false, 'message'=>'No rows updated (maybe not found or no changes)']);
    }
} else {
    echo json_encode(['success'=>false, 'message'=>'Execute failed: '.$stmt->error]);
}
$stmt->close();