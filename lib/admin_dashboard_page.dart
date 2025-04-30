import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:graphic/graphic.dart'; // Add this for charts
import 'config.dart'; // Import the configuration file

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  bool _isLoggedIn = false;
  late TabController _tabController;
  List<Map<String, dynamic>> _vendors = [];
  List<Map<String, dynamic>> _tickets = [];
  Map<String, int> _ticketsByGender = {};
  Map<String, int> _ticketsByAgeRange = {};
  int _vendorCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoginDialog();
    });
  }

  Future<void> _fetchVendors() async {
    final url = Uri.parse('${Config.baseUrl}/get_vendors.php'); // Use Config.baseUrl
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _vendors = List<Map<String, dynamic>>.from(json.decode(response.body));
        _vendorCount = _vendors.length; // Count vendors
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch vendors.')),
      );
    }
  }

  Future<void> _fetchTickets() async {
    final url = Uri.parse('${Config.baseUrl}/get_tickets.php'); // Use Config.baseUrl
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _tickets = List<Map<String, dynamic>>.from(json.decode(response.body));
        _processTicketData(); // Process ticket data for charts
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch tickets.')),
      );
    }
  }

  void _processTicketData() {
    // Reset data
    _ticketsByGender = {'Male': 0, 'Female': 0, 'Other': 0};
    _ticketsByAgeRange = {'0-17': 0, '18-35': 0, '36-50': 0, '51+': 0};

    for (var ticket in _tickets) {
      // Count by gender
      if (_ticketsByGender.containsKey(ticket['gender'])) {
        _ticketsByGender[ticket['gender']] = _ticketsByGender[ticket['gender']]! + 1;
      }

      // Count by age range
      int age = int.tryParse(ticket['age'].toString()) ?? 0;
      if (age <= 17) {
        _ticketsByAgeRange['0-17'] = _ticketsByAgeRange['0-17']! + 1;
      } else if (age <= 35) {
        _ticketsByAgeRange['18-35'] = _ticketsByAgeRange['18-35']! + 1;
      } else if (age <= 50) {
        _ticketsByAgeRange['36-50'] = _ticketsByAgeRange['36-50']! + 1;
      } else {
        _ticketsByAgeRange['51+'] = _ticketsByAgeRange['51+']! + 1;
      }
    }
  }

  Future<void> _showLoginDialog() async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Admin Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final username = usernameController.text;
                final password = passwordController.text;

                final url = Uri.parse('${Config.baseUrl}/admin_login.php'); // Use Config.baseUrl
                final response = await http.post(
                  url,
                  body: {
                    'username': username,
                    'password': password,
                  },
                );

                if (response.statusCode == 200 && response.body.contains('"success":true')) {
                  setState(() {
                    _isLoggedIn = true;
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  _fetchVendors(); // Fetch vendors after login
                  _fetchTickets(); // Fetch tickets after login
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid credentials.')),
                  );
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(); // Navigate back only if possible
                }
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Vendor List'),
            Tab(text: 'Ticket List'),
            Tab(text: 'Charts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVendorList(),
          _buildTicketList(),
          _buildCharts(),
        ],
      ),
    );
  }

  Widget _buildVendorList() {
    return ListView.builder(
      itemCount: _vendors.length,
      itemBuilder: (context, index) {
        final vendor = _vendors[index];
        return ListTile(
          title: Text('${vendor['name']} ${vendor['surname']}'),
          subtitle: Text('Ticket: ${vendor['vendor_ticket_number']}'),
          trailing: Text(vendor['created_at']),
        );
      },
    );
  }

  Widget _buildTicketList() {
    return ListView.builder(
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        return ListTile(
          title: Text('${ticket['name']} ${ticket['surname']}'),
          subtitle: Text('Ticket: ${ticket['ticket_number']}'),
          trailing: Text(ticket['created_at']),
        );
      },
    );
  }

  Widget _buildCharts() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Tickets by Gender', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: Chart(
              data: _ticketsByGender.entries.map((entry) => {'gender': entry.key, 'count': entry.value}).toList(),
              variables: {
                'gender': Variable(accessor: (Map<String, dynamic> map) => map['gender'] as String),
                'count': Variable(accessor: (Map<String, dynamic> map) => map['count'] as num),
              },
              marks: [
                IntervalMark(
                  position: Varset('gender') * Varset('count'),
                ),
              ],
              axes: [
                Defaults.horizontalAxis,
                Defaults.verticalAxis,
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Tickets by Age Range', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: Chart(
              data: _ticketsByAgeRange.entries.map((entry) => {'ageRange': entry.key, 'count': entry.value}).toList(),
              variables: {
                'ageRange': Variable(accessor: (Map<String, dynamic> map) => map['ageRange'] as String),
                'count': Variable(accessor: (Map<String, dynamic> map) => map['count'] as num),
              },
              marks: [
                IntervalMark(
                  position: Varset('ageRange') * Varset('count'),
                ),
              ],
              axes: [
                Defaults.horizontalAxis,
                Defaults.verticalAxis,
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Vendors Count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: Chart(
              data: [
                {'category': 'Vendors', 'count': _vendorCount}
              ],
              variables: {
                'category': Variable(accessor: (Map<String, dynamic> map) => map['category'] as String),
                'count': Variable(accessor: (Map<String, dynamic> map) => map['count'] as num),
              },
              marks: [
                IntervalMark(
                  position: Varset('category') * Varset('count'),
                ),
              ],
              axes: [
                Defaults.horizontalAxis,
                Defaults.verticalAxis,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
