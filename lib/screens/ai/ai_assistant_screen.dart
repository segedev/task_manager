import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/ai_provider.dart';
import 'package:task_manager/providers/project_provider.dart';
import 'package:task_manager/providers/task_provider.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _promptController = TextEditingController();
  String? _selectedProjectId;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateTasks() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a prompt')));
      return;
    }

    if (_selectedProjectId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a project')));
      return;
    }

    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    await aiProvider.generateTasks(
      _promptController.text.trim(),
      _selectedProjectId!,
    );
  }

  Future<void> _importTasks() async {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    await taskProvider.addTasksFromAI(aiProvider.generatedTasks);
    aiProvider.clearGeneratedTasks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${aiProvider.generatedTasks.length} tasks imported successfully!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Consumer3<AIProvider, ProjectProvider, TaskProvider>(
        builder: (context, aiProvider, projectProvider, taskProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.pink.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.psychology, size: 32, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'AI Task Assistant',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Let AI help you plan and organize your tasks',
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Example Prompts
                const Text(
                  'Try these examples:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ExampleChip(
                      text: 'Plan my week with 3 work tasks',
                      onTap:
                          () =>
                              _promptController.text =
                                  'Plan my week with 3 work tasks',
                    ),
                    _ExampleChip(
                      text: 'Create 2 wellness tasks for today',
                      onTap:
                          () =>
                              _promptController.text =
                                  'Create 2 wellness tasks for today',
                    ),
                    _ExampleChip(
                      text: 'Help me organize my project launch',
                      onTap:
                          () =>
                              _promptController.text =
                                  'Help me organize my project launch',
                    ),
                    _ExampleChip(
                      text: 'Weekly meal planning tasks',
                      onTap:
                          () =>
                              _promptController.text =
                                  'Weekly meal planning tasks',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Project Selection
                DropdownButtonFormField<String>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Select Project',
                    prefixIcon: Icon(Icons.folder),
                  ),
                  items:
                      projectProvider.projects.map((project) {
                        return DropdownMenuItem(
                          value: project.id,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Color(
                                    int.parse(
                                      project.color.replaceFirst('#', '0xFF'),
                                    ),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(project.name),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectId = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Prompt Input
                TextFormField(
                  controller: _promptController,
                  decoration: const InputDecoration(
                    labelText: 'Describe what you want to accomplish',
                    hintText:
                        'e.g., Plan my week with 3 work tasks and 2 wellness tasks',
                    prefixIcon: Icon(Icons.chat),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // Generate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: aiProvider.isLoading ? null : _generateTasks,
                    icon:
                        aiProvider.isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.auto_awesome),
                    label: Text(
                      aiProvider.isLoading ? 'Generating...' : 'Generate Tasks',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Error Message
                if (aiProvider.error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            aiProvider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Generated Tasks
                if (aiProvider.generatedTasks.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Generated Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _importTasks,
                        icon: const Icon(Icons.download),
                        label: const Text('Import All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: aiProvider.generatedTasks.length,
                    itemBuilder: (context, index) {
                      final task = aiProvider.generatedTasks[index];
                      return _GeneratedTaskCard(task: task);
                    },
                  ),
                ],

                // Loading Animation
                if (aiProvider.isLoading) ...[
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'AI is analyzing your request...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This may take a few seconds',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.purple.shade600,
                          ),
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
    );
  }
}

class _ExampleChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ExampleChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text),
      onPressed: onTap,
      backgroundColor: Colors.purple.shade50,
      labelStyle: TextStyle(color: Colors.purple.shade700),
    );
  }
}

class _GeneratedTaskCard extends StatelessWidget {
  final Task task;

  const _GeneratedTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
