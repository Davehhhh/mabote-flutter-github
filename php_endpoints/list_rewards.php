<?php
// Suppress any HTML output
ob_start();
require __DIR__ . '/db.php';
ob_end_clean();

$stmt = $mysqli->prepare('
  SELECT reward_id, reward_name, description, points_required, quantity_available, category, reward_image, is_active
  FROM reward
  WHERE is_active = 1 AND quantity_available > 0
  ORDER BY points_required ASC
');
$stmt->execute();
$result = $stmt->get_result();
$rewards = [];
while ($row = $result->fetch_assoc()) {
  $rewards[] = $row;
}
$stmt->close();

// Return rewards data at root level for Flutter compatibility
$response = [
    'success' => true,
    'message' => 'OK',
    'rewards' => $rewards
];

header('Content-Type: application/json');
echo json_encode($response);
exit;
?>
