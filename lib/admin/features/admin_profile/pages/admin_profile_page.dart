// ✅ Front-end only: Admin Profile with editable profile picture
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodel/admin_profile_vm.dart';
import '../../../layout/admin_scaffold.dart';
import '../data/admin_profile_model.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController dobCtrl;

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile = context.read<AdminProfileVM>().profile;
    firstNameCtrl = TextEditingController(text: profile.firstName);
    lastNameCtrl = TextEditingController(text: profile.lastName);
    emailCtrl = TextEditingController(text: profile.email);
    phoneCtrl = TextEditingController(text: profile.phoneNumber);
    addressCtrl = TextEditingController(text: profile.address);
    dobCtrl = TextEditingController(text: profile.dateOfBirth);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminProfileVM>();
    final profile = vm.profile;

    return AdminScaffold(
      title: "My Profile",
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF8EB4D9),
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12, width: 1),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${profile.firstName} ${profile.lastName}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(profile.role, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(profile.email, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 45),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Profile Information",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      if (!vm.isEditing)
                        InkWell(
                          onTap: vm.toggleEdit,
                          child: Row(
                            children: const [
                              Icon(Icons.edit, size: 16, color: Colors.black87),
                              SizedBox(width: 10),
                              Text("Edit", style: TextStyle(fontSize: 14, color: Colors.black87)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildFieldOrText("First Name", firstNameCtrl, profile.firstName, vm.isEditing),
                            ),
                            Expanded(
                              child: _buildFieldOrText("Last Name", lastNameCtrl, profile.lastName, vm.isEditing),
                            ),
                            Expanded(
                              child: _buildDatePickerField("Date of Birth", dobCtrl, profile.dateOfBirth, vm.isEditing),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFieldOrText("Address", addressCtrl, profile.address, vm.isEditing),
                            ),
                            Expanded(
                              child: _buildFieldOrText("Phone Number", phoneCtrl, profile.phoneNumber, vm.isEditing),
                            ),
                            Expanded(
                              child: _buildFieldOrText("Email Address", emailCtrl, profile.email, vm.isEditing),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (vm.isEditing) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8B400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(120, 45),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              vm.saveProfile(AdminProfileData(
                                firstName: firstNameCtrl.text,
                                lastName: lastNameCtrl.text,
                                email: emailCtrl.text,
                                role: profile.role,
                                phoneNumber: phoneCtrl.text,
                                address: addressCtrl.text,
                                dateOfBirth: dobCtrl.text,
                              ));
                              // ✅ update front-end avatar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Profile saved locally!")),
                              );
                            }
                          },
                          child: const Text("Save Changes", style: TextStyle(color: Colors.black)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002147),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            minimumSize: const Size(120, 45),
                          ),
                          onPressed: vm.cancelEdit,
                          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldOrText(String label, TextEditingController controller, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          isEditing
              ? TextFormField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
          )
              : Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, String value, bool isEditing) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 4),
          isEditing
              ? TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.black54),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(controller.text) ?? DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  controller.text = "${picked.year}-${picked.month}-${picked.day}";
                });
              }
            },
          )
              : Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
