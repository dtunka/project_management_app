import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/team_provider.dart';
import '../../data/models/team_model.dart';
import '../../../authorization/presentation/providers/auth_provider.dart';

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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final teamProvider = Provider.of<TeamProvider>(context, listen: false);
        final userRole = authProvider.user?.role.toLowerCase() ?? 'member';
        if (userRole == 'member') {
          teamProvider.fetchMyTeams(); // Fetch only member's teams
        } else {
          teamProvider.fetchTeams(); // Fetch all teams for admin/manager
        }
        teamProvider.fetchAvailableMembers();
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
                          nameError = value.isEmpty
                              ? 'Team name is required'
                              : null;
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
                          descriptionError = value.isEmpty
                              ? 'Description is required'
                              : null;
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
                                  final member =
                                      provider.availableMembers[index];
                                  final isSelected = selectedMemberIds.contains(
                                    member.id,
                                  );

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
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
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
                onPressed: isLoading
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate
                        if (nameController.text.trim().isEmpty) {
                          setDialogState(
                            () => nameError = 'Team name is required',
                          );
                          return;
                        }
                        if (descriptionController.text.trim().isEmpty) {
                          setDialogState(
                            () => descriptionError = 'Description is required',
                          );
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
                                content: Text(
                                  'Team "${newTeam.name}" created successfully',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(dialogContext);
                          } else {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  provider.errorMessage ??
                                      'Failed to create team',
                                ),
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
                          nameError = value.isEmpty
                              ? 'Team name is required'
                              : null;
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
                          descriptionError = value.isEmpty
                              ? 'Description is required'
                              : null;
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
                                  final member =
                                      provider.availableMembers[index];
                                  final isSelected = selectedMemberIds.contains(
                                    member.id,
                                  );

                                  // Check if this member is currently in the team
                                  final isCurrentMember = team.members.any(
                                    (m) => m.id == member.id,
                                  );

                                  return CheckboxListTile(
                                    value: isSelected,
                                    title: Text(
                                      member.name,
                                      style: TextStyle(
                                        fontWeight: isCurrentMember
                                            ? FontWeight.w600
                                            : FontWeight.normal,
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
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    dense: true,
                                    secondary: isCurrentMember
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 14,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _getMemberChangeSummary(
                                          team,
                                          selectedMemberIds,
                                        ),
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
                onPressed: isLoading
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        // Validate
                        if (nameController.text.trim().isEmpty) {
                          setDialogState(
                            () => nameError = 'Team name is required',
                          );
                          return;
                        }
                        if (descriptionController.text.trim().isEmpty) {
                          setDialogState(
                            () => descriptionError = 'Description is required',
                          );
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
                          final currentMemberIds = team.members
                              .map((m) => m.id)
                              .toList();
                          final membersToAdd = selectedMemberIds
                              .where((id) => !currentMemberIds.contains(id))
                              .toList();
                          final membersToRemove = currentMemberIds
                              .where((id) => !selectedMemberIds.contains(id))
                              .toList();

                          // STEP 3: Add new members
                          bool allAdded = true;
                          for (final memberId in membersToAdd) {
                            try {
                              final result = await provider.addMemberToTeam(
                                team.id,
                                memberId,
                              );
                              if (result == null) {
                                allAdded = false;
                              }
                            } catch (_) {
                              allAdded = false;
                            }
                          }

                          // STEP 4: Remove members that were deselected
                          for (final memberId in membersToRemove) {
                            try {
                              await provider.removeMemberFromTeam(
                                team.id,
                                memberId,
                              );
                            } catch (_) {}
                          }

                          // STEP 5: CRITICAL - Refresh all teams to get the latest data
                          await provider.fetchTeams();

                          if (dialogContext.mounted) {
                            if (allAdded || membersToAdd.isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Team "${updatedTeam.name}" updated successfully',
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Team updated but some members could not be added',
                                  ),
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
                                content: Text(
                                  provider.errorMessage ??
                                      'Failed to update team',
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

  // Helper method to check if there are member changes
  bool _hasMemberChanges(TeamModel team, List<String> selectedMemberIds) {
    final currentMemberIds = team.members.map((m) => m.id).toList();
    return selectedMemberIds.length != currentMemberIds.length ||
        !selectedMemberIds.toSet().containsAll(currentMemberIds);
  }

  // Helper method to show summary of member changes
  String _getMemberChangeSummary(
    TeamModel team,
    List<String> selectedMemberIds,
  ) {
    final currentMemberIds = team.members.map((m) => m.id).toList();
    final membersToAdd = selectedMemberIds
        .where((id) => !currentMemberIds.contains(id))
        .toList();
    final membersToRemove = currentMemberIds
        .where((id) => !selectedMemberIds.contains(id))
        .toList();

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

    if (shouldDelete == true && context.mounted) {
      final provider = Provider.of<TeamProvider>(context, listen: false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) =>
            const Center(child: CircularProgressIndicator()),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userRole = authProvider.user?.role.toLowerCase() ?? 'member';
    final canManageTeams = userRole == 'admin' || userRole == 'manager';

    return Consumer<TeamProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.teams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.indigo.shade600,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading teams...',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }

        if (provider.errorMessage != null && provider.teams.isEmpty) {
          return _EmptyState(
            icon: Icons.error_outline,
            iconColor: Colors.red.shade400,
            title: 'Unable to load teams',
            message: provider.errorMessage!,
            action: OutlinedButton.icon(
              onPressed: () => _refreshTeams(provider, userRole),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          );
        }

        final filteredTeams = provider.searchTeams(_searchQuery);
        final totalMembers = provider.teams.fold<int>(
          0,
          (sum, team) => sum + team.memberCount,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 760;

                  final headerText = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teams',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        canManageTeams
                            ? 'Organize people, responsibilities, and access.'
                            : 'View your team membership and collaborators.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );

                  final createButton = canManageTeams
                      ? FilledButton.icon(
                          onPressed: () => _showCreateTeamDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Team'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isCompact) ...[
                        headerText,
                        if (canManageTeams) ...[
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: createButton,
                          ),
                        ],
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: headerText),
                            if (canManageTeams) createButton,
                          ],
                        ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricTile(
                            icon: Icons.groups_outlined,
                            label: 'Total Teams',
                            value: provider.teams.length.toString(),
                            color: Colors.indigo,
                          ),
                          _MetricTile(
                            icon: Icons.people_alt_outlined,
                            label: 'Members',
                            value: totalMembers.toString(),
                            color: Colors.teal,
                          ),
                          _MetricTile(
                            icon: Icons.manage_search_outlined,
                            label: 'Showing',
                            value: filteredTeams.length.toString(),
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by team name or description',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.close, size: 18),
                          ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),

            if (filteredTeams.isEmpty)
              Expanded(
                child: _EmptyState(
                  icon: Icons.groups_outlined,
                  iconColor: Colors.indigo.shade300,
                  title: _searchQuery.isEmpty
                      ? 'No teams yet'
                      : 'No matching teams',
                  message: _searchQuery.isEmpty
                      ? 'Create a team to start grouping members around work.'
                      : 'Try another keyword or clear the search filter.',
                  action: _searchQuery.isEmpty
                      ? (canManageTeams
                            ? FilledButton.icon(
                                onPressed: () => _showCreateTeamDialog(context),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('New Team'),
                              )
                            : null)
                      : TextButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: const Text('Clear search'),
                        ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RefreshIndicator(
                        onRefresh: () => _refreshTeams(provider, userRole),
                        color: Colors.indigo,
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: filteredTeams.length,
                          separatorBuilder: (_, index) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (context, index) {
                            final team = filteredTeams[index];
                            final bool isExpanded =
                                provider.expandedIndex == index;

                            return _TeamRow(
                              team: team,
                              isExpanded: isExpanded,
                              canManageTeams: canManageTeams,
                              isBusy: provider.isLoading,
                              onToggle: () => provider.toggleExpand(index),
                              onEdit: () => _showEditTeamDialog(context, team),
                              onDelete: () => _confirmDelete(context, team),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _refreshTeams(TeamProvider provider, String userRole) {
    if (userRole == 'member') {
      return provider.fetchMyTeams();
    }

    return provider.fetchTeams();
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final MaterialColor color;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color.shade700, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.grey.shade900,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final TeamModel team;
  final bool isExpanded;
  final bool canManageTeams;
  final bool isBusy;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeamRow({
    required this.team,
    required this.isExpanded,
    required this.canManageTeams,
    required this.isBusy,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isExpanded
          ? Colors.indigo.shade50.withValues(alpha: 0.35)
          : Colors.white,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TeamAvatar(name: team.name),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                team.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade900,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _MemberBadge(count: team.memberCount),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          team.description.isEmpty
                              ? 'No description provided.'
                              : team.description,
                          maxLines: isExpanded ? 4 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 18),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 16),
                Text(
                  'Members',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (team.members.isEmpty)
                  Text(
                    'No members assigned yet.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: team.members.map((member) {
                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: Colors.indigo.shade50,
                          child: Text(
                            member.name.isEmpty
                                ? '?'
                                : member.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        label: Text(member.name),
                        labelStyle: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),
                if (canManageTeams) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isBusy ? null : onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.indigo.shade700,
                          side: BorderSide(color: Colors.indigo.shade100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: isBusy ? null : onDelete,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  final String name;

  const _TeamAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.indigo.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MemberBadge extends StatelessWidget {
  final int count;

  const _MemberBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_alt_outlined,
            size: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final Widget? action;

  const _EmptyState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 34, color: iconColor),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (action != null) ...[const SizedBox(height: 18), action!],
            ],
          ),
        ),
      ),
    );
  }
}
