import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/university.dart';
import 'package:event_ticket/requests/university_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class UniversityManagementScreen extends StatefulWidget {
  const UniversityManagementScreen({super.key});

  @override
  State<UniversityManagementScreen> createState() =>
      _UniversityManagementScreenState();
}

class _UniversityManagementScreenState
    extends State<UniversityManagementScreen> {
  final _universityRequest = UniversityRequest();
  late Future<List<University>> _universityFuture;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _universityFuture = _fetchUniversities();
  }

  Future<List<University>> _fetchUniversities() async {
    final response = await _universityRequest.getUniversities();
    if (response.statusCode == 200) {
      setState(() {
        _isFirstLoad = false;
      });
      return (response.data as List)
          .map((e) => University.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      context.showAnimatedToast(response.data['message']);
      setState(() {
        _isFirstLoad = false;
      });
      return [];
    }
  }

  Future<void> _refreshUniversities() async {
    setState(() {
      _universityFuture = _fetchUniversities();
    });
  }

  void onAddUniversity() {
    final nameController = TextEditingController();

    void handleSave() async {
      final name = nameController.text;
      if (name.isEmpty) return;
      final response = await _universityRequest.createUniversity(name);
      if (response.statusCode == 201) {
        setState(() {
          _universityFuture = _fetchUniversities();
        });
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
              'Add New University',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).pOnly(bottom: 20),
            TextField(
              controller: nameController,
              focusNode: FocusNode()..requestFocus(),
              decoration: const InputDecoration(labelText: 'University Name'),
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

  void onDeleteUniversity(University university) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${university.name}?'),
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
      final response =
          await _universityRequest.deleteUniversity(university.id!);
      if (response.statusCode == 200) {
        setState(() {
          _universityFuture = _fetchUniversities();
        });
      }
      if (mounted) {
        context.showAnimatedToast(response.data['message']);
      }
    }
  }

  void onEditUniversity(University university) async {
    if (university.id == null) return;
    final nameController = TextEditingController(text: university.name);

    void handleSave() async {
      final name = nameController.text;
      if (name.isEmpty) return;
      Navigator.pop(context);
      final response =
          await _universityRequest.updateUniversity(university.id!, name);
      if (response.statusCode == 200) {
        setState(() {
          _universityFuture = _fetchUniversities();
        });
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
                decoration: const InputDecoration(labelText: 'University Name'),
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
        });
  }

  void onTapUniversity(University university) async {
    if (university.id == null) return;
    context.push(Routes.facultyManagement, extra: university);
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'University Management',
      floatingActionButton: FloatingActionButton(
        onPressed: onAddUniversity,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<University>>(
        future: _universityFuture,
        builder: (context, snapshot) {
          if (_isFirstLoad &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final universities = snapshot.data ?? [];

          if (universities.isEmpty) {
            return const Center(child: Text('No universities found'));
          }

          return RefreshIndicator(
            onRefresh: _refreshUniversities,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  top: 16, left: 16, right: 16, bottom: 80),
              itemCount: universities.length,
              itemBuilder: (context, index) {
                final university = universities[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      university.name ?? 'No name',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Builder(builder: (context) {
                      var text = 'No faculties';
                      if (university.faculties == null) {
                        text = 'No faculties';
                      } else if (university.faculties!.isNotEmpty) {
                        text =
                            'Faculties: ${university.faculties!.length.toString()}';
                      }
                      return Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    }),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => onEditUniversity(university),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDeleteUniversity(university),
                        ),
                      ],
                    ),
                    onTap: () => onTapUniversity(university),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
