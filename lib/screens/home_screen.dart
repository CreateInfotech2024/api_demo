import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _createMeetingFormKey = GlobalKey<FormState>();
  final _joinMeetingFormKey = GlobalKey<FormState>();
  
  final _hostNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingCodeController = TextEditingController();
  final _participantNameController = TextEditingController();

  @override
  void dispose() {
    _hostNameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingCodeController.dispose();
    _participantNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.shade50,
              Colors.purple.shade50,
              Colors.blue.shade50,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const LoadingWidget(message: 'Initializing Beauty LMS...');
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(provider),
                    const SizedBox(height: 32),
                    _buildConnectionStatus(provider),
                    const SizedBox(height: 32),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildCreateMeetingCard(),
                    const SizedBox(height: 24),
                    _buildJoinMeetingCard(),
                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 24),
                      CustomErrorWidget(
                        message: provider.errorMessage!,
                        onRetry: () => provider.healthCheck(),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider provider) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade400, Colors.purple.shade400],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.video_call,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '💄 Beauty LMS',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Video Conferencing & Course Management',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: provider.isConnected ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            provider.isConnected ? Icons.wifi : Icons.wifi_off,
            color: provider.isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Text(
            provider.isConnected ? '🟢 Connected to Backend' : '🔴 Disconnected',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: provider.isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/courses'),
            icon: const Icon(Icons.school),
            label: const Text('📚 Browse Courses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.read<AppProvider>().loadCourses(),
            icon: const Icon(Icons.refresh),
            label: const Text('🔄 Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateMeetingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _createMeetingFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Create New Meeting',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _hostNameController,
                decoration: const InputDecoration(
                  labelText: 'Host Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter host name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter meeting title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _createMeeting,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.video_call),
                    label: Text(provider.isLoading ? 'Creating...' : '🎥 Create Meeting'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinMeetingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _joinMeetingFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Join Existing Meeting',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _meetingCodeController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Code',
                  prefixIcon: Icon(Icons.code),
                  border: OutlineInputBorder(),
                  hintText: 'Enter 6-digit code',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter meeting code';
                  }
                  if (value.trim().length != 6) {
                    return 'Meeting code must be 6 characters';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _participantNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _joinMeeting,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.login),
                    label: Text(provider.isLoading ? 'Joining...' : '🚀 Join Meeting'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createMeeting() async {
    if (!_createMeetingFormKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final success = await provider.createMeeting(
      hostName: _hostNameController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (success && mounted) {
      // Clear form
      _hostNameController.clear();
      _titleController.clear();
      _descriptionController.clear();
      
      // Navigate to meeting screen
      Navigator.pushNamed(context, '/meeting');
    }
  }

  Future<void> _joinMeeting() async {
    if (!_joinMeetingFormKey.currentState!.validate()) return;

    final provider = context.read<AppProvider>();
    final success = await provider.joinMeeting(
      meetingCode: _meetingCodeController.text.trim().toUpperCase(),
      participantName: _participantNameController.text.trim(),
    );

    if (success && mounted) {
      // Clear form
      _meetingCodeController.clear();
      _participantNameController.clear();
      
      // Navigate to meeting screen
      Navigator.pushNamed(context, '/meeting');
    }
  }
}