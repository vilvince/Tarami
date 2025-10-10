import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarami_application/data/models/profile_model.dart';
import 'package:intl/intl.dart';
import 'package:tarami_application/core/services/profile_service.dart';
// ADD THESE IMPORTS
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isEditing = false;
  final formKey = GlobalKey<FormState>();

  // Add sync status
  bool _isSyncing = false;
  bool _hasPendingChanges = false;
  String? _syncError;

  bool get isSyncing => _isSyncing;
  bool get hasPendingChanges => _hasPendingChanges;
  String? get syncError => _syncError;

  // Local storage keys
  static const String _profileKey = 'local_profile';
  static const String _pendingChangesKey = 'pending_profile_changes';

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

  // Check internet connection
  Future<bool> _hasInternetConnection() async {
    try {
      final ConnectivityResult result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Load profile (tries Firestore first, falls back to local)
  Future<void> loadProfile() async {
    try {
      // Try to load from local storage first (instant load)
      await _loadProfileFromLocal();

      // Try to load from Firestore if online
      final hasInternet = await _hasInternetConnection();
      if (hasInternet) {
        print('Online - Loading profile from Firestore');
        final data = await _profileService.getUserProfile();

        if (data != null) {
          _profile = Profile.fromJson(data);

          // Save to local storage for offline access
          await _saveProfileToLocal();
        } else {
          // No profile in Firestore, use email from auth
          final email = _auth.currentUser?.email ?? '';
          _profile = Profile(
            firstName: '',
            lastName: '',
            gender: '',
            birthDate: '',
            contact: '',
            email: email,
          );
          await _saveProfileToLocal();
        }

        // Check if there are pending changes to sync
        await _syncPendingChanges();
      } else {
        print('Offline - Using cached profile');
        // If no local profile exists and offline
        if (_profile.email.isEmpty) {
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
      }

      _fillControllers();
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
      _syncError = 'Failed to load profile';
      notifyListeners();
    }
  }

  // Load profile from local storage
  Future<void> _loadProfileFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);

      if (profileJson != null) {
        final profileData = json.decode(profileJson) as Map<String, dynamic>;
        _profile = Profile.fromJson(profileData);
        print('Loaded profile from local storage');
      }

      // Check if there are pending changes
      final hasPending = prefs.getBool(_pendingChangesKey) ?? false;
      _hasPendingChanges = hasPending;
    } catch (e) {
      print('Error loading profile from local: $e');
    }
  }

  // Save profile to local storage
  Future<void> _saveProfileToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = {
        'email': _profile.email,
        'first_name': _profile.firstName,
        'last_name': _profile.lastName,
        'gender': _profile.gender,
        'birth_date': _profile.birthDate,
        'contact_number': _profile.contact,
      };

      await prefs.setString(_profileKey, json.encode(profileData));
      print('Saved profile to local storage');
    } catch (e) {
      print('Error saving profile to local: $e');
    }
  }

  // Mark that there are pending changes to sync
  Future<void> _markPendingChanges(bool hasPending) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingChangesKey, hasPending);
      _hasPendingChanges = hasPending;
      notifyListeners();
    } catch (e) {
      print('Error marking pending changes: $e');
    }
  }

  void _fillControllers() {
    firstNameController.text = _profile.firstName;
    lastNameController.text = _profile.lastName;
    genderController.text = _profile.gender;
    birthDateController.text = _profile.birthDate;
    contactController.text = _profile.contact;
    emailController.text = _profile.email;
  }

  // Edit profile
  void enterEditMode() {
    isEditing = true;
    _fillControllers();
    notifyListeners();
  }

  void cancelEdit() {
    isEditing = false;
    _fillControllers(); // Reset to original values
    notifyListeners();
  }

  // Save profile (works offline!)
  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      // Update local profile immediately (optimistic update)
      _profile = _profile.copyWith(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        gender: genderController.text,
        birthDate: birthDateController.text,
        contact: contactController.text,
      );

      // Save to local storage
      await _saveProfileToLocal();

      // Update UI immediately
      isEditing = false;
      notifyListeners();

      // Try to sync with Firestore if online
      final hasInternet = await _hasInternetConnection();
      if (hasInternet) {
        print('Online - Syncing profile to Firestore');
        _isSyncing = true;
        _syncError = null;
        notifyListeners();

        try {
          final existingProfile = await _profileService.getUserProfile();

          if (existingProfile == null) {
            // First time save → create profile
            await _profileService.createUserProfile(
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              gender: genderController.text,
              birthDate: birthDateController.text,
              contactNumber: contactController.text,
            );
          } else {
            // Update profile
            await _profileService.updateUserProfile(
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              gender: genderController.text,
              birthDate: birthDateController.text,
              contactNumber: contactController.text,
            );
          }

          // Clear pending changes flag
          await _markPendingChanges(false);
          print('Profile synced successfully');
        } catch (e) {
          print('Error syncing profile: $e');
          _syncError = 'Failed to sync profile';
          // Mark as pending for later sync
          await _markPendingChanges(true);
        } finally {
          _isSyncing = false;
          notifyListeners();
        }
      } else {
        print('Offline - Profile saved locally, will sync when online');
        // Mark as pending for later sync
        await _markPendingChanges(true);
      }
    } catch (e) {
      print('Error saving profile: $e');
      _syncError = 'Failed to save profile';
      notifyListeners();
    }
  }

  // Sync pending changes when connection returns
  Future<void> _syncPendingChanges() async {
    if (!_hasPendingChanges) return;

    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) return;

    print('Syncing pending profile changes...');
    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final existingProfile = await _profileService.getUserProfile();

      if (existingProfile == null) {
        // Create new profile
        await _profileService.createUserProfile(
          firstName: _profile.firstName,
          lastName: _profile.lastName,
          gender: _profile.gender,
          birthDate: _profile.birthDate,
          contactNumber: _profile.contact,
        );
      } else {
        // Update existing profile
        await _profileService.updateUserProfile(
          firstName: _profile.firstName,
          lastName: _profile.lastName,
          gender: _profile.gender,
          birthDate: _profile.birthDate,
          contactNumber: _profile.contact,
        );
      }

      // Clear pending changes flag
      await _markPendingChanges(false);
      print('Pending changes synced successfully');
    } catch (e) {
      print('Error syncing pending changes: $e');
      _syncError = 'Failed to sync changes';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Call this when app comes back online
  Future<void> syncWhenOnline() async {
    await _syncPendingChanges();
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
              primary: Color(0xFF0B1E2D),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    birthDateController.dispose();
    contactController.dispose();
    emailController.dispose();
    super.dispose();
  }
}