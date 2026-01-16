<?php
include_once __DIR__ . '/conn.php';
ini_set('display_errors', '0');
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$user_id    = $_POST['user_id']    ?? null;
$journal_id = $_POST['journal_id'] ?? null;

if (!$user_id || !$journal_id) {
  echo json_encode(['success'=>false, 'message'=>'Missing parameters']);
  exit;
}

$sql = "DELETE FROM journals WHERE id = ? AND user_id = ?";
$stmt = $conn->prepare($sql);
if (!$stmt) {
  echo json_encode(['success'=>false, 'message'=>'Prepare failed: '.$conn->error]);
  exit;
}
$stmt->bind_param('ii', $journal_id, $user_id);
if ($stmt->execute()) {
  if ($stmt->affected_rows > 0) {
    echo json_encode(['success'=>true, 'message'=>'Journal deleted']);
  } else {
    echo json_encode(['success'=>false, 'message'=>'Not found or already deleted']);
  }
} else {
  echo json_encode(['success'=>false, 'message'=>'Execute failed: '.$stmt->error]);
}
$stmt->close();