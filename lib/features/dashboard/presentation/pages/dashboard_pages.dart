import 'package:flutter/material.dart';
import 'package:project_management_app/features/authorization/presentation/providers/auth_provider.dart';
import 'package:project_management_app/features/projects/presentation/pages/projects_page.dart';
import 'package:project_management_app/features/teams/presentation/pages/teams_page.dart';
import 'package:project_management_app/features/users/presentation/pages/user_page.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/networks/token_manager.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int selectedIndex = 0;
  bool _isSidebarVisible = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
    });
  }

  /// Toggle sidebar visibility
  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  /// Handle sidebar item selection
  void _onSidebarItemSelected(int index) {
    setState(() {
      selectedIndex = index;
      _isSidebarVisible = false; // Close sidebar after selection
    });
  }

  /// ---------- STAT CARD (Compact) ----------
  Widget statCard(String title, String value, IconData icon, Color color) {
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------- SIDEBAR ITEM ----------
  Widget sidebarItem(IconData icon, String title, int index) {
    return ListTile(
      selected: selectedIndex == index,
      selectedTileColor: Colors.white24,
      leading: Icon(icon, color: Colors.white, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      dense: true,
      onTap: () => _onSidebarItemSelected(index),
    );
  }

  /// ---------- DASHBOARD CONTENT (2 boxes per row) ----------
  Widget buildDashboard(DashboardProvider provider) {
    final dashboard = provider.dashboard;

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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

                /// ACTION BUTTONS
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text("Create User"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.group_add, size: 18),
                      label: const Text("Create Team"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.folder, size: 18),
                      label: const Text("View Projects"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// ROW 1: Total Projects & Active Projects
                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        "TOTAL PROJECTS",
                        dashboard?.totalProjects.toString() ?? "0",
                        Icons.folder,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: statCard(
                        "ACTIVE PROJECTS",
                        dashboard?.activeProjects.toString() ?? "0",
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// ROW 2: Total Tasks & Completed Tasks
                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        "TOTAL TASKS",
                        dashboard?.totalTasks.toString() ?? "0",
                        Icons.task,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: statCard(
                        "COMPLETED TASKS",
                        dashboard?.completedTasks.toString() ?? "0",
                        Icons.check_circle,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// ROW 3: Overdue Tasks & Users
                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        "OVERDUE TASKS",
                        dashboard?.overdueTasks.toString() ?? "0",
                        Icons.warning,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: statCard(
                        "USERS",
                        dashboard?.totalUsers.toString() ?? "0",
                        Icons.people,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// ROW 4: Teams & Completion Rate
                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        "TEAMS",
                        dashboard?.totalTeams.toString() ?? "0",
                        Icons.groups,
                        Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: statCard(
                        "COMPLETION RATE",
                        "${(dashboard?.taskCompletionRate ?? 0).toStringAsFixed(0)}%",
                        Icons.pie_chart,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                /// OVERDUE PROJECTS & TASKS PANELS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Overdue Projects Panel
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
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
                                  child: Icon(
                                    Icons.warning,
                                    color: Colors.orange[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Overdue Projects",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    (dashboard?.overdueProjects ?? 0)
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          (dashboard?.overdueProjects ?? 0) > 0
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
                                      color:
                                          (dashboard?.overdueProjects ?? 0) > 0
                                          ? Colors.orange[700]
                                          : Colors.green[700],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    /// Overdue Tasks Panel
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
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
                                  child: Icon(
                                    Icons.task_alt,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Overdue Tasks",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Extra bottom padding
                const SizedBox(height: 20),
              ],
            ),
          );
  }

  /// ---------- PAGE SWITCHER ----------
  Widget buildContent(DashboardProvider provider) {
    switch (selectedIndex) {
      case 0:
        return buildDashboard(provider);

      case 1:
        return const ProjectsPage();

      case 2:
        return const UsersPage();

      case 3:
        return const TeamsPage();

      case 4:
        return const Center(child: Text("Reports Page"));

      case 5:
        return const Center(child: Text("Activities Page"));

      case 6:
        return const Center(child: Text("Settings Page"));

      case 7:
        return const Center(child: Text("Profile Page"));

      default:
        return buildDashboard(provider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    String name = authProvider.user?.name ?? "";
    String role = authProvider.user?.role ?? "";

    if (role.isNotEmpty) {
      role = role[0].toUpperCase() + role.substring(1);
    }
    String avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : "A";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Stack(
        children: [
          /// ---------------- MAIN CONTENT (Always visible) ----------------
          Column(
            children: [
              /// TOP BAR
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    /// Menu Toggle Button
                    GestureDetector(
                      onTap: _toggleSidebar,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _isSidebarVisible ? Icons.close : Icons.menu,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Search Bar
                    Expanded(
                      child: Container(
                        height: 36,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search...",
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 18),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Icon(Icons.notifications_none, size: 20),

                    const SizedBox(width: 12),

                    /// User Profile
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: Text(
                            avatarLetter,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (MediaQuery.of(context).size.width > 500) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              /// CONTENT
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: buildContent(dashboardProvider),
                ),
              ),
            ],
          ),

          /// ---------------- SIDEBAR  ----------------
          if (_isSidebarVisible)
            GestureDetector(
              onTap: _toggleSidebar, // Close sidebar when tapping outside
              child: Container(
                color: Colors.black54, // Semi-transparent background
              ),
            ),

          if (_isSidebarVisible)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 200,
                color: const Color(0xFF1B2A47),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      "TaskFlow",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            sidebarItem(Icons.dashboard, "Dashboard", 0),
                            sidebarItem(Icons.folder, "Projects", 1),
                            sidebarItem(Icons.people, "Users", 2),
                            sidebarItem(Icons.groups, "Teams", 3),
                            sidebarItem(Icons.bar_chart, "Reports", 4),
                            sidebarItem(Icons.timeline, "Activities", 5),
                            sidebarItem(Icons.settings, "Settings", 6),
                            sidebarItem(Icons.person, "Profile", 7),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            20,
                            19,
                            19,
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            86,
                            114,
                            240,
                          ),
                          minimumSize: const Size(double.infinity, 36),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () async {
                          await TokenManager.clearToken();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, '/login');
                          }
                        },
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
