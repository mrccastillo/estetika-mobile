import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String status;
  final String location;
  final String year;
  final VoidCallback? onTap;
  
  const ProjectCard({
    super.key,
    required this.title,
    required this.status,
    required this.location,
    required this.year,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    // Set status color based on status value
    Color statusColor;
    String displayStatus = status;
    
    // Replace 'Finished' with 'On Going' and set color accordingly
    if (status == 'Finished') {
      displayStatus = 'On Going';
      statusColor = Colors.blue;
    } else {
      switch (status) {
        case 'Pending':
          statusColor = Colors.orange;
          break;
        case 'Completed':
          statusColor = Colors.green;
          break;
        case 'Cancelled':
          statusColor = Colors.red;
          break;
        default:
          statusColor = Colors.blue;
      }
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            // Details only
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project title and status
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
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Text(
                            '($displayStatus)',
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
                    // Location
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Year
                    Text(
                      year,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}