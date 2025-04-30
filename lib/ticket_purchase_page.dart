import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart';
import 'config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class TicketPurchasePage extends StatefulWidget {
  const TicketPurchasePage({super.key});

  @override
  State<TicketPurchasePage> createState() => _TicketPurchasePageState();
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _gender;
  String? _selectedDay;

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      final ticketNumber = 'LUJU-${Random().nextInt(900000) + 100000}';
      final ticketDetails = {
        'ticket_number': ticketNumber,
        'name': _nameController.text,
        'surname': _surnameController.text,
        'phone_number': _phoneController.text,
        'email': _emailController.text,
        'gender': _gender ?? '',
        'age': _ageController.text,
        'ticket_type': _selectedDay ?? '',
      };

      final url = Uri.parse('${Config.baseUrl}/save_ticket.php');
      final response = await http.post(
        url,
        body: ticketDetails,
      );

      if (response.statusCode == 200) {
        _showTicketDialog(ticketDetails);
        await _generateAndSendPdf(ticketDetails);

        _nameController.clear();
        _surnameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _ageController.clear();
        setState(() {
          _gender = null;
          _selectedDay = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save ticket.')),
        );
      }
    }
  }

  void _showTicketDialog(Map<String, String> ticketDetails) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ticket Saved Successfully'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ticket Number: ${ticketDetails['ticket_number']}'),
                const SizedBox(height: 10),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: QrImageView(
                    data: ticketDetails.toString(),
                    version: QrVersions.auto,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please screenshot this QR code for your ticket.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndSendPdf(Map<String, String> ticketDetails) async {
    final pdf = pw.Document();

    try {
      // Check if the font file exists
      final fontPath = 'assets/Roboto-Regular.ttf';
      final fontExists = await rootBundle.load(fontPath).then((_) => true).catchError((_) => false);

      if (!fontExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Roboto font not found. Using fallback font.')),
        );
      }

      // Load the custom font or fallback to a built-in font
      final ttf = fontExists
          ? pw.Font.ttf(await rootBundle.load(fontPath))
          : pw.Font.helvetica(); // Fallback to Helvetica if Roboto is missing

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Ticket Details', style: pw.TextStyle(font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Ticket Number: ${ticketDetails['ticket_number']}', style: pw.TextStyle(font: ttf)),
                pw.Text('Name: ${ticketDetails['name']}', style: pw.TextStyle(font: ttf)),
                pw.Text('Surname: ${ticketDetails['surname']}', style: pw.TextStyle(font: ttf)),
                pw.Text('Phone Number: ${ticketDetails['phone_number']}', style: pw.TextStyle(font: ttf)),
                pw.Text('Email: ${ticketDetails['email']}', style: pw.TextStyle(font: ttf)),
                pw.Text('Gender: ${ticketDetails['gender']}', style: pw.TextStyle(font: ttf)),
                pw.Text('Age: ${ticketDetails['age']}', style: pw.TextStyle(font: ttf)),
                pw.Text('Ticket Type: ${ticketDetails['ticket_type']}', style: pw.TextStyle(font: ttf)),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: ticketDetails.toString(),
                    width: 150,
                    height: 150,
                  ),
                ),
              ],
            );
          },
        ),
      );

      if (kIsWeb) {
        final pdfBytes = await pdf.save();
        await _sendPdfToBackend(ticketDetails['email']!, pdfBytes);
      } else {
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/ticket.pdf');
        await file.writeAsBytes(await pdf.save());
        await _sendPdfToBackend(ticketDetails['email']!, await file.readAsBytes());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: $e')),
      );
    }
  }

  Future<void> _sendPdfToBackend(String email, Uint8List pdfBytes) async {
    final emailUrl = Uri.parse('${Config.baseUrl}/send_ticket_email.php');
    final request = http.MultipartRequest('POST', emailUrl);
    request.fields['email'] = email;
    request.files.add(http.MultipartFile.fromBytes('ticket_pdf', pdfBytes, filename: 'ticket.pdf'));

    final emailResponse = await request.send();
    if (emailResponse.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket sent to email successfully.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send ticket to email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Tickets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Attendee Details', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                  validator: (value) => value!.isEmpty ? 'Surname is required' : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? 'Email is required' : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                  validator: (value) => value == null ? 'Gender is required' : null,
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Age is required' : null,
                ),
                const SizedBox(height: 20),
                const Text('Select Ticket Type', style: TextStyle(fontSize: 18)),
                RadioListTile<String>(
                  title: const Text('First Day'),
                  value: 'First Day',
                  groupValue: _selectedDay,
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Second Day'),
                  value: 'Second Day',
                  groupValue: _selectedDay,
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Both Days'),
                  value: 'Both Days',
                  groupValue: _selectedDay,
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width < 600
                        ? double.infinity
                        : MediaQuery.of(context).size.width * 0.4,
                    child: ElevatedButton(
                      onPressed: _submitTicket,
                      child: const Text(
                        'Purchase Ticket',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
