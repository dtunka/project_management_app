import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../../data/models/user_model.dart';
import 'package:flutter/services.dart'; // For Clipboard
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  /// track which user detail is expanded
  int? expandedIndex;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    Future.microtask(() {
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false).fetchUsers();
      }
    });
  }

  String getInitials(String name) {
    List<String> parts = name.split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : "U";
  }

  /// Show edit user dialog
  Future<void> _showEditDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    String selectedRole = user.role;
    bool isLoading = false;
   String? _passwordError;
    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name Field
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                 TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password (leave empty to keep current)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    errorText: _passwordError,
                    helperText: '8+ chars, 1 uppercase, 1 lowercase, 1 number/special char',
                    helperStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setDialogState(() {
                      _passwordError = _validatePassword(value);
                    });
                  },
                ),
                  const SizedBox(height: 16),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.admin_panel_settings),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                        value: 'manager',
                        child: Text('Manager'),
                      ),
                      DropdownMenuItem(value: 'member', child: Text('Member')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),

              // Update Button
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() => isLoading = true);

                        // Prepare update data
                        Map<String, dynamic> updateData = {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'role': selectedRole,
                        };

                        // Only include password if not empty
                        if (passwordController.text.trim().isNotEmpty) {
                          updateData['password'] = passwordController.text
                              .trim();
                        }

                        // Call provider to update user
                        final provider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        final success = await provider.updateUser(
                          user.id,
                          updateData,
                        );

                        if (context.mounted) {
                          if (success != null) {
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(dialogContext);
                          } else {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.errorMessage ??
                                      'Failed to update user',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            setDialogState(() => isLoading = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('UPDATE'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    UserModel user,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${user.name}"?'),
            const SizedBox(height: 8),
            Text(
              'Email: ${user.email}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Role: ${user.role}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      await _deleteUser(user);
    }
  }

  /// Perform delete operation
  Future<void> _deleteUser(UserModel user) async {
    setState(() {
      _isDeleting = true;
    });

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    // Call provider to delete user
    final provider = Provider.of<UserProvider>(context, listen: false);
    final success = await provider.deleteUser(user.id);

    if (context.mounted) {
      // Close loading dialog
      Navigator.pop(context);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User "${user.name}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Collapse expanded user if it was deleted
        if (expandedIndex != null &&
            expandedIndex! < provider.users.length &&
            provider.users[expandedIndex!].id == user.id) {
          setState(() {
            expandedIndex = null;
          });
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to delete user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isDeleting = false;
      });
    }
  }
  // Copy text to clipboard 
   Future<void> _copyToClipboard(String text, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label copied to clipboard'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.blue,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print("Error copying to clipboard: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy $label'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);

    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.users.isEmpty) {
      return const Center(child: Text("No users found"));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchUsers(),
      child: ListView.builder(
        itemCount: provider.users.length,
        itemBuilder: (context, index) {
          UserModel user = provider.users[index];
          bool isExpanded = expandedIndex == index;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
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
                /// MAIN USER ROW
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _getRoleColor(user.role),
                      child: Text(
                        getInitials(user.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                             color: _getRoleColor(user.role).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getRoleColor(user.role),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            expandedIndex = null;
                          } else {
                            expandedIndex = index;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isExpanded ? "Hide Detail" : "View Detail",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                /// DETAIL SECTION
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 10),

                  // Email with icon
                 Row(
                  children: [
                    Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Email: ${user.email}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 16, color: Colors.grey[400]),
                      onPressed: () => _copyToClipboard(user.email, 'Email'),
                      tooltip: 'Copy email',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                /// User ID with copy button - NOW SHOWING FULL ID
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "ID: ${user.id}", // Full ID without truncation
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 16, color: Colors.grey[400]),
                      onPressed: () => _copyToClipboard(user.id, 'User ID'),
                      tooltip: 'Copy user ID',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                  const SizedBox(height: 6),

                  /// PROJECTS
                  Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Projects: None",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// ACTION BUTTONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// EDIT BUTTON - Now functional
                      ElevatedButton.icon(
                        onPressed: provider.isLoading || _isDeleting
                            ? null
                            : () => _showEditDialog(user),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      /// DELETE BUTTON - Now functional
                      ElevatedButton.icon(
                        onPressed: provider.isLoading || _isDeleting
                            ? null
                            : () => _showDeleteConfirmation(context, user),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'member':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
String? _validatePassword(String password) {
  if (password.isEmpty) {
    return null; // Empty password is allowed (means keep current)
  }
  
  if (password.length < 8) {
    return 'At least 8 characters required';
  }
  
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return 'At least one uppercase letter required';
  }
  
  if (!password.contains(RegExp(r'[a-z]'))) {
    return ' At least one lowercase letter required';
  }
  
  // Check for either number OR special character
  bool hasNumberOrSpecial = password.contains(RegExp(r'[0-9]')) || 
                           password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  
  if (!hasNumberOrSpecial) {
    return 'At least one number or special character required';
  }
  
  return null; // Password is valid
}