<?php
include_once __DIR__ . '/conn.php';
ini_set('display_errors', '0');
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$user_id   = $_POST['user_id']   ?? null;
$journal_id= $_POST['journal_id']?? null;
$title     = $_POST['title']     ?? '';
$content   = $_POST['content']   ?? '';
$tags      = $_POST['tags']      ?? '';
$is_private= isset($_POST['is_private']) ? ($_POST['is_private'] == '1' ? 1 : 0) : 0;

if (!$user_id || !$journal_id) {
    echo json_encode(['success'=>false, 'message'=>'Missing parameters']);
    exit;
}

$sql = "UPDATE journals SET title = ?, content = ?, tags = ?, is_private = ? WHERE id = ? AND user_id = ?";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(['success'=>false, 'message'=>'Prepare failed: '.$conn->error]);
    exit;
}
$stmt->bind_param('sssiii', $title, $content, $tags, $is_private, $journal_id, $user_id);
if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode(['success'=>true, 'message'=>'Journal updated']);
    } else {
        echo json_encode(['success'=>false, 'message'=>'No rows updated (maybe not found or no changes)']);
    }
} else {
    echo json_encode(['success'=>false, 'message'=>'Execute failed: '.$stmt->error]);
}
$stmt->close();