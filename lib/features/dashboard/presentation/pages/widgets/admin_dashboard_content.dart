import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../../shared/widgets/stat_card.dart';

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final dashboard = provider.dashboard;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Overview",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Monitor your organization's projects, tasks and team performance",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          /// ACTION BUTTONS - Admin can create everything
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text("Create User"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.group_add, size: 18),
                label: const Text("Create Team"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.folder, size: 18),
                label: const Text("View Projects"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// STATS ROWS
          _buildStatsGrid(dashboard),
          const SizedBox(height: 24),

          /// OVERDUE PANELS
          _buildOverduePanels(dashboard),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic dashboard) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "TOTAL PROJECTS",
                value: dashboard?.totalProjects.toString() ?? "0",
                icon: Icons.folder,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: "ACTIVE PROJECTS",
                value: dashboard?.activeProjects.toString() ?? "0",
                icon: Icons.trending_up,
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
                title: "TOTAL TASKS",
                value: dashboard?.totalTasks.toString() ?? "0",
                icon: Icons.task,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: "COMPLETED TASKS",
                value: dashboard?.completedTasks.toString() ?? "0",
                icon: Icons.check_circle,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "OVERDUE TASKS",
                value: dashboard?.overdueTasks.toString() ?? "0",
                icon: Icons.warning,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: "USERS",
                value: dashboard?.totalUsers.toString() ?? "0",
                icon: Icons.people,
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
                title: "TEAMS",
                value: dashboard?.totalTeams.toString() ?? "0",
                icon: Icons.groups,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: "COMPLETION RATE",
                value: "${(dashboard?.taskCompletionRate ?? 0).toStringAsFixed(0)}%",
                icon: Icons.pie_chart,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverduePanels(dynamic dashboard) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
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
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.warning, color: Colors.orange[700], size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Overdue Projects",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        (dashboard?.overdueProjects ?? 0).toString(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: (dashboard?.overdueProjects ?? 0) > 0
                              ? Colors.orange[700]
                              : Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (dashboard?.overdueProjects ?? 0) > 0
                            ? "Projects need attention"
                            : "All projects on track",
                        style: TextStyle(
                          color: (dashboard?.overdueProjects ?? 0) > 0
                              ? Colors.orange[700]
                              : Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
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
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.task_alt, color: Colors.red[700], size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Overdue Tasks",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        (dashboard?.overdueTasks ?? 0).toString(),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: (dashboard?.overdueTasks ?? 0) > 0
                              ? Colors.red[700]
                              : Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (dashboard?.overdueTasks ?? 0) > 0
                            ? "Tasks need attention"
                            : "All tasks on schedule",
                        style: TextStyle(
                          color: (dashboard?.overdueTasks ?? 0) > 0
                              ? Colors.red[700]
                              : Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}