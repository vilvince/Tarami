import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarami_application/data/models/profile_model.dart';
import 'package:intl/intl.dart';
import 'package:tarami_application/core/services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {

  final ProfileService _profileService = ProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;



  bool isEditing = false;
  final formKey = GlobalKey<FormState>();

  Profile _profile = Profile(
    firstName: '',
    lastName: '',
    gender: '',
    birthDate: '',
    contact: '',
    email: '',
  );

  Profile get profile => _profile;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final genderController = TextEditingController();
  final birthDateController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();

  //Load profile from database

  Future<void> loadProfile() async {

    final data = await _profileService.getUserProfile();
    if (data != null) {
      _profile = Profile.fromJson(data);
    }else{
      final email = _auth.currentUser?.email ?? '';
      _profile = Profile(
        firstName: '',
        lastName: '',
        gender: '',
        birthDate: '',
        contact: '',
        email: email,
      );
    }

    _fillControllers();
    notifyListeners();
  }

  void _fillControllers() {
    firstNameController.text = _profile.firstName;
    lastNameController.text = _profile.lastName;
    genderController.text = _profile.gender;
    birthDateController.text = _profile.birthDate;
    contactController.text = _profile.contact;
    emailController.text = _profile.email;
  }

  //Edit profile
  void enterEditMode() {
    isEditing = true;
    _fillControllers();
    notifyListeners();
  }

  void cancelEdit() {
    isEditing = false;
    notifyListeners();
  }

  //Save profile
  Future<void> saveProfile() async{

    if (formKey.currentState!.validate()) {
      final existingProfile = await _profileService.getUserProfile();

      if (existingProfile == null) {
        // ✅ First time save → create profile
        await _profileService.createUserProfile(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          gender: genderController.text,
          birthDate: birthDateController.text,
          contactNumber: contactController.text,
        );
      } else {
        // ✅ Update profile
        await _profileService.updateUserProfile(
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          gender: genderController.text,
          birthDate: birthDateController.text,
          contactNumber: contactController.text,
        );
      }

      _profile = _profile.copyWith(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        gender: genderController.text,
        birthDate: birthDateController.text,
        contact: contactController.text,
      );

      isEditing = false;
      notifyListeners();
    }
  }



  Future<void> selectBirthDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary:  Color(0xFF0B1E2D), // header background color & selected date
              onPrimary: Colors.white,    // header text color
              onSurface: Colors.black,    // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // buttons (OK / Cancel)
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('MM-dd-yyyy').format(pickedDate);
      birthDateController.text = formattedDate;
    }
  }
}
