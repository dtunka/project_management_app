import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../teams/presentation/providers/team_provider.dart';
import '../../../authorization/presentation/providers/auth_provider.dart';

Future<void> showCreateTaskDialog(BuildContext context) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final deadlineController = TextEditingController();
  
  String? selectedProjectId;
  String selectedStatus = 'pending';
  String selectedPriority = 'medium';
  DateTime? selectedDeadline;
  List<String> selectedAssigneeIds = [];
  List<dynamic> teamMembers = [];
  
  bool isLoading = false;
  String? _titleError;
  String? _descriptionError;
  String? _projectError;
  String? _deadlineError;

  // Get projects for dropdown
  final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
  await projectProvider.fetchProjects();
  final projects = projectProvider.projects;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (innerContext, setDialogState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.task, color: Colors.green[700]),
              const SizedBox(width: 8),
              const Text('Create New Task'),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Task Title Field
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.title),
                      errorText: _titleError,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        _titleError = value.isEmpty ? 'Title is required' : null;
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

                  // Project Selection Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedProjectId,
                    decoration: InputDecoration(
                      labelText: 'Select Project *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.folder),
                      errorText: _projectError,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Select a project'),
                      ),
                      ...projects.map((project) {
                        return DropdownMenuItem(
                          value: project.id,
                          child: Text(project.name),
                        );
                      }).toList(),
                    ],
                  // When selecting a project, print the project object
onChanged: (value) async {
  setDialogState(() {
    selectedProjectId = value;
    _projectError = selectedProjectId == null ? 'Please select a project' : null;
    selectedAssigneeIds.clear();
    teamMembers.clear();
  });
  
  if (value != null) {
    // Find the selected project
    final selectedProject = projects.firstWhere((p) => p.id == value);
    print('Selected project: ${selectedProject.name}');
    print('Project ID: ${selectedProject.id}');
    print('Project ID type: ${selectedProject.id.runtimeType}');
    
    // Fetch team members for the selected project
    final teamProvider = Provider.of<TeamProvider>(innerContext, listen: false);
    await teamProvider.fetchTeams();
    // Find the team for this project - use project.team.id
    final team = teamProvider.teams.firstWhere(
      (t) => t.id == selectedProject.team.id,
      orElse: () => teamProvider.teams.first,
    );
    setDialogState(() {
      teamMembers = team.members;
      print('Team members loaded: ${teamMembers.length}');
       for (var member in teamMembers) {
    print('  Member: ${member.name}, ID: ${member.id}');
  }
    });
  }
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
                      DropdownMenuItem(value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(value: 'completed', child: Text('Completed')),
                      DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Priority Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'critical', child: Text('Critical')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedPriority = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Assignees Selection (Multi-select)
                  if (teamMembers.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assign To',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: teamMembers.length,
                            itemBuilder: (context, index) {
                              final member = teamMembers[index];
                              final isSelected = selectedAssigneeIds.contains(member.id);
                              return CheckboxListTile(
                                value: isSelected,
                                title: Text(member.name),
                                subtitle: Text(member.email),
                                onChanged: (selected) {
                                  setDialogState(() {
                                    if (selected == true) {
                                      selectedAssigneeIds.add(member.id);
                                    } else {
                                      selectedAssigneeIds.remove(member.id);
                                    }
                                  });
                                },
                                dense: true,
                                controlAffinity: ListTileControlAffinity.leading,
                              );
                            },
                          ),
                        ),
                        if (selectedAssigneeIds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Selected: ${selectedAssigneeIds.length} member(s)',
                              style: TextStyle(fontSize: 12, color: Colors.green[700]),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Deadline Date Picker
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: innerContext,
                        initialDate: selectedDeadline ?? DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDeadline = pickedDate;
                          deadlineController.text = _formatDate(pickedDate);
                          _deadlineError = null;
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextField(
                        controller: deadlineController,
                        decoration: InputDecoration(
                          labelText: 'Deadline *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.event),
                          errorText: _deadlineError,
                          hintText: 'Select deadline',
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
                      if (titleController.text.trim().isEmpty) {
                        setDialogState(() => _titleError = 'Title is required');
                        return;
                      }
                      if (descriptionController.text.trim().isEmpty) {
                        setDialogState(() => _descriptionError = 'Description is required');
                        return;
                      }
                      if (selectedProjectId == null) {
                        setDialogState(() => _projectError = 'Please select a project');
                        return;
                      }
                      if (selectedDeadline == null) {
                        setDialogState(() => _deadlineError = 'Please select a deadline');
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      // Get current user (manager) ID from AuthProvider using dialogContext
                      final authProvider = Provider.of<AuthProvider>(dialogContext, listen: false);
                      final currentUserId = authProvider.user?.id ?? '';

                      // Prepare task data with correct format
                      Map<String, dynamic> taskData = {
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'project': selectedProjectId,  // Use 'project' not 'projectId'
                        'status': selectedStatus,
                        'priority': selectedPriority,
                        'deadline': selectedDeadline!.toIso8601String(),
                        'createdBy': currentUserId,  // Add creator ID
                      };

                      // Add assignees if selected (as list of IDs)
                      if (selectedAssigneeIds.isNotEmpty) {
                        taskData['assignedTo'] = selectedAssigneeIds;
                      }else {
  
                      print('WARNING: No assignees selected for this task!');
                      }

                      print('Task data being sent: $taskData');

                      final taskProvider = Provider.of<TaskProvider>(dialogContext, listen: false);
                      final newTask = await taskProvider.createTask(taskData);

                      if (dialogContext.mounted) {
                        if (newTask != null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Task created successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(dialogContext);
                        } else {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(taskProvider.errorMessage ?? 'Failed to create task'),
                              backgroundColor: Colors.red,
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
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('CREATE'),
            ),
          ],
        );
      },
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}