import 'package:flutter/material.dart';
import 'package:project_management_app/features/authorization/presentation/providers/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
    });
  }

  /// ---------- STAT CARD ----------
  Widget statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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
      selectedTileColor: Colors.white12,
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
    );
  }

  /// ---------- DASHBOARD CONTENT ----------
  Widget buildDashboard(DashboardProvider provider) {
    final dashboard = provider.dashboard;

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dashboard Overview",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Monitor your organization's projects, tasks and team performance",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// ACTION BUTTONS
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add),
                      label: const Text("Create User"),
                    ),

                    const SizedBox(width: 10),

                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.group_add),
                      label: const Text("Create Team"),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.folder),
                      label: const Text("View Projects"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// FIRST ROW STATS
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 5,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    statCard(
                      "TOTAL PROJECTS",
                      dashboard?.totalProjects.toString() ?? "0",
                      Icons.folder,
                    ),
                    statCard(
                      "ACTIVE PROJECTS",
                      dashboard?.activeProjects.toString() ?? "0",
                      Icons.trending_up,
                    ),

                    statCard(
                      "TOTAL TASKS",
                      dashboard?.totalTasks.toString() ?? "0",
                      Icons.task,
                    ),

                    statCard(
                      "COMPLETED TASKS",
                      dashboard?.completedTasks.toString() ?? "0",
                      Icons.check_circle,
                    ),

                    statCard(
                      "OVERDUE TASKS",
                      dashboard?.overdueTasks.toString() ?? "0",
                      Icons.warning,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// SECOND ROW
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 2.4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    statCard(
                      "USERS",
                      dashboard?.totalUsers.toString() ?? "0",
                      Icons.people,
                    ),

                    statCard(
                      "TEAMS",
                      dashboard?.totalTeams.toString() ?? "0",
                      Icons.groups,
                    ),

                    statCard(
                      "COMPLETION RATE",
                      "${(dashboard?.taskCompletionRate ?? 0).toStringAsFixed(0)}%",
                      Icons.pie_chart,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// OVERDUE PANELS
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            (dashboard?.overdueProjects ?? 0) > 0
                                ? "${dashboard?.overdueProjects} Overdue Projects Found"
                                : "No overdue projects",
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Container(
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            (dashboard?.overdueTasks ?? 0) > 0
                                ? "Reviewing ${dashboard?.overdueTasks} overdue tasks..."
                                : "No overdue tasks",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
        return const Center(child: Text("Projects Page"));

      case 2:
        return UsersPage();

      case 3:
        return const Center(child: Text("Teams Page"));

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

    /// Mock Auth Data
    final authProvider = Provider.of<AuthProvider>(context);

    String name = authProvider.user?.name ?? "";
    String role = authProvider.user?.role ?? "";

    if (role.isNotEmpty) {
      role = role[0].toUpperCase() + role.substring(1);
    }
    String avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : "A";
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: Row(
        children: [
          /// ---------------- SIDEBAR ----------------
          Container(
            width: 230,
            color: const Color(0xFF1B2A47),

            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "TaskFlow",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                sidebarItem(Icons.dashboard, "Dashboard", 0),
                sidebarItem(Icons.folder, "Projects", 1),
                sidebarItem(Icons.people, "Users", 2),
                sidebarItem(Icons.groups, "Teams", 3),
                sidebarItem(Icons.bar_chart, "Reports", 4),
                sidebarItem(Icons.timeline, "Activities", 5),
                sidebarItem(Icons.settings, "Settings", 6),
                sidebarItem(Icons.person, "Profile", 7),

                const Spacer(),

                Container(
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 243, 147, 147),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    onPressed: () async {
                      await TokenManager.clearToken();

                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ),

          /// ---------------- MAIN CONTENT ----------------
          Expanded(
            child: Column(
              children: [
                /// TOP BAR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: Colors.white,

                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search anything...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      const Icon(Icons.notifications_none),

                      const SizedBox(width: 20),

                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              avatarLetter,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: buildContent(dashboardProvider),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
