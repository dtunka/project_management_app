import 'package:flutter/material.dart';

class SidebarMenuItem {
  final IconData icon;
  final String title;
  final int index;
  final List<String> roles;

  SidebarMenuItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.roles,
  });
}

class SidebarMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String userRole;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userRole,
  });

  List<SidebarMenuItem> _getMenuItems() {
    return [
      SidebarMenuItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        index: 0,
        roles: ['admin', 'manager', 'member'],
      ),
      SidebarMenuItem(
        icon: Icons.folder,
        title: 'Projects',
        index: 1,
        roles: ['admin', 'manager', 'member'],
      ),
      SidebarMenuItem(
        icon: Icons.task,
        title: 'Tasks',
        index: 2,
        roles: ['admin', 'manager', 'member'], // Admin now has tasks too
      ),
      SidebarMenuItem(
        icon: Icons.people,
        title: 'Users',
        index: 3,
        roles: ['admin'], // Only admin
      ),
      SidebarMenuItem(
        icon: Icons.groups,
        title: 'Teams',
        index: 4,
        roles: ['admin', 'manager'],
      ),
      SidebarMenuItem(
        icon: Icons.bar_chart,
        title: 'Reports',
        index: 5,
        roles: ['admin', 'manager'],
      ),
      SidebarMenuItem(
        icon: Icons.timeline,
        title: 'Activities',
        index: 6,
        roles: ['admin', 'manager'],
      ),
      SidebarMenuItem(
        icon: Icons.settings,
        title: 'Settings',
        index: 7,
        roles: ['admin', 'manager'],
      ),
      SidebarMenuItem(
        icon: Icons.person,
        title: 'Profile',
        index: 8,
        roles: ['admin', 'manager', 'member'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = _getMenuItems();
    final filteredItems = menuItems.where((item) => item.roles.contains(userRole)).toList();

    return Column(
      children: filteredItems.map((item) {
        return ListTile(
          selected: selectedIndex == item.index,
          selectedTileColor: Colors.white24,
          leading: Icon(item.icon, color: Colors.white, size: 20),
          title: Text(
            item.title,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          dense: true,
          onTap: () => onItemSelected(item.index),
        );
      }).toList(),
    );
  }
}