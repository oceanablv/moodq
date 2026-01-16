<?php
require_once __DIR__ . '/conn.php';

$email = isset($_POST['email']) ? trim($_POST['email']) : '';
if ($email === '') {
    echo json_encode(['success' => false, 'message' => 'Email required', 'exists' => false]);
    exit;
}

$stmt = $conn->prepare("SELECT id FROM users WHERE email = ? LIMIT 1");
if (!$stmt) {
    echo json_encode(['success' => false, 'message' => 'DB prepare failed', 'exists' => false]);
    exit;
}
$stmt->bind_param('s', $email);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    echo json_encode(['success' => true, 'message' => 'Email is registered. You can change password.', 'exists' => true]);
} else {
    echo json_encode(['success' => false, 'message' => 'Email not registered', 'exists' => false]);
}

$stmt->close();
$conn->close();