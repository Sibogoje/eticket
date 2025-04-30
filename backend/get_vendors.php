<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include 'connection.php';

$sql = "SELECT name, surname, vendor_ticket_number, created_at FROM vendors";
$result = $conn->query($sql);

$vendors = [];
while ($row = $result->fetch_assoc()) {
    $vendors[] = $row;
}

echo json_encode($vendors);

$conn->close();
?>
