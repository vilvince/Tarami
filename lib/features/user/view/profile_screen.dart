import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
// ADD THIS IMPORT
import 'package:connectivity_plus/connectivity_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _listenToConnectivity();
    Future.microtask(() =>
        Provider.of<ProfileViewModel>(context, listen: false).loadProfile());
  }

  // Check initial connectivity
  Future<void> _checkConnectivity() async {
    final ConnectivityResult result =
    await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  // Listen to connectivity changes
  void _listenToConnectivity() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final wasOffline = !_isOnline;
      final isNowOnline = result != ConnectivityResult.none;

      setState(() {
        _isOnline = isNowOnline;
      });

      // If just came online, sync pending changes
      if (wasOffline && isNowOnline && mounted) {
        context.read<ProfileViewModel>().syncWhenOnline();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, _) {
        return WillPopScope(
          onWillPop: () async {
            if (viewModel.isEditing) {
              viewModel.cancelEdit();
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF0B1E2D),
            body: SafeArea(
              child: Column(
                children: [


                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                          onPressed: () {
                            if (viewModel.isEditing) {
                              viewModel.cancelEdit();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        const Text(
                          'Profile Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (!viewModel.isEditing) {
                              viewModel.enterEditMode();
                            }
                          },
                          child: Text(
                            viewModel.isEditing ? '' : 'Edit',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Profile Content
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: viewModel.isEditing
                            ? _buildEditableForm(context, viewModel)
                            : _buildProfileDetails(viewModel),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableForm(BuildContext context, ProfileViewModel viewModel) {
    return Form(
      key: viewModel.formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Show offline info in edit mode
            if (!_isOnline)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You\'re offline. Changes will be saved locally and synced when you\'re back online.',
                        style: TextStyle(
                            color: Colors.orange[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            _buildTextFormField(
              viewModel.firstNameController,
              'First Name',
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your first name'
                  : null,
            ),
            _buildTextFormField(
              viewModel.lastNameController,
              'Last Name',
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your last name'
                  : null,
            ),

            DropdownButtonFormField2<String>(
              value: viewModel.genderController.text.isNotEmpty
                  ? viewModel.genderController.text
                  : null,
              items: const [
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
              ],
              onChanged: (value) {
                if (value != null) {
                  viewModel.genderController.text = value;
                }
              },
              decoration: InputDecoration(
                labelText: 'Gender',
                labelStyle: const TextStyle(color: Colors.black87),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )),
            ),

            // Date picker handled by ViewModel
            GestureDetector(
              onTap: () => viewModel.selectBirthDate(context),
              child: AbsorbPointer(
                child: _buildTextFormField(
                  viewModel.birthDateController,
                  'Date of Birth',
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select your birth date'
                      : null,
                ),
              ),
            ),

            _buildTextFormField(
              viewModel.contactController,
              'Contact Number',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a contact number';
                } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'Please enter numbers only';
                } else if (value.length < 8 || value.length > 11) {
                  return 'Contact number must be 8–11 digits';
                }
                return null;
              },
            ),

            _buildTextFormField(
              viewModel.emailController,
              'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || value.isEmpty
                  ? 'Please enter your email address'
                  : null,
              readOnly: true,
              enabled: false,
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (viewModel.formKey.currentState!.validate()) {
                  await viewModel.saveProfile();
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: const Color(0xFFFFC727),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(ProfileViewModel viewModel) {
    Map<String, String> profileMap = {
      'First Name': viewModel.profile.firstName,
      'Last Name': viewModel.profile.lastName,
      'Gender': viewModel.profile.gender,
      'Date of Birth': viewModel.profile.birthDate,
      'Contact Number': viewModel.profile.contact,
      'Email Address': viewModel.profile.email,
    };

    return ListView(
      children: profileMap.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${entry.key}:',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              Flexible(
                child: Text(
                  entry.value.isNotEmpty ? entry.value : 'Not Available',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
        bool enabled = true,
        bool readOnly = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        cursorColor: Colors.black,
        validator: validator,
        enabled: enabled,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          floatingLabelStyle: const TextStyle(color: Colors.black),
          errorStyle: const TextStyle(color: Colors.red, fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 2.0,
            ),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
      ),
    );
  }
}