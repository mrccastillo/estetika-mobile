import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:estetika_ui/widgets/custom_app_bar.dart';
import 'package:estetika_ui/screens/send_project_screen.dart';
import 'package:estetika_ui/screens/project_detail_screen.dart';
import 'package:intl/intl.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _selectedButtonIndex = 1; // 1 for Projects selected

  List<Map<String, dynamic>> _projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString == null) return;
      final user = jsonDecode(userString);
      final userId = user['id'];

      final response = await http.get(
        Uri.parse(
            'https://capstone-thl5.onrender.com/api/project?projectCreator=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${prefs.getString('token') ?? ''}',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['project'] ?? [];
        setState(() {
          _projects = data.cast<Map<String, dynamic>>();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load projects. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error fetching projects: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        showBackButton: false,
        actions: [],
        title: '',
      ),
      body: Column(
        children: [
          // Navigation buttons row
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 24.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNavButton(0, 'Home'),
                const SizedBox(width: 16),
                _buildNavButton(1, 'Projects'),
              ],
            ),
          ),

          // Projects list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailScreen(
                          project: _projects[index],
                        ),
                      ),
                    );
                  },
                  child: _buildProjectCard(_projects[index]),
                );
              },
            ),
          ),

          // Send Project Proposal button
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: SizedBox(
              width: double.infinity,
              height: 60.0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SendProjectScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203B32),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Send Project Proposal',
                  style: TextStyle(
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(int index, String title) {
    bool isSelected = _selectedButtonIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedButtonIndex = index;
        });
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff203B32) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    // Derive status from tasks
    List<dynamic> tasks = project['tasks'] ?? [];
    String status = 'Pending';

    if (tasks.isNotEmpty) {
      bool allCompleted = tasks.every((t) => t['status'] == 'completed');
      bool anyInProgress = tasks.any((t) => t['status'] == 'in-progress');
      if (allCompleted) {
        status = 'Completed';
      } else if (anyInProgress) {
        status = 'On Going';
      } else {
        status = 'Pending';
      }
    }

    Color statusColor;
    switch (status) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'On Going':
        statusColor = Colors.blue;
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }

    final String title = project['title'] ?? 'No Title';
    final String description = project['description'] ?? '';
    final int budget = project['budget'] ?? 0;
    final String startDate = project['startDate'] != null
        ? project['startDate'].toString().substring(0, 10)
        : 'N/A';
    final String endDate = project['endDate'] != null
        ? project['endDate'].toString().substring(0, 10)
        : 'N/A';
    final double progress = (project['progress'] ?? 0).toDouble();

    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '$status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Room Type: ${project['roomType'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Budget: ${currencyFormat.format(budget)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start: $startDate   End: $endDate',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    color: Colors.green,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Progress: ${progress.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
