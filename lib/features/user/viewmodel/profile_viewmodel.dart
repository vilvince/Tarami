import 'package:flutter/material.dart';
import 'package:tarami_application/data/models/profile_model.dart';
import 'package:intl/intl.dart';

class ProfileViewModel extends ChangeNotifier {
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

  void enterEditMode() {
    isEditing = true;
    firstNameController.text = _profile.firstName;
    lastNameController.text = _profile.lastName;
    genderController.text = _profile.gender;
    birthDateController.text = _profile.birthDate;
    contactController.text = _profile.contact;
    emailController.text = _profile.email;
    notifyListeners();
  }

  void saveProfile() {
    _profile = _profile.copyWith(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      gender: genderController.text,
      birthDate: birthDateController.text,
      contact: contactController.text,
      email: emailController.text,
    );
    isEditing = false;
    notifyListeners();
  }

  void cancelEdit() {
    isEditing = false;
    notifyListeners();
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
              primary: const Color(0xFF0B1E2D), // header background color & selected date
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
