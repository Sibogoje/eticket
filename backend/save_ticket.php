<?php
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST"); // Allow only POST requests
header("Access-Control-Allow-Headers: Content-Type"); // Allow specific headers

include 'connection.php'; // Include the reusable connection file

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Retrieve data from the POST request
    $ticket_number = $_POST['ticket_number'] ?? '';
    $name = $_POST['name'] ?? '';
    $surname = $_POST['surname'] ?? '';
    $phone_number = $_POST['phone_number'] ?? '';
    $email = $_POST['email'] ?? '';
    $gender = $_POST['gender'] ?? '';
    $age = $_POST['age'] ?? 0;
    $ticket_type = $_POST['ticket_type'] ?? '';

    // Validate required fields
    if (empty($ticket_number) || empty($name) || empty($surname) || empty($phone_number) || empty($email) || empty($gender) || empty($ticket_type)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit;
    }

    // Debugging: Log input data
    file_put_contents('debug.log', "Input Data: " . json_encode($_POST) . "\n", FILE_APPEND);

    // Prepare and execute the SQL statement
    $stmt = $conn->prepare("INSERT INTO tickets (ticket_number, name, surname, phone_number, email, gender, age, ticket_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        echo json_encode(['success' => false, 'message' => 'Failed to prepare statement: ' . $conn->error]);
        exit;
    }

    $stmt->bind_param("ssssssss", $ticket_number, $name, $surname, $phone_number, $email, $gender, $age, $ticket_type);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Ticket saved successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to save ticket: ' . $stmt->error]);
    }

    $stmt->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}

$conn->close();
?>
