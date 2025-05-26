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
    _loadProjectDetails();
  }

  Future<void> _loadProjectDetails() async {
    // Simulate API call to get complete project details
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      // In a real app, you would fetch this data from your backend
      // For now, we'll create mock data based on the passed project
      
      // Get project status
      String status = widget.project['status'];
      int currentStageIndex = 0;
      double progress = 0.0;
      
      // Set stage and progress based on status
      switch (status) {
        case 'Pending':
          currentStageIndex = 0;
          progress = 0.1;
          break;
        case 'On Going':
          currentStageIndex = 2;
          progress = 0.4;
          break;
        case 'Completed':
          currentStageIndex = 5;
          progress = 1.0;
          break;
        case 'Cancelled':
          currentStageIndex = -1;
          progress = 0.0;
          break;
        default:
          currentStageIndex = 0;
          progress = 0.1;
      }

      // Mock data for a project
      _projectData = {
        ...widget.project,
        'currentStage': currentStageIndex >= 0 ? _projectStages[currentStageIndex] : 'N/A',
        'progress': progress,
        'clientName': 'Maria Santos',
        'contactNumber': '+63 912 345 6789',
        'email': 'maria.santos@example.com',
        'roomType': 'Living Room',
        'projectSize': '45 sqm',
        'budget': '₱ 350,000',
        'description': 'Modern minimalist design with neutral tones. Open concept living area with large windows for natural light. Needs storage solutions for small space.',
        'startDate': 'June 10, 2025',
        'estimatedCompletionDate': 'August 25, 2025',
        'designerAssigned': status != 'Pending' && status != 'Cancelled' ? {
          'name': 'Designer Alex Reyes',
          'imageUrl': 'https://i.pravatar.cc/150?img=68',
          'rating': 4.8,
          'projectsCompleted': 24,
        } : null,
        'inspirationLinks': [
          'https://www.pinterest.com/pin/492649944689022',
          'https://www.houzz.com/magazine/room-of-the-day-light-and-bright'
        ],
        'timeline': [
          {
            'stage': 'Brief Review',
            'date': 'June 10, 2025',
            'isCompleted': status != 'Pending' && status != 'Cancelled',
          },
          {
            'stage': 'Initial Concepts',
            'date': 'June 20, 2025',
            'isCompleted': status == 'On Going' || status == 'Completed',
          },
          {
            'stage': 'Design Presentation',
            'date': 'July 5, 2025',
            'isCompleted': status == 'On Going' || status == 'Completed',
          },
          {
            'stage': 'Finalize Design',
            'date': 'July 20, 2025',
            'isCompleted': status == 'Completed',
          },
          {
            'stage': 'Implementation',
            'date': 'August 1, 2025',
            'isCompleted': status == 'Completed',
          },
          {
            'stage': 'Project Completion',
            'date': 'August 25, 2025',
            'isCompleted': status == 'Completed',
          },
        ],
        'comments': [
          {
            'user': 'Designer Alex Reyes',
            'message': 'Initial concept sketches are ready for review. Please schedule a time for presentation.',
            'date': 'June 18, 2025',
          },
          {
            'user': 'Admin',
            'message': 'Project proposal approved. Alex Reyes has been assigned as your designer.',
            'date': 'June 12, 2025',
          },
        ],
      };

      setState(() {
        _isLoading = false;
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
          if (status != 'Cancelled')
            _buildProgressSection(),
          
          // Designer section
          if (_projectData['designerAssigned'] != null)
            _buildDesignerSection(),
          
          // Project Details section
          _buildSectionHeader('Project Details'),
          _buildDetailCard([
            _buildDetailRow('Project Name', _projectData['title']),
            _buildDetailRow('Room Type', _projectData['roomType']),
            _buildDetailRow('Project Size', _projectData['projectSize']),
            _buildDetailRow('Location', _projectData['location']),
            _buildDetailRow('Budget', _projectData['budget']),
            _buildDetailRow('Start Date', _projectData['startDate']),
            _buildDetailRow('Est. Completion', _projectData['estimatedCompletionDate']),
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
          if (_projectData['comments'] != null && _projectData['comments'].isNotEmpty)
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            _projectData['location'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          Text(
            _projectData['year'],
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
    final progress = _projectData['progress'] as double;
    final currentStage = _projectData['currentStage'] as String;
    
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
                percent: progress,
                center: Text(
                  '${(progress * 100).toInt()}%',
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
            value: progress,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildDetailRow(String label, String value) {
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
              value,
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
    List<Map<String, dynamic>> timeline = _projectData['timeline'];
    
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

  Widget _buildTimelineItem(String stage, String date, bool isCompleted, {bool isLast = false}) {
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
                  color: isCompleted ? const Color(0xFF203B32) : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? const Color(0xFF203B32) : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? const Color(0xFF203B32) : Colors.grey[300],
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
                    color: isCompleted ? const Color(0xFF203B32) : Colors.grey[700],
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
    List<Map<String, dynamic>> comments = _projectData['comments'];
    
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
                comment['profileImage']
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCommentItem(String user, String message, String date, dynamic comments) {
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
          if (user != comments.last['user'])
            const Divider(height: 24),
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