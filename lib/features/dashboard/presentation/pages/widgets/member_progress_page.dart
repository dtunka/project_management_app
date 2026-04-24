import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../tasks/presentation/providers/task_provider.dart';

class MemberProgressPage extends StatelessWidget {
  const MemberProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final myTasks = taskProvider.tasks;
    
    // Calculate statistics
    final totalTasks = myTasks.length;
    final completedTasks = myTasks.where((t) => t.status == 'completed').length;
    final inProgressTasks = myTasks.where((t) => t.status == 'in_progress').length;
    final pendingTasks = myTasks.where((t) => t.status == 'pending').length;
    final overdueTasks = myTasks.where((t) => t.status == 'overdue').length;
    final dueSoonTasks = myTasks.where((t) {
      final daysUntilDeadline = t.deadline.difference(DateTime.now()).inDays;
      return daysUntilDeadline <= 7 && daysUntilDeadline >= 0 && t.status != 'completed';
    }).length;
    
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Progress',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Track your task performance and completion',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Chart Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: completedTasks.toDouble(),
                          title: '${(completedTasks / totalTasks * 100).round()}%',
                          color: Colors.green,
                          radius: 80,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: inProgressTasks.toDouble(),
                          title: '${(inProgressTasks / totalTasks * 100).round()}%',
                          color: Colors.blue,
                          radius: 80,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: pendingTasks.toDouble(),
                          title: '${(pendingTasks / totalTasks * 100).round()}%',
                          color: Colors.orange,
                          radius: 80,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: overdueTasks.toDouble(),
                          title: '${(overdueTasks / totalTasks * 100).round()}%',
                          color: Colors.red,
                          radius: 80,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildLegendItem(Colors.green, 'Completed', completedTasks),
                    _buildLegendItem(Colors.blue, 'In Progress', inProgressTasks),
                    _buildLegendItem(Colors.orange, 'Pending', pendingTasks),
                    _buildLegendItem(Colors.red, 'Overdue', overdueTasks),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Tasks', totalTasks.toString(), Icons.task, Colors.purple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Due Soon', dueSoonTasks.toString(), Icons.timer, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Completion Rate', '$completionRate%', Icons.pie_chart, Colors.teal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard('Overdue', overdueTasks.toString(), Icons.warning, Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completionRate / 100,
                  backgroundColor: Colors.grey[200],
                  color: Colors.teal,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '$completionRate% Complete',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: $count', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}