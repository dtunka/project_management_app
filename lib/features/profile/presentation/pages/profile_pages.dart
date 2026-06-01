import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';
import '../../data/models/profile_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isEditing = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  File? _selectedImage;
  bool _isUploadingImage = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fetchProfile();
  }

  void _fetchProfile() {
    Future.microtask(() {
      if (mounted) {
        final provider = Provider.of<ProfileProvider>(context, listen: false);
        provider.fetchProfile();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _selectedImage = file;
        });
        await _uploadProfilePicture(file);
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _selectedImage = file;
        });
        await _uploadProfilePicture(file);
      }
    } catch (e) {
      print('Error taking photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to take photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Change Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final profile = provider.profile;
    if (profile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading profile picture...'),
          ],
        ),
      ),
    );

    final imageUrl = await provider.uploadProfilePictureFile(imageFile);

    if (mounted) {
      Navigator.pop(context);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final success = await provider.updateProfile(
          userId: profile.id,
          profilePicture: imageUrl,
        );

        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _selectedImage = null;
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to update profile picture'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to upload image'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isUploadingImage = false;
    });
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return null;
    if (password.length < 8) return 'At least 8 characters required';
    if (!password.contains(RegExp(r'[A-Z]'))) return 'At least one uppercase letter required';
    if (!password.contains(RegExp(r'[a-z]'))) return 'At least one lowercase letter required';
    bool hasNumberOrSpecial = password.contains(RegExp(r'[0-9]')) ||
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (!hasNumberOrSpecial) return 'At least one number or special character required';
    return null;
  }

  void _toggleEdit() {
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile != null && !_isEditing) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _passwordController.clear();
      _nameError = null;
      _emailError = null;
      _passwordError = null;
    }
    setState(() => _isEditing = !_isEditing);
  }

  Future<void> _saveChanges() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    final profile = provider.profile;
    if (profile == null) return;

    bool hasError = false;
    
    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Name is required');
      hasError = true;
    } else {
      setState(() => _nameError = null);
    }

    final emailError = _validateEmail(_emailController.text.trim());
    if (emailError != null) {
      setState(() => _emailError = emailError);
      hasError = true;
    } else {
      setState(() => _emailError = null);
    }

    final passwordError = _validatePassword(_passwordController.text.trim());
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      hasError = true;
    } else {
      setState(() => _passwordError = null);
    }

    if (hasError) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => const Center(child: CircularProgressIndicator()),
    );

    final success = await provider.updateProfile(
      userId: profile.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
        );
        _toggleEdit();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Failed to update profile'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _cancelEdit() {
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _passwordController.clear();
    }
    _nameError = null;
    _emailError = null;
    _passwordError = null;
    setState(() => _isEditing = false);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'manager': return Colors.orange;
      case 'member': return Colors.green;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.profile == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading profile...'),
              ],
            ),
          );
        }

        if (provider.errorMessage != null && provider.profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Error loading profile', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(provider.errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchProfile(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final profile = provider.profile!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.person, size: 32, color: Colors.blue[700]),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Profile', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Manage your personal information', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
              ),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            _isUploadingImage
                                ? Container(
                                    width: 100, height: 100,
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                                    child: const Center(child: CircularProgressIndicator()),
                                  )
                                : Container(
                                    width: 100, height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: _selectedImage != null
                                          ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                                          : (profile.profilePicture != null && profile.profilePicture!.isNotEmpty
                                              ? DecorationImage(image: NetworkImage(profile.profilePicture!), fit: BoxFit.cover)
                                              : null),
                                      color: Colors.blue,
                                    ),
                                    child: _selectedImage == null && (profile.profilePicture == null || profile.profilePicture!.isEmpty)
                                        ? Center(child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)))
                                        : null,
                                  ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: GestureDetector(
                                onTap: _showImageSourceDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: _getRoleColor(profile.role).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                          child: Text(profile.role.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getRoleColor(profile.role))),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      if (!_isEditing) ...[
                        _buildInfoCard(icon: Icons.person_outline, label: 'Full Name', value: profile.name, color: Colors.blue),
                        const SizedBox(height: 16),
                        _buildInfoCard(icon: Icons.email_outlined, label: 'Email Address', value: profile.email, color: Colors.blue),
                        const SizedBox(height: 16),
                        _buildInfoCard(icon: Icons.badge_outlined, label: 'User ID', value: profile.id, color: Colors.grey, isCopyable: true),
                        const SizedBox(height: 16),
                        _buildInfoCard(icon: Icons.calendar_today, label: 'Member Since', value: _formatDate(profile.createdAt), color: Colors.grey),
                      ] else ...[
                        _buildTextField(label: 'Full Name', controller: _nameController, icon: Icons.person_outline, enabled: _isEditing, errorText: _nameError),
                        const SizedBox(height: 16),
                        _buildTextField(label: 'Email Address', controller: _emailController, icon: Icons.email_outlined, enabled: _isEditing, errorText: _emailError, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _buildTextField(label: 'New Password', controller: _passwordController, icon: Icons.lock_outline, enabled: _isEditing, errorText: _passwordError, obscureText: true, helperText: 'Leave empty to keep current password'),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(label: 'User ID', value: profile.id, icon: Icons.badge_outlined),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(label: 'Member Since', value: _formatDate(profile.createdAt), icon: Icons.calendar_today),
                      ],
                      const SizedBox(height: 24),

                      if (_isEditing)
                        Row(
                          children: [
                            Expanded(child: OutlinedButton(onPressed: provider.isUpdating ? null : _cancelEdit, child: const Text('CANCEL'))),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: provider.isUpdating ? null : _saveChanges,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                child: provider.isUpdating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('SAVE CHANGES'),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _toggleEdit,
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required IconData icon, required String label, required String value, required Color color, bool isCopyable = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 20, color: color)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (isCopyable)
            IconButton(
              icon: Icon(Icons.copy, size: 18, color: Colors.grey[400]),
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID copied to clipboard'), duration: Duration(seconds: 1))),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, required IconData icon, required bool enabled, String? errorText, String? helperText, TextInputType? keyboardType, bool obscureText = false}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        errorText: errorText,
        helperText: helperText,
        helperStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}