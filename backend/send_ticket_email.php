<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    if (empty($email) || !isset($_FILES['ticket_pdf'])) {
        echo json_encode(['success' => false, 'message' => 'Invalid request.']);
        exit;
    }

    $ticketPdf = $_FILES['ticket_pdf']['tmp_name'];
    $ticketPdfName = $_FILES['ticket_pdf']['name'];

    $fromEmail = 'technoprintinvestments@gmail.com'; // Replace with your Gmail address
    $fromName = 'E-Ticket System';
    $subject = 'Your Ticket';
    $body = 'Please find your ticket attached.';

    // Configure SMTP settings
    ini_set('SMTP', 'smtp.gmail.com');
    ini_set('smtp_port', '587');
    ini_set('sendmail_from', $fromEmail);
    ini_set('sendmail_path', '/usr/sbin/sendmail -t -i -f ' . $fromEmail);

    // Read the PDF file content
    $fileContent = file_get_contents($ticketPdf);
    $encodedFile = chunk_split(base64_encode($fileContent));

    // Generate a boundary string
    $boundary = md5(time());

    // Email headers
    $headers = "From: $fromName <$fromEmail>\r\n";
    $headers .= "MIME-Version: 1.0\r\n";
    $headers .= "Content-Type: multipart/mixed; boundary=\"$boundary\"\r\n";

    // Email body
    $message = "--$boundary\r\n";
    $message .= "Content-Type: text/plain; charset=UTF-8\r\n";
    $message .= "Content-Transfer-Encoding: 7bit\r\n\r\n";
    $message .= "$body\r\n";
    $message .= "--$boundary\r\n";
    $message .= "Content-Type: application/pdf; name=\"$ticketPdfName\"\r\n";
    $message .= "Content-Transfer-Encoding: base64\r\n";
    $message .= "Content-Disposition: attachment; filename=\"$ticketPdfName\"\r\n\r\n";
    $message .= "$encodedFile\r\n";
    $message .= "--$boundary--";

    // Send the email
    if (mail($email, $subject, $message, $headers)) {
        echo json_encode(['success' => true, 'message' => 'Email sent successfully.']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to send email.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}
?>
