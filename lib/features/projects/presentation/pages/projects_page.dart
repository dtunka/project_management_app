import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../../data/models/project_model.dart';
import '../../../authorization/presentation/providers/auth_provider.dart';
import '../../../teams/presentation/providers/team_provider.dart';
class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    Future.microtask(() {
      if (mounted) {
        final provider = Provider.of<ProjectProvider>(context, listen: false);
        provider.fetchProjects();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Show create project dialog
  Future<void> _showCreateProjectDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    
    String? selectedTeamId;
    String selectedStatus = 'planning';
    DateTime? selectedStartDate;
    DateTime? selectedEndDate;
    
    bool isLoading = false;
    String? _nameError;
    String? _descriptionError;
    String? _teamError;
    String? _startDateError;
    String? _endDateError;

    // Fetch teams for dropdown
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    await teamProvider.fetchTeams();

    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.folder, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text('Create New Project'),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                width: 500,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Project Name Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Project Name *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.folder),
                        errorText: _nameError,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          _nameError = value.isEmpty ? 'Project name is required' : null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.description),
                        errorText: _descriptionError,
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setDialogState(() {
                          _descriptionError = value.isEmpty ? 'Description is required' : null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Team Selection Dropdown
                    Consumer<TeamProvider>(
                      builder: (context, teamProvider, child) {
                        if (teamProvider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final teams = teamProvider.teams;
                        
                        return DropdownButtonFormField<String>(
                          value: selectedTeamId,
                          decoration: InputDecoration(
                            labelText: 'Select Team *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.groups),
                            errorText: _teamError,
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Select a team'),
                            ),
                            ...teams.map((team) {
                              return DropdownMenuItem(
                                value: team.id,
                                child: Text(team.name),
                              );
                            }).toList(),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedTeamId = value;
                              _teamError = selectedTeamId == null ? 'Please select a team' : null;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'planning', child: Text('Planning')),
                        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                        DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
                        DropdownMenuItem(value: 'completed', child: Text('Completed')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Start Date Picker
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedStartDate = pickedDate;
                            startDateController.text = _formatDate(pickedDate);
                            _startDateError = null;
                          });
                        }
                      },
                      child: IgnorePointer(
                        child: TextField(
                          controller: startDateController,
                          decoration: InputDecoration(
                            labelText: 'Start Date *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.calendar_today),
                            errorText: _startDateError,
                            hintText: 'Select start date',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // End Date Picker
                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: selectedStartDate ?? DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 730)),
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedEndDate = pickedDate;
                            endDateController.text = _formatDate(pickedDate);
                            _endDateError = null;
                          });
                        }
                      },
                      child: IgnorePointer(
                        child: TextField(
                          controller: endDateController,
                          decoration: InputDecoration(
                            labelText: 'End Date *',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.event),
                            errorText: _endDateError,
                            hintText: 'Select end date',
                          ),
                        ),
                      ),
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
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate all fields
                        String? nameError = nameController.text.isEmpty ? 'Project name is required' : null;
                        String? descriptionError = descriptionController.text.isEmpty ? 'Description is required' : null;
                        String? teamError = selectedTeamId == null ? 'Please select a team' : null;
                        String? startDateError = selectedStartDate == null ? 'Please select a start date' : null;
                        String? endDateError = selectedEndDate == null ? 'Please select an end date' : null;

                        if (nameError != null || descriptionError != null || teamError != null ||
                            startDateError != null || endDateError != null) {
                          setDialogState(() {
                            _nameError = nameError;
                            _descriptionError = descriptionError;
                            _teamError = teamError;
                            _startDateError = startDateError;
                            _endDateError = endDateError;
                          });
                          return;
                        }

                        setDialogState(() => isLoading = true);

                        // Prepare project data
                        Map<String, dynamic> projectData = {
                          'name': nameController.text.trim(),
                          'description': descriptionController.text.trim(),
                          'team': selectedTeamId,
                          'status': selectedStatus,
                          'startDate': selectedStartDate!.toIso8601String(),
                          'deadline': selectedEndDate!.toIso8601String(),
                          'progress': 0,
                          'contributors': [],
                        };

                        // Call provider to create project
                        final projectProvider = Provider.of<ProjectProvider>(dialogContext, listen: false);
                        final newProject = await projectProvider.createProject(projectData);

                        if (dialogContext.mounted) {
                          if (newProject != null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Project "${newProject.name}" created successfully'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(projectProvider.errorMessage ?? 'Failed to create project'),
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
  // Show edit project dialog
Future<void> _showEditProjectDialog(ProjectModel project) async {
  final nameController = TextEditingController(text: project.name);
  final descriptionController = TextEditingController(text: project.description);
  final startDateController = TextEditingController(text: _formatDate(project.startDate));
  final endDateController = TextEditingController(text: _formatDate(project.deadline));
  
  String selectedStatus = project.status;
  DateTime? selectedStartDate = project.startDate;
  DateTime? selectedEndDate = project.deadline;
  
  bool isLoading = false;
  String? _nameError;
  String? _descriptionError;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Edit Project'),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Project Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Project Name *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.folder),
                      errorText: _nameError,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        _nameError = value.isEmpty ? 'Project name is required' : null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                      errorText: _descriptionError,
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      setDialogState(() {
                        _descriptionError = value.isEmpty ? 'Description is required' : null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.trending_up),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'planning', child: Text('Planning')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'on_hold', child: Text('On Hold')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Start Date Picker
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedStartDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedStartDate = pickedDate;
                          startDateController.text = _formatDate(pickedDate);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextField(
                        controller: startDateController,
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                          hintText: 'Select start date',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // End Date Picker
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedEndDate,
                        firstDate: selectedStartDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedEndDate = pickedDate;
                          endDateController.text = _formatDate(pickedDate);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextField(
                        controller: endDateController,
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                          hintText: 'Select end date',
                        ),
                      ),
                    ),
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
              onPressed: isLoading
                  ? null
                  : () async {
                      // Validate fields
                      if (nameController.text.trim().isEmpty) {
                        setDialogState(() => _nameError = 'Project name is required');
                        return;
                      }
                      if (descriptionController.text.trim().isEmpty) {
                        setDialogState(() => _descriptionError = 'Description is required');
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      // Prepare update data
                      Map<String, dynamic> updateData = {
                        'name': nameController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'status': selectedStatus,
                        'startDate': selectedStartDate?.toIso8601String(),
                        'deadline': selectedEndDate?.toIso8601String(),
                      };

                      // Call provider to update project
                      final projectProvider = Provider.of<ProjectProvider>(dialogContext, listen: false);
                      final updatedProject = await projectProvider.updateProject(project.id, updateData);

                      if (dialogContext.mounted) {
                        if (updatedProject != null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Project updated successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.pop(dialogContext);
                        } else {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(projectProvider.errorMessage ?? 'Failed to update project'),
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
                  : const Text('SAVE'),
            ),
          ],
        );
      },
    ),
  );
}

