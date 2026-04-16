import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../../data/models/user_model.dart';
import 'package:flutter/services.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  int? expandedIndex;
  bool _isDeleting = false;
  String _selectedRoleFilter = 'All Roles';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() {
    Future.microtask(() {
      if (mounted) {
        final provider = Provider.of<UserProvider>(context, listen: false);
        provider.fetchUsers();
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

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePasswordForCreate(String password) {
    if (password.isEmpty) return 'Password is required';
    return _validatePasswordStrength(password);
  }

  String? _validatePasswordForEdit(String password) {
    if (password.isEmpty) return null;
    return _validatePasswordStrength(password);
  }

  String? _validatePasswordStrength(String password) {
    if (password.length < 8) return 'At least 8 characters required';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'At least one uppercase letter required';
    if (!password.contains(RegExp(r'[a-z]'))) return 'At least one lowercase letter required';
    bool hasNumberOrSpecial = password.contains(RegExp(r'[0-9]')) ||
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (!hasNumberOrSpecial) return 'At least one number or special character required';
    return null;
  }

  List<UserModel> _getFilteredUsers(UserProvider provider) {
    if (_selectedRoleFilter == 'All Roles') {
      return provider.users;
    }
    return provider.users.where((user) =>
        user.role.toLowerCase() == _selectedRoleFilter.toLowerCase()).toList();
  }

  // Check if user can perform actions
  bool get _canCreateUser => Provider.of<UserProvider>(context, listen: false).canCreateUser;
  
  bool _canEditUser(UserModel user) => Provider.of<UserProvider>(context, listen: false).canEditUser(user);
  
  bool _canDeleteUser(UserModel user) => Provider.of<UserProvider>(context, listen: false).canDeleteUser(user);

  Future<void> _showEditDialog(UserModel user) async {
    // Check permission
    if (!_canEditUser(user)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to edit users'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                          _passwordError = _validatePasswordForEdit(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.admin_panel_settings),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'manager', child: Text('Manager')),
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
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  String? nameError = nameController.text.isEmpty ? 'Name is required' : null;
                  String? emailError = _validateEmail(emailController.text);
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

                  Map<String, dynamic> updateData = {
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'role': selectedRole,
                  };
                  if (passwordController.text.trim().isNotEmpty) {
                    updateData['password'] = passwordController.text.trim();
                  }

                  final provider = Provider.of<UserProvider>(dialogContext, listen: false);
                  final updatedUser = await provider.updateUser(user.id, updateData);

                  if (dialogContext.mounted) {
                    if (updatedUser != null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('User updated successfully'), backgroundColor: Colors.green),
                      );
                      Navigator.pop(dialogContext);
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(provider.errorMessage ?? 'Failed to update user'), backgroundColor: Colors.red),
                      );
                      setDialogState(() => isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('UPDATE'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCreateUserDialog() async {
    // Check permission
    if (!_canCreateUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to create users'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        errorText: _passwordError,
                        helperText: '8+ chars, 1 uppercase, 1 lowercase, 1 number/special char',
                        helperStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setDialogState(() {
                          _passwordError = _validatePasswordForCreate(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.admin_panel_settings),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'manager', child: Text('Manager')),
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
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  String? nameError = nameController.text.isEmpty ? 'Name is required' : null;
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

                  Map<String, dynamic> createData = {
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'password': passwordController.text.trim(),
                    'role': selectedRole,
                  };

                  final provider = Provider.of<UserProvider>(dialogContext, listen: false);
                  final newUser = await provider.createUser(createData);

                  if (dialogContext.mounted) {
                    if (newUser != null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('User "${newUser.name}" created successfully'), backgroundColor: Colors.green),
                      );
                      Navigator.pop(dialogContext);
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(provider.errorMessage ?? 'Failed to create user'), backgroundColor: Colors.red),
                      );
                      setDialogState(() => isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('CREATE'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, UserModel user) async {
    if (!_canDeleteUser(user)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You do not have permission to delete users'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
            Text('Email: ${user.email}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('Role: ${user.role}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      setState(() => _isDeleting = true);
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      final provider = Provider.of<UserProvider>(context, listen: false);
      final success = await provider.deleteUser(user.id);

      if (context.mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User "${user.name}" deleted successfully'), backgroundColor: Colors.green));
          if (expandedIndex != null && expandedIndex! < provider.users.length && provider.users[expandedIndex!].id == user.id) {
            setState(() => expandedIndex = null);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Failed to delete user'), backgroundColor: Colors.red));
        }
      }
      setState(() => _isDeleting = false);
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$label copied to clipboard'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.blue,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to copy $label'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    
    // Check if user can view users page
    if (!provider.canViewUsers) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'You do not have permission to view this page.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (provider.isLoading && provider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredUsers = _getFilteredUsers(provider);
    final canCreate = _canCreateUser;

    return Column(
      children: [
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.people, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Users', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      Text('${filteredUsers.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
              // Role Filter Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: DropdownButton<String>(
                  value: _selectedRoleFilter,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRoleFilter = newValue!;
                      expandedIndex = null;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'All Roles', child: Row(children: [Icon(Icons.people, size: 18, color: Colors.blue), SizedBox(width: 8), Text('All Roles')])),
                    DropdownMenuItem(value: 'admin', child: Row(children: [Icon(Icons.admin_panel_settings, size: 18, color: Colors.red), SizedBox(width: 8), Text('Admin')])),
                    DropdownMenuItem(value: 'manager', child: Row(children: [Icon(Icons.manage_accounts, size: 18, color: Colors.orange), SizedBox(width: 8), Text('Manager')])),
                    DropdownMenuItem(value: 'member', child: Row(children: [Icon(Icons.person, size: 18, color: Colors.green), SizedBox(width: 8), Text('Member')])),
                  ],
                ),
              ),
              // Create User Button - Only for Admin
              if (canCreate)
                ElevatedButton.icon(
                  onPressed: provider.isLoading || _isDeleting ? null : _showCreateUserDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Create User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ],
          ),
        ),
        if (filteredUsers.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _selectedRoleFilter == 'All Roles' ? "No users found" : "No ${_selectedRoleFilter.toLowerCase()} users found",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (_selectedRoleFilter != 'All Roles')
                    TextButton(
                      onPressed: () => setState(() => _selectedRoleFilter = 'All Roles'),
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
                  final bool isExpanded = expandedIndex == index;
                  final canEdit = _canEditUser(user);
                  final canDelete = _canDeleteUser(user);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
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
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: _getRoleColor(user.role),
                              child: Text(getInitials(user.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: _getRoleColor(user.role).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                    child: Text(user.role.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getRoleColor(user.role))),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => expandedIndex = isExpanded ? null : index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                child: Text(isExpanded ? "Hide Detail" : "View Detail", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 16),
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(child: Text("Email: ${user.email}", style: const TextStyle(fontSize: 14))),
                              IconButton(
                                icon: Icon(Icons.copy, size: 16, color: Colors.grey[400]),
                                onPressed: () => _copyToClipboard(user.email, 'Email'),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.badge_outlined, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(child: Text("ID: ${user.id}", style: const TextStyle(fontSize: 14))),
                              IconButton(
                                icon: Icon(Icons.copy, size: 16, color: Colors.grey[400]),
                                onPressed: () => _copyToClipboard(user.id, 'User ID'),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.folder_outlined, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text("Projects: ${user.projects?.join(", ") ?? "None"}", style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (canEdit)
                                ElevatedButton.icon(
                                  onPressed: provider.isLoading || _isDeleting ? null : () => _showEditDialog(user),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, elevation: 0),
                                ),
                              if (canEdit && canDelete) const SizedBox(width: 8),
                              if (canDelete)
                                ElevatedButton.icon(
                                  onPressed: provider.isLoading || _isDeleting ? null : () => _showDeleteConfirmation(context, user),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
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
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'manager': return Colors.orange;
      case 'member': return Colors.green;
      default: return Colors.blue;
    }
  }
}