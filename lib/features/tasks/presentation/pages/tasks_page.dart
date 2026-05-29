import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../widgets/create_task_dialog.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../teams/presentation/providers/team_provider.dart';
import '../widgets/comment_dialog.dart';
import '../../../authorization/presentation/providers/auth_provider.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() {
    Future.microtask(() {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final userRole = authProvider.user?.role?.toLowerCase() ?? 'member';
        
        if (userRole == 'member') {
          taskProvider.fetchMyTasks(); // Fetch only member's tasks
        } else {
          taskProvider.fetchTasks(); // Fetch all tasks for manager
        }
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

  List<TaskModel> _getFilteredTasks(List<TaskModel> tasks) {
    if (_searchQuery.isEmpty) return tasks;
    return tasks.where((task) =>
      task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      task.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  // Member can only view tasks, not edit or delete
  bool _canEditTask(String userRole) {
    return userRole == 'manager';
  }

  bool _canDeleteTask(String userRole) {
    return userRole == 'manager';
  }

  bool _canCreateTask(String userRole) {
    return userRole == 'manager';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final userRole = authProvider.user?.role?.toLowerCase() ?? 'member';
    
    final allTasks = taskProvider.getFilteredTasks();
    final filteredTasks = _getFilteredTasks(allTasks);

    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header with Task Count and New Task Button (only for manager)
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
                    decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.task, color: Colors.purple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Tasks', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      Text('${filteredTasks.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple)),
                    ],
                  ),
                ],
              ),
              // New Task Button - Only for Manager
              if (_canCreateTask(userRole))
                ElevatedButton.icon(
                  onPressed: () => showCreateTaskDialog(context),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
            ],
          ),
        ),

        // Search and Filter Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: DropdownButton<String>(
                  value: taskProvider.statusFilter,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.filter_list),
                  onChanged: (String? newValue) {
                    taskProvider.setStatusFilter(newValue!);
                  },
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Status')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tasks List
        if (filteredTasks.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No tasks found', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => userRole == 'member' ? taskProvider.fetchMyTasks() : taskProvider.fetchTasks(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  final bool isExpanded = taskProvider.expandedIndex == index;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 8,
                            height: 40,
                            decoration: BoxDecoration(
                              color: task.statusColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: task.priorityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Text(task.priorityText, style: TextStyle(fontSize: 10, color: task.priorityColor)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: task.statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Text(task.statusText, style: TextStyle(fontSize: 10, color: task.statusColor)),
                                  ),
                                  Text('Due: ${_formatDate(task.deadline)}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                ],
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey[600]),
                            onPressed: () => taskProvider.toggleExpand(index),
                          ),
                        ),
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow(Icons.folder, 'Project', task.projectName),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.people, 'Assignees', task.assignees.map((a) => a.name).join(', ')),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.priority_high, 'Priority', task.priorityText),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.event, 'Deadline', _formatDate(task.deadline)),
                                const SizedBox(height: 8),
                                _buildDetailRow(Icons.comment, 'Comments', '${task.comments.length} comments'),
                                const SizedBox(height: 16),
                                // Action Buttons - Only show for Manager
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Comment button - Available for both
                                    OutlinedButton.icon(
                                      onPressed: () => showCommentDialog(context, task),
                                      icon: const Icon(Icons.comment, size: 16),
                                      label: const Text('Comment'),
                                    ),
                                    // Edit button - Only for Manager
                                    if (_canEditTask(userRole)) ...[
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _showEditTaskDialog(task),
                                        icon: const Icon(Icons.edit, size: 16),
                                        label: const Text('Edit'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                      ),
                                    ],
                                    // Delete button - Only for Manager
                                    if (_canDeleteTask(userRole)) ...[
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _confirmDeleteTask(task),
                                        icon: const Icon(Icons.delete, size: 16),
                                        label: const Text('Delete'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(width: 80, child: Text('$label:', style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ],
    );
  }

  // Show edit task dialog (only for manager)
// Show edit task dialog
Future<void> _showEditTaskDialog(TaskModel task) async {
  final titleController = TextEditingController(text: task.title);
  final descriptionController = TextEditingController(text: task.description);
  final deadlineController = TextEditingController(text: _formatDate(task.deadline));
  
  String selectedStatus = task.status;
  String selectedPriority = task.priority;
  DateTime? selectedDeadline = task.deadline;
  List<String> selectedAssigneeIds = task.assignees.map((a) => a.id).toList();
  
  bool isLoading = false;
  String? _titleError;
  String? _descriptionError;
  
  // For project and team members
  List<dynamic> projects = [];
  List<dynamic> teamMembers = [];
  String? selectedProjectId = task.projectId;
  bool isLoadingProjects = true;
  bool isLoadingMembers = false;

  // Load projects first
  final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
  await projectProvider.fetchProjects();
  projects = projectProvider.projects;
  isLoadingProjects = false;

  // Load team members for the selected project
  if (selectedProjectId != null) {
    isLoadingMembers = true;
    try {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      await teamProvider.fetchTeams();
      
      // Find the project to get its team
      final project = projects.firstWhere((p) => p.id == selectedProjectId);
      final team = teamProvider.teams.firstWhere(
        (t) => t.id == project.team.id,
        orElse: () => teamProvider.teams.first,
      );
      teamMembers = team.members;
    } catch (e) {
      print('Error loading team members: $e');
    }
    isLoadingMembers = false;
  }

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (innerContext, setDialogState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Edit Task'),
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
                  if (isLoadingProjects)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<String>(
                      value: selectedProjectId,
                      decoration: const InputDecoration(
                        labelText: 'Project',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: [
                        ...projects.map((project) {
                          return DropdownMenuItem<String>(
                            value: project.id.toString(),
                            child: Text(project.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) async {
                        setDialogState(() {
                          selectedProjectId = value;
                          selectedAssigneeIds.clear();
                          teamMembers.clear();
                          isLoadingMembers = true;
                        });
                        
                        if (value != null) {
                          // Load team members for the selected project
                          final teamProvider = Provider.of<TeamProvider>(innerContext, listen: false);
                          await teamProvider.fetchTeams();
                          final project = projects.firstWhere((p) => p.id == value);
                          final team = teamProvider.teams.firstWhere(
                            (t) => t.id == project.team.id,
                            orElse: () => teamProvider.teams.first,
                          );
                          setDialogState(() {
                            teamMembers = team.members;
                            isLoadingMembers = false;
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

                  // Assignees Selection
                  if (isLoadingMembers)
                    const Center(child: CircularProgressIndicator())
                  else if (teamMembers.isNotEmpty)
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
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDeadline = pickedDate;
                          deadlineController.text = _formatDate(pickedDate);
                        });
                      }
                    },
                    child: IgnorePointer(
                      child: TextField(
                        controller: deadlineController,
                        decoration: InputDecoration(
                          labelText: 'Deadline',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.event),
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

                      setDialogState(() => isLoading = true);

                      // Prepare update data
                      Map<String, dynamic> updateData = {
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'status': selectedStatus,
                        'priority': selectedPriority,
                        'deadline': selectedDeadline!.toIso8601String(),
                      };

                      // Add assignees if selected (use 'assignedTo' field)
                      if (selectedAssigneeIds.isNotEmpty) {
                        updateData['assignedTo'] = selectedAssigneeIds;
                      }

                      // Only update project if changed
                      if (selectedProjectId != task.projectId) {
                        updateData['project'] = selectedProjectId;
                      }

                      print('Updating task with data: $updateData');

                      final taskProvider = Provider.of<TaskProvider>(dialogContext, listen: false);
                      final updatedTask = await taskProvider.updateTask(task.id, updateData);

                      if (dialogContext.mounted) {
                        if (updatedTask != null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            const SnackBar(
                              content: Text('Task updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(dialogContext);
                        } else {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(taskProvider.errorMessage ?? 'Failed to update task'),
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
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('SAVE'),
            ),
          ],
        );
      },
    ),
  );
}

  // Confirm delete task (only for manager)
  Future<void> _confirmDeleteTask(TaskModel task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this task?'),
            const SizedBox(height: 8),
            Text('Task: "${task.title}"', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Project: ${task.projectName}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
      showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final success = await taskProvider.deleteTask(task.id);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Task deleted successfully' : taskProvider.errorMessage ?? 'Failed to delete task'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}