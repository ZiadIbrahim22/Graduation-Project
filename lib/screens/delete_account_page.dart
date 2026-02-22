// import 'package:flutter/material.dart';
// import '../services/localization_service.dart';
// import '../services/user_service.dart';
// import 'login_page.dart';

// class DeleteAccountPage extends StatefulWidget {
//   const DeleteAccountPage({super.key});

//   @override
//   State<DeleteAccountPage> createState() => _DeleteAccountPageState();
// }

// class _DeleteAccountPageState extends State<DeleteAccountPage> with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _passwordController = TextEditingController();
//   final _reasonController = TextEditingController();
//   bool _isConfirmed = false;
//   bool _isLoading = false;
//   bool _isObscured = true;




//   late AnimationController _controller;
//   late Animation<double> _fade;
//   late Animation<Offset> _slide;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 600));
//     _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//     _slide = Tween(begin: const Offset(0, .15), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _reasonController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleDelete() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_isConfirmed) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('please_confirm_deletion'.tr)
//         ), // You might need to add this key
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     final success = await UserService().deleteUser(
//       password: _passwordController.text,
//       reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
//     );

//     setState(() => _isLoading = false);

//     if (mounted) {
//       if (success) {
//         UserService().logout();
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const LoginPage()),
//           (route) => false,
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('failed_to_delete_account'.tr), // You might need to add this key or use a generic error
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'delete_account'.tr,
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFFdc2626), // Red for destructive action
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: FadeTransition(
//         opacity: _fade,
//         child: SlideTransition(
//           position: _slide,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Warning Section
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFfee2e2), // Light red bg
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFFef4444)),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.warning_amber_rounded,
//                             color: Color(0xFFdc2626), size: 30),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'delete_account_warning'
//                                 .tr, // Key: "This action is irreversible. All your data will be permanently lost."
//                             style: const TextStyle(
//                               color: Color(0xFFb91c1c),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 30),

//                   // Password Field
//                   Text(
//                     'confirm_password'.tr,
//                     style:
//                         const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: _isObscured,
//                     decoration: InputDecoration(
//                       hintText: 'enter_your_password'.tr,
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                             _isObscured ? Icons.visibility_off : Icons.visibility),
//                         onPressed: () => setState(() => _isObscured = !_isObscured),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'password_required'.tr;
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 20),

//                   // Reason Field (Optional)
//                   Text(
//                     'reason_for_leaving'.tr, // "Reason for leaving (Optional)"
//                     style:
//                         const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   TextFormField(
//                     controller: _reasonController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: 'tell_us_why'
//                           .tr, // "Tell us why you are deleting your account..."
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Confirmation Checkbox
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: _isConfirmed,
//                         activeColor: const Color(0xFFdc2626),
//                         onChanged: (val) =>
//                             setState(() => _isConfirmed = val ?? false),
//                       ),
//                       Expanded(
//                         child: Text(
//                           'delete_confirmation_text'
//                               .tr, // "I understand that this action is permanent and cannot be undone."
//                           style: const TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 40),

//                   // Delete Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed:
//                           (_isConfirmed && !_isLoading) ? _handleDelete : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFdc2626),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10)),
//                         disabledBackgroundColor: Colors.grey[400],
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               height: 20,
//                               width: 20,
//                               child: CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2),
//                             )
//                           : Text(
//                               'delete_account'.tr,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
