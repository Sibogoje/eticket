<?php
header("Access-Control-Allow-Origin: *"); // Allow requests from any origin
header("Access-Control-Allow-Methods: POST"); // Allow only POST requests
header("Access-Control-Allow-Headers: Content-Type"); // Allow specific headers

include 'connection.php'; // Include the reusable connection file

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Retrieve data from the POST request
    $vendor_ticket_number = $_POST['vendor_ticket_number'] ?? '';
    $name = $_POST['name'] ?? '';
    $surname = $_POST['surname'] ?? '';
    $products = $_POST['products'] ?? '';
    $stall_size = $_POST['stall_size'] ?? '';
    $event_days = $_POST['event_days'] ?? '';

    // Validate required fields
    if (empty($vendor_ticket_number) || empty($name) || empty($surname) || empty($products) || empty($stall_size) || empty($event_days)) {
        echo json_encode(['success' => false, 'message' => 'All fields are required.']);
        exit;
    }

    // Prepare and execute the SQL statement
    $stmt = $conn->prepare("INSERT INTO vendors (vendor_ticket_number, name, surname, products, stall_size, event_days) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("ssssss", $vendor_ticket_number, $name, $surname, $products, $stall_size, $event_days);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Vendor registered successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to register vendor.']);
    }

    $stmt->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}

$conn->close();
?>