// Confirm delete project
Future<void> _confirmDeleteProject(ProjectModel project) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text('Are you sure you want to delete project "${project.name}"?'),
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
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingContext) => const Center(child: CircularProgressIndicator()),
    );

    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final success = await projectProvider.deleteProject(project.id);

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(projectProvider.errorMessage ?? 'Failed to delete project'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context);
    final userRole = authProvider.user?.role?.toLowerCase() ?? 'member';
    
    // Check if user can create projects (only Manager)
    final bool canCreateProject = userRole == 'manager';

    final filteredProjects = projectProvider.searchProjects(_searchQuery);

    if (projectProvider.isLoading && projectProvider.projects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading projects...'),
          ],
        ),
      );
    }

    if (projectProvider.errorMessage != null && projectProvider.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading projects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              projectProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => projectProvider.fetchProjects(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with Project Count and Create Button
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
              // Project Count with Icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Projects',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      Text(
                        '${filteredProjects.length}',
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

              // Create Project Button - ONLY visible to Manager
              if (canCreateProject)
                ElevatedButton.icon(
                  onPressed: projectProvider.isLoading ? null : _showCreateProjectDialog,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Project'),
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

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search projects...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Projects List
        if (filteredProjects.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No projects found'
                        : 'No projects matching "$_searchQuery"',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      child: const Text('Clear search'),
                    ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => projectProvider.fetchProjects(),
              color: Colors.blue,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = filteredProjects[index];
                  final bool isExpanded = projectProvider.expandedIndex == index;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Main Project Row
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 8,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getStatusColor(project.status),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(project.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getStatusText(project.status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(project.status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                project.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Manager: ${project.manager.name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.linear_scale,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${project.progress}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(project.status),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => projectProvider.toggleExpand(index),
                          ),
                        ),

                        // Expanded Details
                        if (isExpanded) ...[
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Team Info
                                _buildDetailRow(
                                  icon: Icons.groups,
                                  label: 'Team',
                                  value: project.team.name,
                                ),
                                const SizedBox(height: 8),

                                // Dates
                                _buildDetailRow(
                                  icon: Icons.calendar_today,
                                  label: 'Start Date',
                                  value: _formatDate(project.startDate),
                                ),
                                const SizedBox(height: 8),

                                _buildDetailRow(
                                  icon: Icons.event,
                                  label: 'Deadline',
                                  value: _formatDate(project.deadline),
                                ),
                                const SizedBox(height: 8),

                                // Manager Email
                                _buildDetailRow(
                                  icon: Icons.email_outlined,
                                  label: 'Manager Email',
                                  value: project.manager.email,
                                ),
                                const SizedBox(height: 12),

                                // Contributors Section
                                if (project.contributors.isNotEmpty) ...[
                                  const Text(
                                    'Contributors',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: project.contributors.map((contributor) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          contributor.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],

                                const SizedBox(height: 12),

                                // Progress Bar
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Progress',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${project.progress}%',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(project.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: project.progress / 100,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _getStatusColor(project.status),
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Action Buttons (Only visible to Manager who owns the project)
if (projectProvider.canEditProject(project) || projectProvider.canDeleteProject(project))
  Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      if (projectProvider.canEditProject(project))
        ElevatedButton.icon(
          onPressed: projectProvider.isUpdating
              ? null
              : () => _showEditProjectDialog(project),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      if (projectProvider.canEditProject(project) && projectProvider.canDeleteProject(project))
        const SizedBox(width: 8),
      if (projectProvider.canDeleteProject(project))
        ElevatedButton.icon(
          onPressed: projectProvider.isDeleting
              ? null
              : () => _confirmDeleteProject(project),
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
    ],
  ),
                              ],
                            ),
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'planning':
        return Colors.purple;
      case 'on_hold':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      case 'planning':
        return 'Planning';
      case 'on_hold':
        return 'On Hold';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}