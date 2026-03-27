import 'package:flutter/material.dart';
import 'package:project_management_app/features/projects/presentation/providers/project_provider.dart';
import 'package:project_management_app/features/shared/widgets/stat_card.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';

class ManagerDashboardContent extends StatefulWidget {
  const ManagerDashboardContent({super.key});

  @override
  State<ManagerDashboardContent> createState() => _ManagerDashboardContentState();
}

class _ManagerDashboardContentState extends State<ManagerDashboardContent> {
  String _dueFilter = 'week'; // 'week', 'two_weeks', 'month'
  
  // Due date filter options
  final Map<String, String> _filterOptions = {
    'week': 'Due This Week',
    'two_weeks': 'Due in 2 Weeks',
    'month': 'Due This Month',
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    Future.microtask(() {
      if (mounted) {
        final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        
        projectProvider.fetchProjects();
        dashboardProvider.fetchDashboard();
      }
    });
  }

  int _getDaysForFilter() {
    switch (_dueFilter) {
      case 'week':
        return 7;
      case 'two_weeks':
        return 14;
      case 'month':
        return 30;
      default:
        return 7;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    
    // Get manager's projects
    final myProjects = projectProvider.projects;
    final stats = projectProvider.getProjectStatistics();
    final dueSoonProjects = projectProvider.getProjectsDueWithinDays(_getDaysForFilter());
    final overdueProjects = projectProvider.getOverdueProjects();
    
    // Get projects by status
    final inProgressProjects = projectProvider.getProjectsByStatus('in_progress');
    final onHoldProjects = projectProvider.getProjectsByStatus('on_hold');
    final completedProjects = projectProvider.getProjectsByStatus('completed');
    final cancelledProjects = projectProvider.getProjectsByStatus('cancelled');

    if (projectProvider.isLoading && myProjects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your projects...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            "Manager Dashboard",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Monitor your projects and team performance",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "MY PROJECTS",
                  value: stats['totalProjects'].toString(),
                  icon: Icons.folder,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "DUE SOON",
                  value: dueSoonProjects.length.toString(),
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "OVERDUE",
                  value: overdueProjects.length.toString(),
                  icon: Icons.error,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "TOTAL TASKS",
                  value: stats['totalTasks'].toString(),
                  icon: Icons.task,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "COMPLETION RATE",
                  value: "${stats['completionRate']}%",
                  icon: Icons.pie_chart,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "COMPLETED TASKS",
                  value: stats['completedTasks'].toString(),
                  icon: Icons.check_circle,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Project Status Cards
          const Text(
            "Project Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusCard(
                title: "In Progress",
                count: inProgressProjects.length,
                color: Colors.blue,
                icon: Icons.trending_up,
              ),
              const SizedBox(width: 12),
              _buildStatusCard(
                title: "On Hold",
                count: onHoldProjects.length,
                color: Colors.orange,
                icon: Icons.pause_circle_outline,
              ),
              const SizedBox(width: 12),
              _buildStatusCard(
                title: "Completed",
                count: completedProjects.length,
                color: Colors.green,
                icon: Icons.check_circle,
              ),
              const SizedBox(width: 12),
              _buildStatusCard(
                title: "Cancelled",
                count: cancelledProjects.length,
                color: Colors.red,
                icon: Icons.cancel,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Due Soon Projects Section with Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Due Soon Projects",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Filter Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _dueFilter,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      _dueFilter = newValue!;
                    });
                  },
                  items: _filterOptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (dueSoonProjects.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No projects due ${_filterOptions[_dueFilter]?.toLowerCase() ?? 'soon'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dueSoonProjects.length,
              itemBuilder: (context, index) {
                final project = dueSoonProjects[index];
                return _buildProjectCard(project, context);
              },
            ),
          
          const SizedBox(height: 24),

          // All Projects Section
          const Text(
            "All My Projects",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          if (myProjects.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No projects assigned to you',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myProjects.length,
              itemBuilder: (context, index) {
                final project = myProjects[index];
                final bool isExpanded = projectProvider.expandedIndex == index;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 8,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getStatusColor(project.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.groups, size: 12, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  project.team.name,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(project.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getStatusText(project.status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(project.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.grey[600],
                          ),
                          onPressed: () => projectProvider.toggleExpand(index),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Progress Section
                              const Text(
                                'Progress',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: project.progress / 100,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation(_getStatusColor(project.status)),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${project.progress}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(project.status),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Task Breakdown
                              const Text(
                                'Task Breakdown',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildTaskBreakdownItem('Completed', project.completedTasks, Colors.green),
                                  const SizedBox(width: 8),
                                  _buildTaskBreakdownItem('In Progress', project.inProgressTasks, Colors.blue),
                                  const SizedBox(width: 8),
                                  _buildTaskBreakdownItem('Pending', project.pendingTasks, Colors.orange),
                                  const SizedBox(width: 8),
                                  _buildTaskBreakdownItem('Overdue', project.overdueTasks, Colors.red),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // Project Details
                              const Text(
                                'Project Details',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(Icons.calendar_today, 'Start Date', _formatDate(project.startDate)),
                              _buildDetailRow(Icons.event, 'Deadline', _formatDate(project.deadline)),
                              _buildDetailRow(Icons.person, 'Team', project.team.name),
                              _buildDetailRow(Icons.people, 'Members', '${project.contributors.length} contributors'),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskBreakdownItem(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(project, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(project.status),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.description,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Due: ${_formatDate(project.deadline)} • ${project.team.name}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(project.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(project.status),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(project.status),
            ),
          ),
        ),
        onTap: () {
          // Navigate to project details
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'on_hold':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'on_hold':
        return 'On Hold';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}