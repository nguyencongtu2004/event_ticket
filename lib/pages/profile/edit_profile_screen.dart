import 'dart:io';

import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/university.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/pages/profile/widget/user_info.dart';
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
  late User _editedUser;
  File? _selectedImage;
  final _universityRequest = UniversityRequest();
  List<University> _availableUniversities = [];

  String? _selectedUniversity;
  String? _selectedFaculty;
  String? _selectedMajor;
  List<Faculty> _filteredFaculties = [];
  List<Major> _filteredMajors = [];

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;
    if (user != null) {
      _editedUser = user;
      _selectedUniversity = user.university;
      _selectedFaculty = user.faculty;
      _selectedMajor = user.major;
    }

    _universityRequest.getUniversities().then((response) {
      print(response.data);
      setState(() {
        _availableUniversities = List<University>.from(
            response.data.map((e) => University.fromJson(e)));
        _updateFilteredFaculties();
        _updateFilteredMajors();
      });
    });
  }

  void _updateFilteredFaculties() {
    final university = _availableUniversities.firstWhere(
      (u) => u.name == _selectedUniversity,
      orElse: () => University(id: '', name: '', faculties: []),
    );

    setState(() {
      _filteredFaculties = university.faculties;

      // Giữ lại khoa đã chọn nếu tồn tại trong danh sách khoa mới
      if (_selectedFaculty != null &&
          _filteredFaculties.any((f) => f.name == _selectedFaculty)) {
        _selectedFaculty = _selectedFaculty;
      } else {
        _selectedFaculty = null; // Reset nếu không khớp
      }

      _updateFilteredMajors(); // Cập nhật ngành theo khoa mới
    });
  }

  void _updateFilteredMajors() {
    final faculty = _filteredFaculties.firstWhere(
      (f) => f.name == _selectedFaculty,
      orElse: () => Faculty(id: '', name: '', majors: []),
    );

    setState(() {
      _filteredMajors = faculty.majors;

      // Giữ lại ngành đã chọn nếu tồn tại trong danh sách ngành mới
      if (_selectedMajor != null &&
          _filteredMajors.any((m) => m.name == _selectedMajor)) {
        _selectedMajor = _selectedMajor;
      } else {
        _selectedMajor = null; // Reset nếu không khớp
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
      _editedUser = _editedUser.copyWith(
        university: _availableUniversities
            .firstWhere((u) => u.name == _selectedUniversity)
            .id,
        faculty:
            _filteredFaculties.firstWhere((f) => f.name == _selectedFaculty).id,
        major: _filteredMajors.firstWhere((m) => m.name == _selectedMajor).id,
      );
      // Gửi thông tin cập nhật đến UserNotifier
      final isSuccess = await ref
          .read(userProvider.notifier)
          .updateUser(_editedUser, _selectedImage);
      // TODO: Upload _selectedImage lên server nếu cần

      if (isSuccess) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thất bại')),
        );
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : NetworkImage(user.avatar ??
                                'https://via.placeholder.com/150'),
                        child: _selectedImage == null
                            ? const Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                    ).centered(),
                    const SizedBox(height: 24),
                    TextFormField(
                      initialValue: _editedUser.name,
                      decoration: const InputDecoration(labelText: 'Tên'),
                      onSaved: (value) {
                        if (value != null) {
                          _editedUser = _editedUser.copyWith(name: value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _editedUser.phone,
                      decoration:
                          const InputDecoration(labelText: 'Số điện thoại'),
                      onSaved: (value) {
                        _editedUser = _editedUser.copyWith(phone: value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedUniversity,
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'Trường đại học'),
                      items: _availableUniversities
                          .map((university) => DropdownMenuItem(
                                value: university.name,
                                child: Text(
                                  university.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUniversity = value;
                          _editedUser = _editedUser.copyWith(university: value);
                          _updateFilteredFaculties();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedFaculty,
                      decoration: const InputDecoration(labelText: 'Khoa'),
                      items: _filteredFaculties
                          .map((faculty) => DropdownMenuItem(
                                value: faculty.name,
                                child: Text(
                                  faculty.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFaculty = value;
                          _editedUser = _editedUser.copyWith(faculty: value);
                          _updateFilteredMajors();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedMajor,
                      decoration: const InputDecoration(labelText: 'Ngành học'),
                      items: _filteredMajors
                          .map((major) => DropdownMenuItem(
                                value: major.name,
                                child: Text(
                                  major.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMajor = value;
                          _editedUser = _editedUser.copyWith(major: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Genders>(
                      value: _editedUser.gender,
                      decoration: const InputDecoration(labelText: 'Giới tính'),
                      items: Genders.values
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender.name.capitalized),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _editedUser = _editedUser.copyWith(gender: value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _editedUser.birthday != null
                            ? _editedUser.birthday!
                                .toLocal()
                                .toIso8601String()
                                .split('T')
                                .first
                            : '',
                      ),
                      decoration: const InputDecoration(labelText: 'Ngày sinh'),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _editedUser.birthday ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _editedUser =
                                _editedUser.copyWith(birthday: picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Lưu'),
                    ),
                  ],
                ),
              ).pOnly(top: 24, left: 16, right: 16).scrollVertical()
            : const Center(child: Text('Không có thông tin người dùng.')),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Đã xảy ra lỗi: $error'),
        ),
      ),
    );
  }
}
