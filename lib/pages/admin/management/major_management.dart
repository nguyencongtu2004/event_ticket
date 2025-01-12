import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/university.dart';
import 'package:event_ticket/requests/university_request.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class MajorManagementScreen extends StatefulWidget {
  const MajorManagementScreen({super.key, required this.faculty});

  final Faculty faculty;

  @override
  State<MajorManagementScreen> createState() => _MajorManagementScreenState();
}

class _MajorManagementScreenState extends State<MajorManagementScreen> {
  final _universityRequest = UniversityRequest();
  late Future<List<Major>> _majorFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _majorFuture = _fetchMajors();
  }

  Future<List<Major>> _fetchMajors() async {
    final response =
        await _universityRequest.getMajorsByFacultyId(widget.faculty.id!);
    setState(() => _isLoading = false);
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => Major.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      context.showAnimatedToast(response.data['message']);
      return [];
    }
  }

  Future<void> _refreshMajors() async {
    setState(() => _majorFuture = _fetchMajors());
  }

  void onAddMajor() {
    final nameController = TextEditingController();

    void handleSave() async {
      final name = nameController.text;
      if (name.isEmpty) return;
      final response =
          await _universityRequest.createMajor(widget.faculty.id!, name);
      if (response.statusCode == 201) {
        setState(() => _majorFuture = _fetchMajors());
      }
      context.showAnimatedToast(response.data['message']);
      Navigator.pop(context);
    }

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Major',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).pOnly(bottom: 20),
            TextField(
              controller: nameController,
              focusNode: FocusNode()..requestFocus(),
              decoration: const InputDecoration(labelText: 'Major Name'),
            ).pOnly(bottom: 20),
            ElevatedButton.icon(
              onPressed: handleSave,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ).pOnly(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20);
      },
    );
  }

  void onDeleteMajor(Major major) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${major.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _universityRequest.deleteMajor(major.id!);
      if (response.statusCode == 200) {
        setState(() => _majorFuture = _fetchMajors());
      }
      if (mounted) {
        context.showAnimatedToast(response.data['message']);
      }
    }
  }

  void onEditMajor(Major major) async {
    if (major.id == null) return;
    final nameController = TextEditingController(text: major.name);

    void handleSave() async {
      final name = nameController.text;
      if (name.isEmpty) return;
      Navigator.pop(context);
      final response = await _universityRequest.updateMajor(major.id!, name);
      if (response.statusCode == 200) {
        setState(() => _majorFuture = _fetchMajors());
      }
      context.showAnimatedToast(response.data['message']);
    }

    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            TextField(
              controller: nameController,
              focusNode: FocusNode()..requestFocus(),
              decoration: const InputDecoration(labelText: 'Major Name'),
            ),
            ElevatedButton.icon(
              onPressed: handleSave,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ],
        ).pOnly(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Major Management',
      floatingActionButton: FloatingActionButton(
        onPressed: onAddMajor,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Major>>(
        future: _majorFuture,
        builder: (context, snapshot) {
          final isLoading = _isLoading;
          final majors = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refreshMajors,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // Phần thông tin khoa
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Faculty: ${widget.faculty.name}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).expand(),
                  ],
                ).p(16),
                // Tiêu đề danh sách ngành
                Text(
                  'Majors:',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ).pOnly(left: 16),
                const SizedBox(height: 16),
                // Hiển thị trạng thái tải dữ liệu
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (snapshot.hasError)
                  Center(child: Text('Error: ${snapshot.error}'))
                else if (majors.isEmpty)
                  const Center(child: Text('No majors found'))
                else
                  ...majors.map(
                    (major) => Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          major.name ?? 'No name',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => onEditMajor(major),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => onDeleteMajor(major),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
