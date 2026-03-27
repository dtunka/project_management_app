import 'package:flutter/material.dart';
import 'package:project_management_app/features/authorization/presentation/providers/auth_provider.dart';
import 'package:project_management_app/features/dashboard/presentation/pages/widgets/admin_dashboard_content.dart';
import 'package:project_management_app/features/dashboard/presentation/pages/widgets/manager_dashboard_content.dart';
import 'package:project_management_app/features/dashboard/presentation/pages/widgets/member_dashboard_content.dart';
import 'package:project_management_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:project_management_app/features/projects/presentation/providers/project_provider.dart';
import 'package:provider/provider.dart';
import '../../../projects/presentation/pages/projects_page.dart';
import '../../../teams/presentation/pages/teams_page.dart';
import '../../../users/presentation/pages/user_page.dart';
import '../../../profile/presentation/pages/profile_pages.dart';

import '../../../shared/widgets/sidebar_menu.dart';
import '../../../../core/networks/token_manager.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  bool _isSidebarVisible = false;

  @override
  void initState() {
    super.initState();
    
    // Debug: Print user role on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('===== USER ROLE DEBUG =====');
      print('User: ${authProvider.user?.name}');
      print('Role: ${authProvider.user?.role}');
      print('===========================');
    });
    
    Future.microtask(() {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  void _onSidebarItemSelected(int index) {
    setState(() {
      selectedIndex = index;
      _isSidebarVisible = false;
    });
  }

  // Get the appropriate dashboard content based on user role
  Widget _getDashboardContent() {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role?.toLowerCase() ?? 'member';
    
    print('Building dashboard for role: $userRole');
    
    switch (userRole) {
      case 'admin':
        return const AdminDashboardContent();
      case 'manager':
        return const ManagerDashboardContent();
      case 'member':
        return const MemberDashboardContent();
      default:
        return const MemberDashboardContent();
    }
  }

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _getDashboardContent();
      case 1:
        return const ProjectsPage();
      case 2:
        return const Center(child: Text("Tasks Page - Coming Soon"));
      case 3:
        return const UsersPage();
      case 4:
        return const TeamsPage();
      case 5:
        return const Center(child: Text("Reports Page"));
      case 6:
        return const Center(child: Text("Activities Page"));
      case 7:
        return const Center(child: Text("Settings Page"));
      case 8:
        return const ProfilePage();
      default:
        return _getDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
   final authProvider = Provider.of<AuthProvider>(context);
  final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
  final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
  
  // Set user info in project provider when role is available
  if (authProvider.user != null) {
    final userId = authProvider.user!.id;
    final userRole = authProvider.user!.role.toLowerCase();
    
    // Only set if different from current
    if (projectProvider.currentUserRole != userRole) {
      print('=== SETTING USER INFO IN DASHBOARD ===');
      print('User ID: $userId');
      print('User Role: $userRole');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        projectProvider.setUserInfo(userId, userRole);
        projectProvider.fetchProjects();
      });
    }
  }
    String name = authProvider.user?.name ?? "";
    String role = authProvider.user?.role ?? "";
    String userRole = role.toLowerCase();

    if (role.isNotEmpty) {
      role = role[0].toUpperCase() + role.substring(1);
    }
    String avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : "A";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Stack(
        children: [
          /// MAIN CONTENT
          Column(
            children: [
              /// TOP BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
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
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: Text(
                            avatarLetter,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
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
                  child: _buildContent(),
                ),
              ),
            ],
          ),

          /// SIDEBAR OVERLAY
          if (_isSidebarVisible)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          /// SIDEBAR
          if (_isSidebarVisible)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 250,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B2A47),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(2, 0),
                    ),
                  ],
                ),
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
                      child: SidebarMenu(
                        selectedIndex: selectedIndex,
                        onItemSelected: _onSidebarItemSelected,
                        userRole: userRole,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(12),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 86, 114, 240),
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
                        label: const Text("Logout", style: TextStyle(fontSize: 13)),
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