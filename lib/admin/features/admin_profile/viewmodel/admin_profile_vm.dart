import 'package:flutter/material.dart';
import '../data/admin_profile_model.dart';

class AdminProfileVM extends ChangeNotifier {
  AdminProfileData profile = AdminProfileData(
    firstName: "Juan",
    lastName: "Cruz",
    email: "juan@gmail.com",
    role: "Admin",
    phoneNumber: "09991123443",
    address: "Legazpi City, Albay",
    dateOfBirth: "October 10, 2000",
  );

  bool isEditing = false;

  void toggleEdit() {
    isEditing = !isEditing;
    notifyListeners();
  }

  void saveProfile(AdminProfileData updatedProfile) {
    profile = updatedProfile;
    isEditing = false;
    notifyListeners();
  }

  void cancelEdit() {
    isEditing = false;
    notifyListeners();
  }
}
