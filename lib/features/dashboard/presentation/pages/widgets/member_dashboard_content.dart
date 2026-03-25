import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../../shared/widgets/stat_card.dart';

class MemberDashboardContent extends StatelessWidget {
  const MemberDashboardContent({super.key});

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
            "My Dashboard",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Track your personal tasks and projects",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),

          /// STATS ROWS - Personal stats for member
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: "MY TASKS",
                  value: dashboard?.totalTasks.toString() ?? "0",
                  icon: Icons.task,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "COMPLETED",
                  value: dashboard?.completedTasks.toString() ?? "0",
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
                  value: (dashboard?.totalTasks ?? 0 - dashboard!.completedTasks ?? 0).toString(),
                  icon: Icons.trending_up,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: "OVERDUE",
                  value: dashboard?.overdueTasks.toString() ?? "0",
                  icon: Icons.warning,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// MY TASKS SECTION
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
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.task, color: Colors.blue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "My Tasks",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        "You have 5 tasks pending",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.grey,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "60% Complete",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}