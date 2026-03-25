import 'package:flutter/material.dart';
import 'package:project_management_app/features/authorization/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// A widget that shows its children only if the user has the required role
class RoleBasedWidget extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role?.toLowerCase() ?? 'member';

    if (allowedRoles.contains(userRole)) {
      return child;
    }
    
    return fallback ?? const SizedBox.shrink();
  }
}

/// A widget that conditionally shows different content based on user role
class RoleBasedSwitch extends StatelessWidget {
  final Map<String, Widget> roleContent;
  final Widget? defaultContent;

  const RoleBasedSwitch({
    super.key,
    required this.roleContent,
    this.defaultContent,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.user?.role?.toLowerCase() ?? 'member';

    if (roleContent.containsKey(userRole)) {
      return roleContent[userRole]!;
    }
    
    return defaultContent ?? const SizedBox.shrink();
  }
}