import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/university.dart';
import 'package:event_ticket/requests/university_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class FacultyManagementScreen extends StatefulWidget {
  const FacultyManagementScreen({super.key, required this.university});

  final University university;

  @override
  State<FacultyManagementScreen> createState() =>
      _FacultyManagementScreenState();
}

class _FacultyManagementScreenState extends State<FacultyManagementScreen> {
  final _universityRequest = UniversityRequest();
  late Future<List<Faculty>> _facultyFuture;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _facultyFuture = _fetchFaculties();
  }

  Future<List<Faculty>> _fetchFaculties() async {
    final response = await _universityRequest
        .getFacultiesByUniversityId(widget.university.id!);
    setState(() => _isLoading = false);
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => Faculty.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      context.showAnimatedToast(response.data['message']);
      return [];
    }
  }

  Future<void> _refreshFaculties() async {
    setState(() => _facultyFuture = _fetchFaculties());
  }

  void onAddFaculty() {
    final nameController = TextEditingController();

    void handleSave() async {
      final name = nameController.text;
      if (name.isEmpty) return;
      final response =
          await _universityRequest.createFaculty(widget.university.id!, name);
      if (response.statusCode == 201) {
        setState(() {
          _facultyFuture = _fetchFaculties();
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
              'Add New Faculty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ).pOnly(bottom: 20),
            TextField(
              controller: nameController,
              focusNode: FocusNode()..requestFocus(),
              decoration: const InputDecoration(labelText: 'Faculty Name'),
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

  void onDeleteFaculty(Faculty faculty) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${faculty.name}?'),
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
      final response = await _universityRequest.deleteFaculty(faculty.id!);
      if (response.statusCode == 200) {
        setState(() {
          _facultyFuture = _fetchFaculties();
        });
      }
      if (mounted) {
        context.showAnimatedToast(response.data['message']);
      }
    }
  }

  void onEditFaculty(Faculty faculty) async {
    if (faculty.id == null) return;
    final nameController = TextEditingController(text: faculty.name);

    void handleSave() async {
      final name = nameController.text;
      if (name.isEmpty) return;
      Navigator.pop(context);
      final response =
          await _universityRequest.updateFaculty(faculty.id!, name);
      if (response.statusCode == 200) {
        setState(() {
          _facultyFuture = _fetchFaculties();
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
                decoration: const InputDecoration(labelText: 'Faculty Name'),
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

  void onTapFaculty(Faculty faculty) async {
    if (faculty.id == null) return;
    context.push(Routes.majorManagement, extra: faculty);
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Faculty Management',
      floatingActionButton: FloatingActionButton(
        onPressed: onAddFaculty,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Faculty>>(
        future: _facultyFuture,
        builder: (context, snapshot) {
          final isLoading = _isLoading;
          final faculties = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refreshFaculties,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                // Phần thông tin trường đại học
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'University: ${widget.university.name}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ).expand(),
                  ],
                ).p(16),
                // Tiêu đề danh sách khoa
                Text(
                  'Faculties:',
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
                else if (faculties.isEmpty)
                  const Center(child: Text('No faculties found'))
                else
                  ...faculties.map(
                    (faculty) => Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        title: Text(
                          faculty.name ?? 'No name',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        // subtitle: Builder(builder: (context) {
                        //   var text = 'No majors';
                        //   if (faculty.majors == null) {
                        //     text = 'No majors';
                        //   } else if (faculty.majors!.isNotEmpty) {
                        //     text =
                        //         'Majors: ${faculty.majors!.length.toString()}';
                        //   }
                        //   return Text(
                        //     text,
                        //     style: Theme.of(context).textTheme.bodyMedium,
                        //   );
                        // }),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => onEditFaculty(faculty),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => onDeleteFaculty(faculty),
                            ),
                          ],
                        ),
                        onTap: () => onTapFaculty(faculty),
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
