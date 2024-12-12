import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/category.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/providers/category_provider.dart';
import 'package:event_ticket/providers/event_management_provider.dart';
import 'package:event_ticket/requests/user_request.dart';
import 'package:event_ticket/ulties/format.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _userRequest = UserRequest();

  final _formKey = GlobalKey<FormState>();
  int currentIndex = 0; // Biến trạng thái cho tab hiện tại
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _maxAttendeesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _categoriesFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _dateFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _maxAttendeesFocus = FocusNode();

  List<File> _selectedImages = [];
  DateTime? _selectedDate = DateTime.now().add(const Duration(days: 7));
  Category? _selectedCategory;
  List<Category> _categories = [];
  List<User> searchResult = [];
  List<User> selectedUsers = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _maxAttendeesController.dispose();
    _searchController.dispose();
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _categoriesFocus.dispose();
    _locationFocus.dispose();
    _dateFocus.dispose();
    _priceFocus.dispose();
    _maxAttendeesFocus.dispose();
    super.dispose();
  }

  void _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    setState(() {
      _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
    });
  }

  void _pickDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _searchUser() async {
    final searchInput = _searchController.text.trim();
    if (searchInput.isEmpty) return;
    final result = await _userRequest.searchUser(
      query: searchInput,
      role: Roles.eventCreator,
    );
    setState(() {
      searchResult =
          result.where((user) => !selectedUsers.contains(user)).toList();
    });
  }

  void _addUser(User user) {
    setState(() {
      selectedUsers.add(user);
      searchResult.remove(user);
    });
  }

  void _removeUser(User user) {
    setState(() {
      selectedUsers.remove(user);
    });
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> eventData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'price': _priceController.text,
        'maxAttendees': _maxAttendeesController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'categoryId': _selectedCategory!.id,
        'colaborators':
            json.encode(selectedUsers.map((user) => user.id).toList()),
      };

      if (_selectedImages.isNotEmpty) {
        eventData['images'] = _selectedImages
            .map((image) => MultipartFile.fromFileSync(image.path))
            .toList();
      }

      FormData formData = FormData.fromMap(eventData);

      // Call API to create event
      final created = await ref
          .read(eventManagementProvider.notifier)
          .createEvent(formData);
      if (mounted) {
        if (created) {
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create event'),
            ),
          );
        }
      }
    } else {
      VxToast.show(context, msg: 'Please fill in all required fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(categoryProvider).whenData((categories) {
      _categories = categories;
      if (_selectedCategory == null && categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
    });
    return TicketScaffold(
      title: 'Create Event',
      appBarActions: [
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () async {
            await _createEvent();
          },
        ),
      ],
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              tabs: const [
                Tab(text: 'General Information'),
                Tab(text: 'Colaborators'),
              ],
            ),
            Form(
              key: _formKey,
              child: IndexedStack(
                index: currentIndex,
                children: [
                  _buildGeneralInformationTab(),
                  _buildColaboratorsTab(),
                ],
              ),
            ).expand(),
          ],
        ),
      ),
    ).hero('addEvent');
  }

  Widget _buildGeneralInformationTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Images
          GestureDetector(
            onTap: _pickImages,
            child: _selectedImages.isEmpty
                ? Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(child: Text('Tap to select images')),
                  )
                : SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _selectedImages
                          .map((image) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.file(
                                  image,
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          // Name
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            decoration: const InputDecoration(
              labelText: 'Event Name',
              prefixIcon: Icon(Icons.event),
            ),
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_descriptionFocus),
            textInputAction: TextInputAction.next,
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a name' : null,
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            focusNode: _descriptionFocus,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_locationFocus),
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter a description'
                : null,
          ),
          const SizedBox(height: 16),

          // Location
          TextFormField(
            controller: _locationController,
            focusNode: _locationFocus,
            decoration: const InputDecoration(
              labelText: 'Location',
              prefixIcon: Icon(Icons.location_on),
            ),
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_priceFocus),
            textInputAction: TextInputAction.next,
            validator: (value) => value == null || value.isEmpty
                ? 'Please enter a location'
                : null,
          ),
          const SizedBox(height: 16),

          // Price
          TextFormField(
            controller: _priceController,
            focusNode: _priceFocus,
            decoration: const InputDecoration(
              labelText: 'Price',
              prefixIcon: Icon(Icons.attach_money),
            ),
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_maxAttendeesFocus),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Max Attendees
          TextFormField(
            controller: _maxAttendeesController,
            focusNode: _maxAttendeesFocus,
            decoration: const InputDecoration(
              labelText: 'Max Attendees',
              prefixIcon: Icon(Icons.people),
            ),
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_dateFocus),
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Date
          GestureDetector(
            onTap: () => _pickDate(context),
            child: ListTile(
              focusNode: _dateFocus,
              contentPadding: const EdgeInsets.only(left: 12),
              title: const Text('Select Date'),
              subtitle: Text(_selectedDate != null
                  ? Format.formatDDMMYYYY(_selectedDate!)
                  : 'No date selected'),
              leading: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 16),

          // Category
          DropdownButtonFormField<Category>(
            focusNode: _categoriesFocus,
            value: _selectedCategory,
            items: _categories
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Category',
              prefixIcon: Icon(Icons.category),
            ),
            validator: (value) =>
                value == null ? 'Please select a category' : null,
          ),
          const SizedBox(height: 16),
        ],
      ).p(16),
    );
  }

  Widget _buildColaboratorsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search User',
                  prefixIcon: Icon(Icons.search),
                ),
                onFieldSubmitted: (_) => _searchUser(),
                textInputAction: TextInputAction.search,
              ),
            ),
            ElevatedButton(
              onPressed: _searchUser,
              child: const Text('Search'),
            ),
          ],
        ).p16(),

        //  Selected users
        if (selectedUsers.isNotEmpty) ...[
          Text('Selected Users:',
                  style: Theme.of(context).textTheme.titleMedium)
              .px(16),
          Row(
            children: selectedUsers
                .map((user) => Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(user.avatar ??
                                  'https://via.placeholder.com/50'),
                              radius: 25,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.name ?? 'No name',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ).p(8),
                        const Positioned(
                          top: 0,
                          right: 0,
                          child: Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ).onInkTap(() => _removeUser(user)))
                .toList(),
          ).scrollHorizontal()
        ],

        // Search result
        if (searchResult.isNotEmpty) ...[
          Text('Search Result:', style: Theme.of(context).textTheme.titleMedium)
              .px(16),
          ListView(
            children: searchResult
                .map((user) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            user.avatar ?? 'https://via.placeholder.com/50'),
                        radius: 25,
                      ),
                      title: Text(user.name ?? 'No name'),
                      subtitle: Text(user.studentId ?? 'No student ID'),
                      trailing: ElevatedButton(
                        onPressed: () => _addUser(user),
                        child: const Text('Add'),
                      ),
                    ))
                .toList(),
          ).expand(),
        ],
      ],
    );
  }
}
