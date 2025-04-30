<?php
$servername = "195.35.53.20";
$username = "u747325399_eTicket";
$password = "eTicket_123";
$dbname = "u747325399_eTicket";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
