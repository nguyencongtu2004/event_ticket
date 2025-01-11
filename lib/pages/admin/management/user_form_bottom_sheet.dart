import 'package:dio/dio.dart';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/university.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/requests/university_request.dart';
import 'package:event_ticket/requests/user_request.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class UserFormBottomSheet extends StatefulWidget {
  final User? user;
  final Function onSuccess;
  final Function? onClose;

  const UserFormBottomSheet({
    super.key,
    this.user,
    required this.onSuccess,
    this.onClose,
  });

  @override
  State<UserFormBottomSheet> createState() => _UserFormBottomSheetState();
}

class _UserFormBottomSheetState extends State<UserFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _universityRequest = UniversityRequest();
  final _userRequest = UserRequest();

  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _studentIdController;

  List<University> availableUniversities = [];
  University? selectedUniversity;
  Faculty? selectedFaculty;
  Major? selectedMajor;
  List<Faculty> filteredFaculties = [];
  List<Major> filteredMajors = [];
  Genders selectedGender = Genders.male;
  Roles selectedRole = Roles.ticketBuyer;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name);
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.user?.phone);
    _studentIdController = TextEditingController(text: widget.user?.studentId);

    if (widget.user != null) {
      selectedUniversity = widget.user!.university;
      selectedFaculty = widget.user!.faculty;
      selectedMajor = widget.user!.major;
      selectedGender = widget.user!.gender ?? Genders.male;
      selectedRole = widget.user!.role ?? Roles.ticketBuyer;
    }

    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    final response = await _universityRequest.getUniversitiesWithAll();
    if (response.statusCode == 200) {
      setState(() {
        availableUniversities = List<University>.from(
            response.data.map((e) => University.fromJson(e)));
        _updateFilteredFaculties();
        _updateFilteredMajors();
      });
    }
  }

  void _updateFilteredFaculties() {
    final university = availableUniversities.firstWhere(
      (u) => u == selectedUniversity,
      orElse: () => University.fromNull(),
    );

    setState(() {
      filteredFaculties = university.faculties ?? [];

      if (selectedFaculty != null &&
          filteredFaculties.any((f) => f == selectedFaculty)) {
        selectedFaculty = selectedFaculty;
      } else {
        selectedFaculty = filteredFaculties.isNotEmpty
            ? filteredFaculties.first
            : Faculty.fromNull();
      }

      _updateFilteredMajors();
    });
  }

  void _updateFilteredMajors() {
    final faculty = filteredFaculties.firstWhere(
      (f) => f == selectedFaculty,
      orElse: () => Faculty.fromNull(),
    );

    setState(() {
      filteredMajors = faculty.majors ?? [];

      if (selectedMajor != null &&
          filteredMajors.any((m) => m == selectedMajor)) {
        selectedMajor = selectedMajor;
      } else {
        selectedMajor =
            filteredMajors.isNotEmpty ? filteredMajors.first : Major.fromNull();
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final userData = {
      'senderRole': 'admin',
      'userId': widget.user?.id,
      'name': _nameController.text,
      'password': _passwordController.text,
      'phone': _phoneController.text,
      'studentId': _studentIdController.text,
      'university': selectedUniversity?.id,
      'faculty': selectedFaculty?.id,
      'major': selectedMajor?.id,
      'gender': selectedGender.name,
      'role': selectedRole.value,
    };

    print(userData);

    final formData = FormData.fromMap(userData);

    final response = await _userRequest.updateUserInfo(formData);
    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      if (mounted) {
        if (response.data['message'] != null) {
          context.showAnimatedToast(response.data['message']);
        } else {
          context.showAnimatedToast('Updated successfully');
        }
        if (widget.onClose != null) {
          widget.onClose!();
        } else {
          Navigator.pop(context);
        }
        widget.onSuccess();
      }
    } else {
      if (mounted) {
        context.showAnimatedToast(response.data['message']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              widget.user == null ? 'Add New User' : 'Edit User',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Leave blank if not change'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _studentIdController,
              decoration: const InputDecoration(labelText: 'Student ID'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<University>(
              value: selectedUniversity,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'University'),
              items: availableUniversities
                  .map((university) => DropdownMenuItem(
                        value: university,
                        child: Text(
                          university.name ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedUniversity = value;
                  _updateFilteredFaculties();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Faculty>(
              value: selectedFaculty,
              decoration: const InputDecoration(labelText: 'Faculty'),
              items: filteredFaculties
                  .map((faculty) => DropdownMenuItem(
                        value: faculty,
                        child: Text(faculty.name ?? ''),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFaculty = value;
                  _updateFilteredMajors();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Major>(
              value: selectedMajor,
              decoration: const InputDecoration(labelText: 'Major'),
              items: filteredMajors
                  .map((major) => DropdownMenuItem(
                        value: major,
                        child: Text(major.name ?? ''),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMajor = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Roles>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: Roles.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Genders>(
              value: selectedGender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: Genders.values.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : _handleSubmit,
              icon: isLoading
                  ? const CircularProgressIndicator().w(20).h(20)
                  : const Icon(Icons.save),
              label: Text(widget.user == null ? 'Add User' : 'Update User'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
