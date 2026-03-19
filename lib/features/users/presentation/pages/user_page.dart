import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
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
  String _selectedRoleFilter = 'All Roles'; // Default filter

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

  /// Email validation
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Password validation for CREATE (required)
  String? _validatePasswordForCreate(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    return _validatePasswordStrength(password);
  }

  /// Password validation for EDIT (optional)
  String? _validatePasswordForEdit(String password) {
    if (password.isEmpty) {
      return null; // Empty password is allowed (means keep current)
    }

    return _validatePasswordStrength(password);
  }

  /// Common password strength validation
  String? _validatePasswordStrength(String password) {
    if (password.length < 8) {
      return 'At least 8 characters required';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'At least one uppercase letter required';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'At least one lowercase letter required';
    }

    // Check for either number OR special character
    bool hasNumberOrSpecial =
        password.contains(RegExp(r'[0-9]')) ||
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasNumberOrSpecial) {
      return 'At least one number or special character required';
    }

    return null;
  }

  /// Filter users based on selected role using provider
  List<dynamic> _getFilteredUsers(UserProvider provider) {
    if (_selectedRoleFilter == 'All Roles') {
      return provider.users;
    }
    return provider.users.where((user) => 
      user.role.toLowerCase() == _selectedRoleFilter.toLowerCase()
    ).toList();
  }

  /// Show edit user dialog
  Future<void> _showEditDialog(BuildContext context, dynamic user) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    String selectedRole = user.role;
    bool isLoading = false;
    String? _nameError;
    String? _emailError;
    String? _passwordError;

    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text('Edit User'),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                        errorText: _nameError,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          _nameError = value.isEmpty ? 'Name is required' : null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        errorText: _emailError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setDialogState(() {
                          _emailError = _validateEmail(value);
                        });
                      },
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
                        helperText:
                            '8+ chars, 1 uppercase, 1 lowercase, 1 number/special char',
                        helperStyle: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setDialogState(() {
                          _passwordError = _validatePasswordForEdit(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role *',
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
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),

              // Update Button
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate all fields
                        String? nameError = nameController.text.isEmpty ? 'Name is required' : null;
                        String? emailError = _validateEmail(emailController.text);
                        
                        // Only validate password if it's not empty
                        String? passwordError;
                        if (passwordController.text.isNotEmpty) {
                          passwordError = _validatePasswordForEdit(passwordController.text);
                        }

                        if (nameError != null || emailError != null || passwordError != null) {
                          setDialogState(() {
                            _nameError = nameError;
                            _emailError = emailError;
                            _passwordError = passwordError;
                          });
                          return;
                        }

                        setDialogState(() => isLoading = true);

                        // Prepare update data
                        Map<String, dynamic> updateData = {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'role': selectedRole,
                        };

                        // Only include password if not empty
                        if (passwordController.text.trim().isNotEmpty) {
                          updateData['password'] = passwordController.text.trim();
                        }

                        // Call provider to update user
                        final provider = Provider.of<UserProvider>(
                          dialogContext,
                          listen: false,
                        );
                        final updatedUser = await provider.updateUser(
                          user.id,
                          updateData,
                        );

                        if (dialogContext.mounted) {
                          if (updatedUser != null) {
                            // Show success message
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('User "${updatedUser.name}" updated successfully'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(dialogContext);
                          } else {
                            // Show error message
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.errorMessage ?? 'Failed to update user',
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
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

  /// Show create user dialog
  Future<void> _showCreateUserDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'member';
    bool isLoading = false;
    String? _nameError;
    String? _emailError;
    String? _passwordError;

    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.person_add, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text('Create New User'),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                width: 400,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                        errorText: _nameError,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          _nameError = value.isEmpty ? 'Name is required' : null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.email),
                        errorText: _emailError,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setDialogState(() {
                          _emailError = _validateEmail(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        errorText: _passwordError,
                        helperText:
                            '8+ chars, 1 uppercase, 1 lowercase, 1 number/special char',
                        helperStyle: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setDialogState(() {
                          _passwordError = _validatePasswordForCreate(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.admin_panel_settings),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(
                          value: 'manager',
                          child: Text('Manager'),
                        ),
                        DropdownMenuItem(
                          value: 'member',
                          child: Text('Member'),
                        ),
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
            ),
            actions: [
              // Cancel Button
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),

              // Create Button
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate all fields
                        String? nameError = nameController.text.isEmpty
                            ? 'Name is required'
                            : null;
                        String? emailError = _validateEmail(emailController.text);
                        String? passwordError = _validatePasswordForCreate(passwordController.text);

                        if (nameError != null || emailError != null || passwordError != null) {
                          setDialogState(() {
                            _nameError = nameError;
                            _emailError = emailError;
                            _passwordError = passwordError;
                          });
                          return;
                        }

                        setDialogState(() => isLoading = true);

                        // Prepare create data
                        Map<String, dynamic> createData = {
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'password': passwordController.text.trim(),
                          'role': selectedRole,
                        };

                        // Call provider to create user
                        final provider = Provider.of<UserProvider>(
                          dialogContext,
                          listen: false,
                        );
                        final newUser = await provider.createUser(createData);

                        if (dialogContext.mounted) {
                          if (newUser != null) {
                            // Show success message
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'User "${newUser.name}" created successfully',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(dialogContext);
                          } else {
                            // Show error message
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.errorMessage ?? 'Failed to create user',
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            setDialogState(() => isLoading = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
                    : const Text('CREATE'),
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
    dynamic user,
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
  Future<void> _deleteUser(dynamic user) async {
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
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get filtered users based on selected role
        final filteredUsers = _getFilteredUsers(provider);

        return Column(
          children: [
            // Header with Total Users, Filter Dropdown and Create Button
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Total Users with Icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Users',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            '${filteredUsers.length}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Role Filter Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedRoleFilter,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRoleFilter = newValue!;
                          // Collapse expanded user when filter changes
                          expandedIndex = null;
                        });
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'All Roles',
                          child: Row(
                            children: [
                              Icon(Icons.people, size: 18, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('All Roles'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Row(
                            children: [
                              Icon(Icons.admin_panel_settings, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Admin'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'manager',
                          child: Row(
                            children: [
                              Icon(Icons.manage_accounts, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Manager'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'member',
                          child: Row(
                            children: [
                              Icon(Icons.person, size: 18, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Member'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Create User Button
                  ElevatedButton.icon(
                    onPressed: provider.isLoading || _isDeleting
                        ? null
                        : () => _showCreateUserDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Users List
            if (filteredUsers.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _selectedRoleFilter == 'All Roles'
                            ? "No users found"
                            : "No ${_selectedRoleFilter.toLowerCase()} users found",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_selectedRoleFilter != 'All Roles')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedRoleFilter = 'All Roles';
                            });
                          },
                          child: const Text('View all users'),
                        ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.fetchUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
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
                                          color: _getRoleColor(
                                            user.role,
                                          ).withValues(alpha: 0.1),
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
                                  Icon(
                                    Icons.email_outlined,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Email: ${user.email}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.copy,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () =>
                                        _copyToClipboard(user.email, 'Email'),
                                    tooltip: 'Copy email',
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              /// User ID with copy button
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
                                      "ID: ${user.id}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.copy,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                    onPressed: () =>
                                        _copyToClipboard(user.id, 'User ID'),
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
                                  /// EDIT BUTTON
                                  ElevatedButton.icon(
                                    onPressed: provider.isLoading || _isDeleting
                                        ? null
                                        : () => _showEditDialog(context, user),
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

                                  /// DELETE BUTTON
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
                ),
              ),
          ],
        );
      },
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