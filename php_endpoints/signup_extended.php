  <?php
  // htdocs/mabote_api/signup_extended.php
  require __DIR__ . '/db.php';

  $body = json_body();
  $first = trim($body['first_name'] ?? '');
  $last  = trim($body['last_name'] ?? '');
  $email = strtolower(trim($body['email'] ?? ''));
  $pass  = $body['password'] ?? '';
  $phone = trim($body['phone'] ?? '');
  $address = trim($body['address'] ?? '');
  $barangay = trim($body['barangay'] ?? '');
  $city = trim($body['city'] ?? '');

  if (!$first || !$last || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($pass) < 6) {
    respond(false, 'Invalid input');
  }

  $stmt = $mysqli->prepare('SELECT user_id FROM users WHERE email = ? LIMIT 1');
  $stmt->bind_param('s', $email);
  $stmt->execute();
  $stmt->store_result();
  if ($stmt->num_rows > 0) respond(false, 'Email already registered');
  $stmt->close();

  $hash = password_hash($pass, PASSWORD_BCRYPT);
  $qrId = 'QR' . strtoupper(bin2hex(random_bytes(8))); // Generate unique QR ID

  $stmt = $mysqli->prepare('INSERT INTO users (first_name, last_name, email, password_hash, phone, address, barangay, city, qr_id, is_active, total_points, created_at) VALUES (?,?,?,?,?,?,?,?,?,1,0,NOW())');
  $stmt->bind_param('sssssssss', $first, $last, $email, $hash, $phone, $address, $barangay, $city, $qrId);
  if (!$stmt->execute()) respond(false, 'Failed to create user');
  $userId = $stmt->insert_id;
  $stmt->close();

  // Create wallet row with 0 balance
  $stmt = $mysqli->prepare('INSERT INTO wallet (user_id, current_balance, is_active, wallet_status) VALUES (?,0,1,\'active\')');
  $stmt->bind_param('i', $userId);
  $stmt->execute();
  $stmt->close();

  // Generate session token for auto-login
  $token = bin2hex(random_bytes(32));
  
  // Save session data
  $stmt = $mysqli->prepare('INSERT INTO sessions (user_id, token, created_at, expires_at) VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY))');
  $stmt->bind_param('is', $userId, $token);
  $stmt->execute();
  $stmt->close();

  respond(true, 'Account created', [
    'user_id' => $userId, 
    'name' => $first . ' ' . $last,
    'email' => $email,
    'token' => $token,
    'qr_id' => $qrId
  ]);
