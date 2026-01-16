<?php
require_once __DIR__ . '/conn.php';

$USE_HASH = false; // ubah ke true jika ingin hashing

$email = isset($_POST['email']) ? trim($_POST['email']) : '';
$new_password = isset($_POST['new_password']) ? $_POST['new_password'] : '';

if ($email === '' || $new_password === '') {
    echo json_encode(['success' => false, 'message' => 'Missing parameters']);
    exit;
}

if ($USE_HASH) {
    $pass_to_store = password_hash($new_password, PASSWORD_DEFAULT);
} else {
    $pass_to_store = $new_password;
}

$stmt = $conn->prepare("UPDATE users SET password = ? WHERE email = ?");
if (!$stmt) {
    echo json_encode(['success' => false, 'message' => 'DB prepare failed']);
    exit;
}
$stmt->bind_param('ss', $pass_to_store, $email);
$ok = $stmt->execute();

if ($ok && $stmt->affected_rows > 0) {
    echo json_encode(['success' => true, 'message' => 'Password updated']);
} else {
    echo json_encode(['success' => false, 'message' => 'Failed to update password']);
}

$stmt->close();
$conn->close();