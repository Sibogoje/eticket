import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'config.dart'; // Import the configuration file

class VendorRegistrationPage extends StatefulWidget {
  const VendorRegistrationPage({super.key});

  @override
  State<VendorRegistrationPage> createState() => _VendorRegistrationPageState();
}

class _VendorRegistrationPageState extends State<VendorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _productsController = TextEditingController();
  String? _stallSize;
  String? _eventDays;

  Future<void> _submitVendor() async {
    if (_formKey.currentState!.validate()) {
      final vendorTicketNumber = 'VENDOR-${Random().nextInt(900000) + 100000}'; // Generate unique vendor ticket number
      final url = Uri.parse('${Config.baseUrl}/save_vendor.php'); // Use Config.baseUrl
      final response = await http.post(
        url,
        body: {
          'vendor_ticket_number': vendorTicketNumber,
          'name': _nameController.text,
          'surname': _surnameController.text,
          'products': _productsController.text,
          'stall_size': _stallSize ?? '',
          'event_days': _eventDays ?? '',
        },
      );

      if (response.statusCode == 200) {
        _showVendorDialog(vendorTicketNumber);

        // Clear text fields and reset state variables
        _nameController.clear();
        _surnameController.clear();
        _productsController.clear();
        setState(() {
          _stallSize = null;
          _eventDays = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save vendor details.')),
        );
      }
    }
  }

  void _showVendorDialog(String vendorTicketNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vendor Registered Successfully'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Vendor Ticket Number: $vendorTicketNumber'),
                const SizedBox(height: 10),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: QrImageView(
                    data: vendorTicketNumber, // QR code data
                    version: QrVersions.auto,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please screenshot this QR code for your vendor ticket.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Vendor Details', style: TextStyle(fontSize: 18)),
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
                  controller: _productsController,
                  decoration: const InputDecoration(labelText: 'Products to be Sold'),
                  validator: (value) => value!.isEmpty ? 'Products are required' : null,
                ),
                const SizedBox(height: 20),
                const Text('Select Stall Size', style: TextStyle(fontSize: 18)),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Stall Size'),
                  items: const [
                    DropdownMenuItem(value: 'Small', child: Text('Small')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'Large', child: Text('Large')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _stallSize = value;
                    });
                  },
                  validator: (value) => value == null ? 'Stall size is required' : null,
                ),
                const SizedBox(height: 20),
                const Text('Select Event Days', style: TextStyle(fontSize: 18)),
                RadioListTile<String>(
                  title: const Text('First Day'),
                  value: 'First Day',
                  groupValue: _eventDays,
                  onChanged: (value) {
                    setState(() {
                      _eventDays = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Second Day'),
                  value: 'Second Day',
                  groupValue: _eventDays,
                  onChanged: (value) {
                    setState(() {
                      _eventDays = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Both Days'),
                  value: 'Both Days',
                  groupValue: _eventDays,
                  onChanged: (value) {
                    setState(() {
                      _eventDays = value;
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
                      onPressed: _submitVendor,
                      child: const Text(
                        'Register Vendor',
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
