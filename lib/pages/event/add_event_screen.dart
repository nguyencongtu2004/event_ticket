import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/category.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/providers/category_provider.dart';
import 'package:event_ticket/providers/event_management_provider.dart';
import 'package:event_ticket/requests/user_request.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:velocity_x/velocity_x.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _userRequest = UserRequest();
  var _isLoading = false;

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
  final FocusNode _timeFocus = FocusNode();

  List<Map<String, dynamic>> _selectedImages = [];
  DateTime? _selectedDate = DateTime.now().add(const Duration(days: 7));
  Category? _selectedCategory;
  List<Category> _categories = [];
  List<User> searchResult = [];
  List<User> selectedUsers = [];
  Timer? _debounce;

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
    _timeFocus.dispose();
    super.dispose();
  }

  void _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    // Đọc dữ liệu hình ảnh dưới dạng Uint8List
    final imageData = await Future.wait(
      pickedFiles.map((file) async {
        return {
          'path': file.path,
          'bytes': await file.readAsBytes(), // Dữ liệu Uint8List
        };
      }),
    );

    setState(() => _selectedImages = imageData);
  }

  void _addImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    final newImages = await Future.wait(
      pickedFiles.map((file) async {
        final bytes = await file.readAsBytes(); // Đọc dữ liệu Uint8List
        return {
          'path': file.path,
          'bytes': bytes
        }; // Trả về bản đồ chứa dữ liệu
      }),
    );

    setState(() {
      for (var newImage in newImages) {
        // Kiểm tra trùng lặp dựa trên bytes
        bool isDuplicate = _selectedImages.any((existingImage) {
          return existingImage['bytes'] == newImage['bytes'];
        });
        if (!isDuplicate) {
          _selectedImages.add(newImage);
        }
      }
    });
  }

  void _pickDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  void _pickTime(BuildContext context) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        // Convert selectedTime to DateTime
        _selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          selectedTime.hour,
          selectedTime.minute,
        );
      });
    }
  }

  void _onSearchChanged() {
    // Debounce logic
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUser();
    });
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
        'date': _selectedDate!.toUtc().toIso8601String(),
        'categoryId': _selectedCategory!.id,
        'collaborators':
            json.encode(selectedUsers.map((user) => user.id).toList()),
      };

      if (_selectedImages.isNotEmpty) {
        eventData['images'] = _selectedImages.map((imageData) {
          return MultipartFile.fromBytes(
            imageData['bytes'], // Sử dụng dữ liệu Uint8List
            filename: imageData['path'].split('/').last, // Lấy tên file
          );
        }).toList();
      }

      FormData formData = FormData.fromMap(eventData);

      // Gọi API để tạo sự kiện
      setState(() => _isLoading = true);
      final created = await ref
          .read(eventManagementProvider.notifier)
          .createEvent(formData);
      setState(() => _isLoading = false);

      if (mounted) {
        if (created) {
          Navigator.of(context).pop(true);
        } else {
          context.showAnimatedToast('Failed to create event');
        }
      }
    } else {
      context.showAnimatedToast('Please fill in all required fields');
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
      title: 'Create Event ${_nameController.text}',
      appBarActions: [
        if (_isLoading)
          const CircularProgressIndicator().w(20).h(20).p(12)
        else
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async => await _createEvent(),
          ),
      ],
      body: LayoutBuilder(builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;
        if (isLargeScreen) {
          return Form(
            key: _formKey,
            child: Row(
              children: [
                Column(
                  children: [
                    Text('General Information',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            )).px(16),
                    _buildGeneralInformationTab().expand(),
                  ],
                ).expand(flex: 2),
                const VerticalDivider(width: 1),
                Column(
                  children: [
                    Text('Collaborators',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            )).px(16),
                    _buildCollaboratorsTab().expand(),
                  ],
                ).expand(flex: 1),
              ],
            ).w(1200).px(24).centered(),
          );
        }
        return DefaultTabController(
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
                  Tab(text: 'Collaborators'),
                ],
              ),
              Form(
                key: _formKey,
                child: IndexedStack(
                  index: currentIndex,
                  children: [
                    _buildGeneralInformationTab(),
                    _buildCollaboratorsTab(),
                  ],
                ),
              ).expand(),
            ],
          ),
        );
      }),
    ).hero('addEvent');
  }

  Widget _buildGeneralInformationTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Images
          ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._selectedImages.map((imageData) => Stack(
                    children: [
                      Image.memory(
                        imageData['bytes'] as Uint8List,
                        fit: BoxFit.cover,
                      ).p(4).w(150).h(150),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () =>
                              setState(() => _selectedImages.remove(imageData)),
                          tooltip: 'Remove image',
                        ),
                      ),
                    ],
                  )),
              if (_selectedImages.isEmpty)
                Container(
                  color: Colors.grey[300],
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 32),
                      Text(
                        'Tap to select images',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).p(4).h(150).w(450).onTap(_pickImages)
              else
                Container(
                  color: Colors.grey[300],
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 32),
                      Text(
                        'Tap to select more images',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).p(4).w(150).h(150).onTap(_addImage),
            ],
          ).h(150),

          // Name
          TextFormField(
            controller: _nameController,
            focusNode: _nameFocus,
            decoration: const InputDecoration(
              labelText: 'Event Name',
              prefixIcon: Icon(Icons.event),
            ),
            onChanged: (_) => setState(() {}),
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
            validator: (value) {
              const minPrice = 1000.0;
              const maxPrice = 500000000.0;
              if (value == null || value.isEmpty) return null;
              final price = double.tryParse(value);
              if (price == null) return 'Please enter a valid number';
              if (price != 0 && (price < minPrice || price > maxPrice)) {
                return 'Price must be between ${minPrice.toCurrency()} and ${maxPrice.toCurrency()}';
              }
              return null;
            },
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
                  ? _selectedDate!.toDDMMYYYY()
                  : 'No date selected'),
              leading: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 16),

          // Time
          GestureDetector(
            onTap: () => _pickTime(context),
            child: ListTile(
              focusNode: _timeFocus,
              contentPadding: const EdgeInsets.only(left: 12),
              title: const Text('Select Time'),
              subtitle: Text(_selectedDate != null
                  ? _selectedDate!.toHHMM()
                  : 'No time selected'),
              leading: const Icon(Icons.access_time),
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

  Widget _buildCollaboratorsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        SearchBar(
          controller: _searchController,
          onChanged: (_) => _onSearchChanged(),
          hintText: 'Search for a user...',
          leading: const Icon(Icons.search),
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
                            Avatar(user, radius: 25),
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
          ListView.builder(
            itemCount: searchResult.length,
            itemBuilder: (context, index) {
              final user = searchResult[index];
              return ListTile(
                leading: Avatar(user, radius: 25),
                title: Text(user.name ?? 'No name'),
                subtitle: Text(user.studentId ?? 'No student ID'),
                trailing: ElevatedButton(
                  onPressed: () => _addUser(user),
                  child: const Text('Add'),
                ),
              );
            },
          ).expand(),
        ] else
          const Text('No search result').centered().expand(),
      ],
    );
  }
}
