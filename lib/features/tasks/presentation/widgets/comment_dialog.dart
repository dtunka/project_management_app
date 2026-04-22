import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../../data/models/task_model.dart';

Future<void> showCommentDialog(BuildContext context, TaskModel task) async {
  final commentController = TextEditingController();
  bool isLoading = false;

  return showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.comment, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text('Comments'),
            ],
          ),
          content: Container(
            width: 450,
            height: 400,
            child: Column(
              children: [
                // Comments List
                Expanded(
                  child: task.comments.isEmpty
                      ? const Center(
                          child: Text(
                            'No comments yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: task.comments.length,
                          itemBuilder: (context, index) {
                            final comment = task.comments[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.blue[100],
                                          child: Text(
                                            comment.userName.isNotEmpty
                                                ? comment.userName[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _formatDate(comment.createdAt),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      comment.text,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    if (comment.attachments.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: comment.attachments.map((url) {
                                          return Chip(
                                            label: Text('Attachment'),
                                            avatar: const Icon(Icons.attach_file, size: 16),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(),
                // Comment Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Write your comment...',
                          border: InputBorder.none,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (commentController.text.trim().isEmpty) return;
                              
                              setDialogState(() => isLoading = true);
                              
                              final taskProvider = Provider.of<TaskProvider>(
                                dialogContext,
                                listen: false,
                              );
                              await taskProvider.addComment(
                                task.id,
                                commentController.text.trim(),
                              );
                              
                              if (dialogContext.mounted) {
                                setDialogState(() => isLoading = false);
                                commentController.clear();
                                // Refresh task list to show new comment
                                await taskProvider.fetchTasks();
                              }
                            },
                      icon: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send, color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    ),
  );
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}