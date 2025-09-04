import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfileService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;



  //create user profile in the database
  Future<void> createUserProfile({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
    required String contactNumber,
  })async{
    final user = currentUser;
    if (user == null){
      throw Exception('No authenticated user found');
    }

    try{
      final profileData = {
        'email': user.email!,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'birth_date': birthDate,
        'contact_number': contactNumber,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profileData);
    }catch(e){
      throw Exception('Error creating user profile: $e');

    }
  }

  //Get user profile from the database
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) {
      throw Exception('No authenticated user found');
    }
    try{
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if(doc.exists && doc.data() != null){
        return doc.data()!;
      }
      return null;
    }catch (e){
      throw Exception('Error getting user profile: $e');
    }
  }

  //Update usr profile in the database
  Future<void> updateUserProfile({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
    required String contactNumber,
  })async{
    if (currentUserId == null){
      throw Exception('No authenticated user found');
    }
    try{
      final updates = <String, dynamic>{};
      if (firstName.isNotEmpty) updates['first_name'] = firstName.trim();
      if (lastName.isNotEmpty) updates['last_name'] = lastName.trim();
      if (gender.isNotEmpty) updates['gender'] = gender;
      if (birthDate.isNotEmpty) updates['birth_date'] = birthDate;
      if (contactNumber.isNotEmpty) updates['contact_number'] = contactNumber.trim();
      if (updates.isNotEmpty) {
        updates['updated_at'] = FieldValue.serverTimestamp();

        await _firestore
            .collection('users')
            .doc(currentUserId)
            .update(updates);

        print('Profile updated successfully');
      }
    }catch(e){
      throw Exception('Error updating user profile: $e');
    }
  }

  /// Check if profile is complete
  Future<bool> hasCompletedProfile() async {
    if (currentUserId == null) return false;

    try {
      final profile = await getUserProfile();

      if (profile == null) return false;

      final requiredFields = ['first_name', 'last_name', 'gender', 'birth_date', 'contact_number'];

      for (String field in requiredFields) {
        if (profile[field] == null || profile[field].toString().trim().isEmpty) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }
}
