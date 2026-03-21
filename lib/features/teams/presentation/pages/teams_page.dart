import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../../data/models/team_model.dart';
import '../../data/models/team_member_model.dart';

class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
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
        final provider = Provider.of<TeamProvider>(context, listen: false);
        provider.fetchTeams();
        provider.fetchAvailableMembers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Show create team dialog
  Future<void> _showCreateTeamDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    List<String> selectedMemberIds = [];
    bool isLoading = false;
    String? nameError;
    String? descriptionError;

    return showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.group_add, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text('Create New Team'),
              ],
            ),
            content: SingleChildScrollView(
              child: Container(
                width: 500,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name Field
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Team Name *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.group),
                        errorText: nameError,
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          nameError = value.isEmpty ? 'Team name is required' : null;
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
                        errorText: descriptionError,
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setDialogState(() {
                          descriptionError = value.isEmpty ? 'Description is required' : null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Members Selection
                    Consumer<TeamProvider>(
                      builder: (context, provider, child) {
                        if (provider.isMembersLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (provider.availableMembers.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('No members available'),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Members',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: provider.availableMembers.length,
                                itemBuilder: (context, index) {
                                  final member = provider.availableMembers[index];
                                  final isSelected = selectedMemberIds.contains(member.id);

                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(member.name),
                                    subtitle: Text(member.email),
                                    onChanged: (selected) {
                                      setDialogState(() {
                                        if (selected == true) {
                                          selectedMemberIds.add(member.id);
                                        } else {
                                          selectedMemberIds.remove(member.id);
                                        }
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity.leading,
                                    dense: true,
                                  );
                                },
                              ),
                            ),
                            if (selectedMemberIds.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Selected: ${selectedMemberIds.length} members',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                          ],
                        );
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
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate
                        if (nameController.text.trim().isEmpty) {
                          setDialogState(() => nameError = 'Team name is required');
                          return;
                        }
                        if (descriptionController.text.trim().isEmpty) {
                          setDialogState(() => descriptionError = 'Description is required');
                          return;
                        }

                        setDialogState(() => isLoading = true);

                        final provider = Provider.of<TeamProvider>(
                          dialogContext,
                          listen: false,
                        );
                        final newTeam = await provider.createTeam(
                          name: nameController.text.trim(),
                          description: descriptionController.text.trim(),
                          memberIds: selectedMemberIds,
                        );

                        if (dialogContext.mounted) {
                          if (newTeam != null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Team "${newTeam.name}" created successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(provider.errorMessage ?? 'Failed to create team'),
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

  // Show edit team dialog with member selection
 // Show edit team dialog with member selection
// Show edit team dialog with member selection
Future<void> _showEditTeamDialog(BuildContext context, TeamModel team) async {
  final nameController = TextEditingController(text: team.name);
  final descriptionController = TextEditingController(text: team.description);
  
  // Initialize selected members with current team members
  List<String> selectedMemberIds = team.members.map((m) => m.id).toList();
  
  bool isLoading = false;
  String? nameError;
  String? descriptionError;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Edit Team'),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Team Name *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.group),
                      errorText: nameError,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        nameError = value.isEmpty ? 'Team name is required' : null;
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
                      errorText: descriptionError,
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      setDialogState(() {
                        descriptionError = value.isEmpty ? 'Description is required' : null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Members Selection with Current Members Pre-selected
                  Consumer<TeamProvider>(
                    builder: (context, provider, child) {
                      if (provider.isMembersLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (provider.availableMembers.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('No members available'),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Team Members',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${selectedMemberIds.length} selected',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 300),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: provider.availableMembers.length,
                              itemBuilder: (context, index) {
                                final member = provider.availableMembers[index];
                                final isSelected = selectedMemberIds.contains(member.id);
                                
                                // Check if this member is currently in the team
                                final isCurrentMember = team.members.any((m) => m.id == member.id);

                                return CheckboxListTile(
                                  value: isSelected,
                                  title: Text(
                                    member.name,
                                    style: TextStyle(
                                      fontWeight: isCurrentMember ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  subtitle: Text(member.email),
                                  onChanged: (selected) {
                                    setDialogState(() {
                                      if (selected == true) {
                                        selectedMemberIds.add(member.id);
                                      } else {
                                        selectedMemberIds.remove(member.id);
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                  secondary: isCurrentMember
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Current',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Show summary of changes
                          if (_hasMemberChanges(team, selectedMemberIds))
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 14, color: Colors.blue[700]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _getMemberChangeSummary(team, selectedMemberIds),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
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
              onPressed: isLoading
                  ? null
                  : () async {
                      // Validate
                      if (nameController.text.trim().isEmpty) {
                        setDialogState(() => nameError = 'Team name is required');
                        return;
                      }
                      if (descriptionController.text.trim().isEmpty) {
                        setDialogState(() => descriptionError = 'Description is required');
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      final provider = Provider.of<TeamProvider>(
                        dialogContext,
                        listen: false,
                      );
                      
                      // STEP 1: Update team name and description
                      final updatedTeam = await provider.updateTeam(
                        teamId: team.id,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                      );

                      if (updatedTeam != null) {
                        // STEP 2: Find members to add and remove
                        final currentMemberIds = team.members.map((m) => m.id).toList();
                        final membersToAdd = selectedMemberIds.where((id) => !currentMemberIds.contains(id)).toList();
                        final membersToRemove = currentMemberIds.where((id) => !selectedMemberIds.contains(id)).toList();
                        
                        print('=== Member Changes ===');
                        print('Members to add: $membersToAdd');
                        print('Members to remove: $membersToRemove');
                        
                        // STEP 3: Add new members
                        bool allAdded = true;
                        for (final memberId in membersToAdd) {
                          try {
                            final result = await provider.addMemberToTeam(team.id, memberId);
                            if (result != null) {
                              print('✅ Successfully added member: $memberId');
                            } else {
                              print('❌ Failed to add member: $memberId');
                              allAdded = false;
                            }
                          } catch (e) {
                            print('❌ Error adding member $memberId: $e');
                            allAdded = false;
                          }
                        }
                        
                        // STEP 4: Remove members that were deselected
                        for (final memberId in membersToRemove) {
                          try {
                            final result = await provider.removeMemberFromTeam(team.id, memberId);
                            if (result != null) {
                              print('✅ Successfully removed member: $memberId');
                            } else {
                              print('❌ Failed to remove member: $memberId');
                            }
                          } catch (e) {
                            print('❌ Error removing member $memberId: $e');
                          }
                        }
                        
                        // STEP 5: CRITICAL - Refresh all teams to get the latest data
                        await provider.fetchTeams();
                        
                        if (dialogContext.mounted) {
                          if (allAdded || membersToAdd.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Team "${updatedTeam.name}" updated successfully'),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text('Team updated but some members could not be added'),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                          Navigator.pop(dialogContext);
                        }
                      } else {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(provider.errorMessage ?? 'Failed to update team'),
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

// Helper method to check if there are member changes
bool _hasMemberChanges(TeamModel team, List<String> selectedMemberIds) {
  final currentMemberIds = team.members.map((m) => m.id).toList();
  return selectedMemberIds.length != currentMemberIds.length ||
         !selectedMemberIds.toSet().containsAll(currentMemberIds);
}

// Helper method to show summary of member changes
String _getMemberChangeSummary(TeamModel team, List<String> selectedMemberIds) {
  final currentMemberIds = team.members.map((m) => m.id).toList();
  final membersToAdd = selectedMemberIds.where((id) => !currentMemberIds.contains(id)).toList();
  final membersToRemove = currentMemberIds.where((id) => !selectedMemberIds.contains(id)).toList();
  
  if (membersToAdd.isEmpty && membersToRemove.isEmpty) {
    return 'No changes to team members';
  }
  
  final List<String> changes = [];
  if (membersToAdd.isNotEmpty) {
    changes.add('+${membersToAdd.length} new');
  }
  if (membersToRemove.isNotEmpty) {
    changes.add('-${membersToRemove.length} removed');
  }
  
  return 'Members: ${changes.join(", ")}';
}

  // Show delete confirmation
  Future<void> _confirmDelete(BuildContext context, TeamModel team) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete team "${team.name}"?'),
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
      final provider = Provider.of<TeamProvider>(context, listen: false);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(child: CircularProgressIndicator()),
      );

      final success = await provider.deleteTeam(team.id);

      if (context.mounted) {
        Navigator.pop(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Team "${team.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.errorMessage ?? 'Failed to delete team'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.teams.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading teams...'),
              ],
            ),
          );
        }

        if (provider.errorMessage != null && provider.teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading teams',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchTeams(),
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

        final filteredTeams = provider.searchTeams(_searchQuery);

        return Column(
          children: [
            // Header with Team Count and New Team Button
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
                  // Team Count
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.groups,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teams',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          Text(
                            '${filteredTeams.length}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // New Team Button
                  ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () => _showCreateTeamDialog(context),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('New Team'),
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
                  hintText: 'Search teams...',
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

            // Teams List
            if (filteredTeams.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No teams found'
                            : 'No teams matching "$_searchQuery"',
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
                  onRefresh: () => provider.fetchTeams(),
                  color: Colors.orange,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTeams.length,
                    itemBuilder: (context, index) {
                      final team = filteredTeams[index];
                      final bool isExpanded = provider.expandedIndex == index;

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
                            // Main Team Row
                            ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 8,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              title: Text(
                                team.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    team.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.people,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${team.memberCount} members',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
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
                                onPressed: () => provider.toggleExpand(index),
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
                                    // Members List
                                    const Text(
                                      'Members',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (team.members.isEmpty)
                                      Text(
                                        'No members yet',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[500],
                                        ),
                                      )
                                    else
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: team.members.map((member) {
                                          return Chip(
                                            label: Text(member.name),
                                            avatar: CircleAvatar(
                                              backgroundColor: Colors.orange.shade100,
                                              child: Text(
                                                member.name[0].toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.orange[700],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Edit Button (now handles all member management)
                                        ElevatedButton.icon(
                                          onPressed: provider.isLoading
                                              ? null
                                              : () => _showEditTeamDialog(context, team),
                                          icon: const Icon(Icons.edit, size: 16),
                                          label: const Text('Edit Team'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Delete Button
                                        ElevatedButton.icon(
                                          onPressed: provider.isLoading
                                              ? null
                                              : () => _confirmDelete(context, team),
                                          icon: const Icon(Icons.delete, size: 16),
                                          label: const Text('Delete'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
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
      },
    );
  }
}