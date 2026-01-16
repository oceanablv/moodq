<?php
include_once __DIR__ . '/conn.php';
ini_set('display_errors', '0');
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(['success'=>false, 'message'=>'Missing user_id']);
    exit;
}

$conn->begin_transaction();

try {
    $stmt = $conn->prepare("DELETE FROM journals WHERE user_id = ?");
    $stmt->bind_param('i', $user_id);
    $stmt->execute();
    $stmt->close();

    $stmt = $conn->prepare("DELETE FROM dass_results WHERE user_id = ?");
    $stmt->bind_param('i', $user_id);
    $stmt->execute();
    $stmt->close();

    $stmt = $conn->prepare("DELETE FROM practice_logs WHERE user_id = ?");
    $stmt->bind_param('i', $user_id);
    $stmt->execute();
    $stmt->close();

    $stmt = $conn->prepare("DELETE FROM moods WHERE user_id = ?");
    $stmt->bind_param('i', $user_id);
    $stmt->execute();
    $stmt->close();

    $stmt = $conn->prepare("DELETE FROM users WHERE id = ?");
    $stmt->bind_param('i', $user_id);
    $stmt->execute();
    $affected = $stmt->affected_rows;
    $stmt->close();

    $conn->commit();

    if ($affected > 0) {
        echo json_encode(['success'=>true, 'message'=>'Account and data deleted']);
    } else {
        echo json_encode(['success'=>false, 'message'=>'User not found']);
    }
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['success'=>false, 'message'=>'Error: '.$e->getMessage()]);
}