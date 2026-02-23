import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'review_report_page.dart';
import 'map_picker_page.dart';
// import '../models/report.dart';
import '../services/localization_service.dart';
// import '../services/report_service.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  double? _lat;
  double? _lng;

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  String? _selectedCategory;
  final List<String> _categories = [
    "Traffic_Accident".tr,
    "Fire_Incident".tr,
    "Medical_Emergency".tr,
    "Public_Disturbance".tr,
    "Other".tr
  ];

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxHeight: 640,
      maxWidth: 640,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      appBar: AppBar(
        title: Text(
          'create_report'.tr,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1e3a8a),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    'short_title'.tr,
                    _titleController,
                    hint: "e.g.,_Broken_Streetlight_on_Main_St.".tr,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'description'.tr,
                    _descriptionController,
                    hint:
                        "Describe_the_issue_in_detail,_the_more_information,_the_better."
                            .tr,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  Text('category'.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        hint: Text("Select_a_category".tr),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Upload Photo
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e3a8a).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF1e3a8a), width: 1),
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _image == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Color(0xFF1e3a8a),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('tap_upload'.tr,
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _buildTextField(
                    'location'.tr,
                    _locationController,
                    icon: Icons.location_on,
                    isReadOnly: true,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MapPickerPage()),
                      );

                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _locationController.text =
                              result['address']; // وضع العنوان في التكست فيلد
                          _lat = result['lat'];
                          _lng = result['lng'];
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 30),

                  CustomButton(
                    text: 'submit_report'.tr,
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          _selectedCategory != null) {
                        submitReport();
                      } else if (_selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Please_select_a_category".tr)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> submitReport() async {
  //   if (_image == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please_attach_an_image".tr)),
  //     );
  //     return;
  //   }

  //   try {
  //     // Show loading indicator
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => const Center(child: CircularProgressIndicator()),
  //     );

  //     // Add report to service
  //     final newReport = Report(
  //       id: '',
  //       title: _titleController.text,
  //       description: _descriptionController.text,
  //       incidentType: _selectedCategory!,
  //       location: _locationController.text,
  //       date: DateTime.now(),
  //       status: ReportStatus.pending,
  //       icon: _getCategoryIcon(_selectedCategory!),
  //       iconColor: _getCategoryColor(_selectedCategory!),
  //     );

  //     final report = await ReportService().addReport(
  //       newReport,
  //       _image!,
  //       lat: _lat,
  //       lng: _lng,
  //     );

  //     if (!mounted) return;
  //     // Hide loading
  //     Navigator.pop(context);

  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ReviewReportPage(
  //           reportData: report,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     // Hide loading if error
  //     Navigator.pop(context);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.toString())),
  //     );
  //   }
  // }

  

  void submitReport() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please_attach_an_image".tr)),
      );
      return;
    }

    if (_locationController.text.contains("Loading") || _lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please_wait_for_location_to_load".tr)),
      );
      return;
    }

    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please_select_location_on_map".tr)),
      );
      return;
    }

    // هنا بنجهز الداتا في Map عشان نبعتها لصفحة المراجعة
    final reportData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory!,
      'location': _locationController.text, // اسم المكان (العنوان)
      'lat': _lat,
      'lng': _lng,
      'image': _image, // ملف الصورة الفعلي File
    };

    // بننقل المستخدم لصفحة المراجعة ومعاه الداتا
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewReportPage(
          reportData: reportData,
        ),
      ),
    );
  }


  // IconData _getCategoryIcon(String category) {
  //   switch (category) {
  //     case "Traffic Accident":
  //       return Icons.car_crash;
  //     case "Fire Incident":
  //       return Icons.local_fire_department;
  //     case "Medical Emergency":
  //       return Icons.medical_services;
  //     case "Public Disturbance":
  //       return Icons.groups;
  //     default:
  //       return Icons.report_problem;
  //   }
  // }

  // Color _getCategoryColor(String category) {
  //   switch (category) {
  //     case "Traffic Accident":
  //       return Colors.orange;
  //     case "Fire Incident":
  //       return Colors.red;
  //     case "Medical Emergency":
  //       return Colors.blue;
  //     case "Public Disturbance":
  //       return Colors.purple;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? hint,
      int maxLines = 1,
      IconData? icon,
      bool isReadOnly = false,
      VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          readOnly: isReadOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF1e3a8a))
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This_field_is_required'.tr;
            }
            return null;
          },
        ),
      ],
    );
  }
}
