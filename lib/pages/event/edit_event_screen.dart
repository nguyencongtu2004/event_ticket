import 'dart:io';
import 'package:dio/dio.dart';
import 'package:event_ticket/models/category.dart';
import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/providers/category_provider.dart';
import 'package:event_ticket/providers/event_management_provider.dart';
import 'package:event_ticket/requests/event_request.dart';
import 'package:event_ticket/ulties/format.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:velocity_x/velocity_x.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  const EditEventScreen({super.key, required this.event});

  final Event event;

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _maxAttendeesController;

  List<File> _selectedImages = [];
  DateTime? _selectedDate;
  Category? _selectedCategory;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing event data
    _nameController = TextEditingController(text: widget.event.name);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _priceController =
        TextEditingController(text: widget.event.price.toString());
    _maxAttendeesController =
        TextEditingController(text: widget.event.maxAttendees.toString());
    _selectedDate = widget.event.date;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  void _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((file) => File(file.path)).toList();
      });
    }
  }

  void _pickDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> eventData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'price': _priceController.text,
        'maxAttendees': _maxAttendeesController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'categoryId': _selectedCategory!.id,
      };

      if (_selectedImages.isNotEmpty) {
        eventData['images'] = _selectedImages
            .map((image) => MultipartFile.fromFileSync(image.path))
            .toList();
      }

      FormData formData = FormData.fromMap(eventData);

      print(formData.fields);
      // Call API to update event
      final updated = await ref
          .read(eventManagementProvider.notifier)
          .updateEvent(widget.event.id, formData);
      if (mounted) {
        if (updated) {
          Navigator.of(context).pop(true);
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update event'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(categoryProvider).whenData((categories) {
      _categories = categories;
      _selectedCategory = widget.event.category.first;
    });
    return TicketScaffold(
      title: 'Edit Event',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Images
                  GestureDetector(
                    onTap: _pickImages,
                    child: _selectedImages.isEmpty
                        ? Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(
                                child: Text('Tap to select images')),
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
                    decoration: const InputDecoration(
                      labelText: 'Event Name',
                      prefixIcon: Icon(Icons.event),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a name'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a location'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Max Attendees
                  TextFormField(
                    controller: _maxAttendeesController,
                    decoration: const InputDecoration(
                      labelText: 'Max Attendees',
                      prefixIcon: Icon(Icons.people),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Date
                  GestureDetector(
                    onTap: () => _pickDate(context),
                    child: ListTile(
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
                    value: _selectedCategory,
                    items: _categories
                        .map((category) => DropdownMenuItem<Category>(
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
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateEvent,
              child: const Text('Update Event'),
            ),
          ],
        ).p(16),
      ),
    );
  }
}
