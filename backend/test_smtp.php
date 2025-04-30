<?php
require 'PHPMailer/PHPMailer.php';
require 'PHPMailer/SMTP.php';
require 'PHPMailer/Exception.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

$mail = new PHPMailer(true);

try {
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'lujufest@gmail.com';
    $mail->Password = 'Luju@2025';
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    $mail->setFrom('no-reply@eticket.com', 'E-Ticket System');
    $mail->addAddress('recipient@example.com'); // Replace with your email address

    $mail->Subject = 'SMTP Test';
    $mail->Body = 'This is a test email.';

    $mail->send();
    echo 'Test email sent successfully.';
} catch (Exception $e) {
    echo 'Test email failed. Error: ' . $mail->ErrorInfo;
}
?>
