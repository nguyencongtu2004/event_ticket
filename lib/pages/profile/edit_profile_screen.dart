import 'dart:io';

import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/university.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/pages/profile/widget/pick_avatar.dart';
import 'package:event_ticket/providers/user_provider.dart';
import 'package:event_ticket/requests/university_request.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late User editedUser;
  File? _selectedImage;
  var _isLoading = false;
  final _universityRequest = UniversityRequest();
  List<University> availableUniversities = [];

  String? selectedUniversity;
  String? selectedFaculty;
  String? selectedMajor;
  List<Faculty> filteredFaculties = [];
  List<Major> filteredMajors = [];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;
    if (user != null) {
      editedUser = user;
      selectedUniversity = user.university;
      selectedFaculty = user.faculty;
      selectedMajor = user.major;
    }

    _universityRequest.getUniversitiesWithAll().then((response) {
      setState(() {
        availableUniversities = List<University>.from(
            response.data.map((e) => University.fromJson(e)));
        _updateFilteredFaculties();
        _updateFilteredMajors();
      });
    });
  }

  void _updateFilteredFaculties() {
    final university = availableUniversities.firstWhere(
      (u) => u.name == selectedUniversity,
      orElse: () => University.fromNull(),
    );

    setState(() {
      filteredFaculties = university.faculties ?? [];

      // Giữ lại khoa đã chọn nếu tồn tại trong danh sách khoa mới
      if (selectedFaculty != null &&
          filteredFaculties.any((f) => f.name == selectedFaculty)) {
        selectedFaculty = selectedFaculty;
      } else {
        selectedFaculty =
            filteredFaculties.first.name; // Reset cái đầu tiên nếu không khớp
      }

      _updateFilteredMajors(); // Cập nhật ngành theo khoa mới
    });
  }

  void _updateFilteredMajors() {
    final faculty = filteredFaculties.firstWhere(
      (f) => f.name == selectedFaculty,
      orElse: () => Faculty.fromNull(),
    );

    setState(() {
      filteredMajors = faculty.majors ?? [];

      // Giữ lại ngành đã chọn nếu tồn tại trong danh sách ngành mới
      if (selectedMajor != null &&
          filteredMajors.any((m) => m.name == selectedMajor)) {
        selectedMajor = selectedMajor;
      } else {
        selectedMajor =
            filteredMajors.first.name; // Reset cái đầu tiên nếu không khớp
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      editedUser = editedUser.copyWith(
        university: availableUniversities
            .firstWhere((u) => u.name == selectedUniversity,
                orElse: () => University.fromNull())
            .id,
        faculty: filteredFaculties
            .firstWhere((f) => f.name == selectedFaculty,
                orElse: () => Faculty.fromNull())
            .id,
        major: filteredMajors
            .firstWhere((m) => m.name == selectedMajor,
                orElse: () => Major.fromNull())
            .id,
      );
      // Gửi thông tin cập nhật đến UserNotifier
      setState(() => _isLoading = true);
      final isSuccess = await ref
          .read(userProvider.notifier)
          .updateUser(editedUser, _selectedImage);
      setState(() => _isLoading = false);

      if (isSuccess) {
        Navigator.of(context).pop();
        context.showAnimatedToast('Update profile successfully!');
      } else {
        context.showAnimatedToast('Failed to update profile.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider);
    return TicketScaffold(
      title: 'Edit Profile',
      body: userAsyncValue.when(
        data: (user) => user != null
            ? Form(
                key: _formKey,
                child: Column(
                  children: [
                    PickAvatar(
                      user,
                      radius: 70,
                      selectedImage: _selectedImage,
                      onTap: _pickImage,
                      showCamera: true,
                    ).centered(),
                    const SizedBox(height: 24),
                    TextFormField(
                      initialValue: editedUser.name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      onSaved: (value) {
                        if (value != null) {
                          editedUser = editedUser.copyWith(name: value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: editedUser.phone,
                      decoration:
                          const InputDecoration(labelText: 'Phone number'),
                      onSaved: (value) {
                        editedUser = editedUser.copyWith(phone: value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedUniversity,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'University'),
                      items: availableUniversities
                          .map((university) => DropdownMenuItem(
                                value: university.name,
                                child: Text(
                                  university.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUniversity = value;
                          editedUser = editedUser.copyWith(university: value);
                          _updateFilteredFaculties();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedFaculty,
                      decoration: const InputDecoration(labelText: 'Faculty'),
                      items: filteredFaculties
                          .map((faculty) => DropdownMenuItem(
                                value: faculty.name,
                                child: Text(
                                  faculty.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedFaculty = value;
                          editedUser = editedUser.copyWith(faculty: value);
                          _updateFilteredMajors();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedMajor,
                      decoration: const InputDecoration(labelText: 'Major'),
                      items: filteredMajors
                          .map((major) => DropdownMenuItem(
                                value: major.name,
                                child: Text(
                                  major.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedMajor = value;
                          editedUser = editedUser.copyWith(major: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Genders>(
                      value: editedUser.gender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: Genders.values
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender.name.capitalized),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          editedUser = editedUser.copyWith(gender: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: editedUser.birthday != null
                            ? editedUser.birthday!
                                .toLocal()
                                .toIso8601String()
                                .split('T')
                                .first
                            : '',
                      ),
                      decoration:
                          const InputDecoration(labelText: 'Date of birth'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: editedUser.birthday ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            editedUser = editedUser.copyWith(birthday: picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProfile,
                      icon: _isLoading
                          ? const CircularProgressIndicator().w(20).h(20)
                          : const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ],
                ),
              ).px(16).py(24).scrollVertical()
            : const Center(child: Text('User not found')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
