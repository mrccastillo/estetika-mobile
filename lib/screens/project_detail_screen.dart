import 'package:flutter/material.dart';
import 'package:estetika_ui/widgets/custom_app_bar.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  // Project milestone stages
  final List<String> _projectStages = [
    'Briefing',
    'Concept Design',
    'Design Development',
    'Documentation',
    'Implementation',
    'Completion'
  ];

  late Map<String, dynamic> _projectData;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    print('Project passed to ProjectDetailScreen: ${widget.project}');
    _loadProjectDetails();
  }

  Future<void> _loadProjectDetails() async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      _projectData = widget.project; // Use the real project data
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Project Details',
        actions: [],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _hasError
              ? _buildErrorView()
              : _buildProjectDetailsView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF203B32),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load project details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
              _loadProjectDetails();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF203B32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailsView() {
    final status = _projectData['status'];
    final statusColor = _getStatusColor(status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project header with status
          _buildProjectHeader(statusColor),
          const SizedBox(height: 24),

          // Project Progress section
          if (status != 'Cancelled') _buildProgressSection(),

          // Designer section
          if (_projectData['designerAssigned'] != null) _buildDesignerSection(),

          // Project Details section
          _buildSectionHeader('Project Details'),
          _buildDetailCard([
            _buildDetailRow('Project Name', _projectData['title']),
            _buildDetailRow('Room Type', _projectData['roomType']),
            _buildDetailRow('Budget', '₱${_projectData['budget'] ?? 'N/A'}'),
            _buildDetailRow(
                'Start Date',
                _projectData['startDate']?.toString().substring(0, 10) ??
                    'N/A'),
            _buildDetailRow('End Date',
                _projectData['endDate']?.toString().substring(0, 10) ?? 'N/A'),
            _buildDetailRow('Status',
                _projectData['status']?.toString().toUpperCase() ?? 'N/A'),
            _buildDetailRow('Progress', '${_projectData['progress'] ?? 0}%'),
            _buildDetailRow(
                'Client', _projectData['projectCreator']?['fullName'] ?? 'N/A'),
            _buildDetailRow('Client Email',
                _projectData['projectCreator']?['email'] ?? 'N/A'),
          ]),
          const SizedBox(height: 16),

          // Client Information section
          _buildSectionHeader('Client Information'),
          _buildDetailCard([
            _buildDetailRow('Client Name', _projectData['clientName']),
            _buildDetailRow('Contact Number', _projectData['contactNumber']),
            _buildDetailRow('Email', _projectData['email']),
          ]),
          const SizedBox(height: 16),

          // Project Description
          _buildSectionHeader('Requirements & Description'),
          _buildDescriptionCard(_projectData['description']),
          const SizedBox(height: 16),

          // Inspiration Links
          if (_projectData['inspirationLinks'] != null &&
              _projectData['inspirationLinks'].isNotEmpty)
            _buildInspirationLinksSection(),

          // Project Timeline
          _buildSectionHeader('Project Timeline'),
          _buildTimelineSection(),
          const SizedBox(height: 16),

          // Comments Section
          if (_projectData['comments'] != null &&
              _projectData['comments'].isNotEmpty)
            _buildCommentsSection(),

          // Action Buttons
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProjectHeader(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _projectData['title'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF203B32),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  _projectData['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _projectData['location']?.toString() ?? 'N/A',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            _projectData['year']?.toString() ?? 'N/A',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = (_projectData['progress'] ?? 0);
    final double progressValue =
        (progress is int) ? progress.toDouble() : (progress as double? ?? 0.0);
    final currentStage = _projectData['currentStage']?.toString() ?? 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF203B32),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 10.0,
                animation: true,
                percent: progressValue / 100,
                center: Text(
                  '${progressValue.toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: const Color(0xFF203B32),
                backgroundColor: Colors.grey[300]!,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Stage',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStage,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF203B32),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressValue / 100,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF203B32),
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Briefing',
                style: TextStyle(fontSize: 12),
              ),
              const Text(
                'Completion',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesignerSection() {
    final designer = _projectData['designerAssigned'];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Designer Assigned',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF203B32),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage: NetworkImage(designer['imageUrl']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      designer['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${designer['rating']} • ${designer['projectsCompleted']} Projects',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Action to message the designer
                },
                icon: const Icon(Icons.message_outlined, size: 18),
                label: const Text('Message'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203B32),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF203B32),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF203B32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A', // <-- Fix here
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildInspirationLinksSection() {
    List<String> links = _projectData['inspirationLinks'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Inspiration Links'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: links.map((link) => _buildLinkItem(link)).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLinkItem(String link) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () async {
          final Uri url = Uri.parse(link);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        },
        child: Row(
          children: [
            const Icon(
              Icons.link,
              size: 18,
              color: Color(0xFF203B32),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                link,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    final List<Map<String, dynamic>> timeline =
        (_projectData['timeline'] ?? []).cast<Map<String, dynamic>>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: timeline.length,
        itemBuilder: (context, index) {
          final item = timeline[index];
          return _buildTimelineItem(
            item['stage'],
            item['date'],
            item['isCompleted'],
            isLast: index == timeline.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(String stage, String date, bool isCompleted,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color:
                      isCompleted ? const Color(0xFF203B32) : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFF203B32)
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color:
                      isCompleted ? const Color(0xFF203B32) : Colors.grey[300],
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? const Color(0xFF203B32)
                        : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    final List<Map<String, dynamic>> comments =
        (_projectData['comments'] ?? []).cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Comments & Updates'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return _buildCommentItem(
                comment['user'],
                comment['message'],
                comment['date'],
                comments, // Pass the full list
                index,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCommentItem(String user, String message, String date,
      List<Map<String, dynamic>> comments, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                user,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          // Only show divider if not the last comment
          if (index != comments.length - 1) const Divider(height: 24),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement messaging functionality
              },
              icon: const Icon(Icons.message_outlined),
              label: const Text('Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF203B32),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF203B32)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement call functionality
              },
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Call'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF203B32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Example for a detail section or card
  Widget _buildProjectSummary(Map<String, dynamic> project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title: ${project['title'] ?? 'N/A'}'),
        Text('Description: ${project['description'] ?? 'N/A'}'),
        Text('Room Type: ${project['roomType'] ?? 'N/A'}'),
        Text('Budget: ₱${project['budget'] ?? 'N/A'}'),
        Text(
            'Start Date: ${project['startDate']?.toString().substring(0, 10) ?? 'N/A'}'),
        Text(
            'End Date: ${project['endDate']?.toString().substring(0, 10) ?? 'N/A'}'),
        Text('Status: ${project['status']?.toString().toUpperCase() ?? 'N/A'}'),
        Text('Progress: ${(project['progress'] ?? 0).toString()}%'),
        Text('Client: ${project['projectCreator']?['fullName'] ?? 'N/A'}'),
        Text('Client Email: ${project['projectCreator']?['email'] ?? 'N/A'}'),
        Text(
            'Members: ${project['members'] != null ? project['members'].length.toString() : '0'}'),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'On Going':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
