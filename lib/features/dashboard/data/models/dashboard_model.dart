class DashboardModel {
  final int totalProjects;
  final int totalTasks;
  final int totalUsers;
  final int totalTeams;
  final int activeProjects;
  final int completedTasks;
  final int overdueTasks;
  final int overdueProjects;
  final double taskCompletionRate;

  DashboardModel({
    required this.totalProjects,
    required this.totalTasks,
    required this.totalUsers,
    required this.totalTeams,
    required this.activeProjects,
    required this.completedTasks,
    required this.overdueTasks,
    required this.overdueProjects,
    required this.taskCompletionRate,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalProjects: json['totalProjects'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      totalUsers: json['totalUsers'] ?? 0,
      totalTeams: json['totalTeams'] ?? 0,
      activeProjects: json['activeProjects'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      overdueTasks: json['overdueTasks'] ?? 0,
      overdueProjects: json['overdueProjects'] ?? 0,
      taskCompletionRate: (json['taskCompletionRate'] ?? 0).toDouble(),
    );
  }
}