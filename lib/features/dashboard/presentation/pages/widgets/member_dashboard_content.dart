import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../projects/presentation/providers/project_provider.dart';
import '../../../../tasks/presentation/providers/task_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../../shared/widgets/stat_card.dart';

class MemberDashboardContent extends StatefulWidget {
  const MemberDashboardContent({super.key});

  @override
  State<MemberDashboardContent> createState() => _MemberDashboardContentState();
}

class _MemberDashboardContentState extends State<MemberDashboardContent> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    Future.microtask(() {
      if (mounted) {
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        
        taskProvider.fetchTasks();
        projectProvider.fetchProjects();
        dashboardProvider.fetchDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    
    final dashboard = dashboardProvider.dashboard;
    final myTasks = taskProvider.tasks;
    final myProjects = projectProvider.projects;
    
    // Calculate task statistics
    final totalTasks = myTasks.length;
    final completedTasks = myTasks.where((t) => t.status == 'completed').length;
    final inProgressTasks = myTasks.where((t) => t.status == 'in_progress').length;
    final pendingTasks = myTasks.where((t) => t.status == 'pending').length;
    final overdueTasks = myTasks.where((t) => t.status == 'overdue').length;
    
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    if (dashboardProvider.isLoading && myTasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading dashboard...'),
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
            "My Dashboard",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Track your personal tasks and projects",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "MY TASKS",
                  value: totalTasks.toString(),
                  icon: Icons.task,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "COMPLETED",
                  value: completedTasks.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "IN PROGRESS",
                  value: inProgressTasks.toString(),
                  icon: Icons.trending_up,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "OVERDUE",
                  value: overdueTasks.toString(),
                  icon: Icons.warning,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "PENDING",
                  value: pendingTasks.toString(),
                  icon: Icons.pending,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "COMPLETION",
                  value: "$completionRate%",
                  icon: Icons.pie_chart,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Chart Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pie_chart, color: Colors.teal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "My Progress",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildProgressChart(completedTasks, inProgressTasks, pendingTasks, overdueTasks),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildProgressLegend(completedTasks, inProgressTasks, pendingTasks, overdueTasks),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: completionRate / 100,
                  backgroundColor: Colors.grey[200],
                  color: Colors.teal,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '$completionRate% Complete',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // My Tasks List
          const Text(
            "Recent Tasks",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          if (myTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.task_alt, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No tasks assigned', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myTasks.length > 5 ? 5 : myTasks.length,
              itemBuilder: (context, index) {
                final task = myTasks[index];
                return _buildTaskCard(task);
              },
            ),
          
          if (myTasks.length > 5)
            TextButton(
              onPressed: () {
                // Navigate to full tasks page
              },
              child: const Text('View All Tasks'),
            ),
          
          const SizedBox(height: 24),

          // My Projects Section
          const Text(
            "My Projects",
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
                    Text('No projects assigned', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myProjects.length > 3 ? 3 : myProjects.length,
              itemBuilder: (context, index) {
                final project = myProjects[index];
                return _buildProjectCard(project);
              },
            ),
          
          if (myProjects.length > 3)
            TextButton(
              onPressed: () {
                // Navigate to full projects page
              },
              child: const Text('View All Projects'),
            ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressChart(int completed, int inProgress, int pending, int overdue) {
    final total = completed + inProgress + pending + overdue;
    if (total == 0) {
      return const Center(
        child: Text('No data available', style: TextStyle(fontSize: 12, color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: completed.toDouble(),
              title: '${(completed / total * 100).round()}%',
              color: Colors.green,
              radius: 60,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: inProgress.toDouble(),
              title: '${(inProgress / total * 100).round()}%',
              color: Colors.blue,
              radius: 60,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: pending.toDouble(),
              title: '${(pending / total * 100).round()}%',
              color: Colors.orange,
              radius: 60,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: overdue.toDouble(),
              title: '${(overdue / total * 100).round()}%',
              color: Colors.red,
              radius: 60,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildProgressLegend(int completed, int inProgress, int pending, int overdue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, 'Completed', completed),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.blue, 'In Progress', inProgress),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.orange, 'Pending', pending),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.red, 'Overdue', overdue),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildTaskCard(task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: task.statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.statusText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: task.statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              _buildTaskInfo(Icons.folder, task.projectName),
              _buildTaskInfo(Icons.priority_high, task.priorityText),
              _buildTaskInfo(Icons.event, _formatDate(task.deadline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildProjectCard(project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: project.statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: project.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  project.statusText,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: project.statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              _buildProjectInfo(Icons.groups, project.team.name),
              _buildProjectInfo(Icons.linear_scale, '${project.progress}%'),
              _buildProjectInfo(Icons.event, _formatDate(project.deadline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}