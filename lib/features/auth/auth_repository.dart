import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

// Set up logger
final _logger = Logger('AuthRepository');

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase) {
    // Configure logger to output debug info in development
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      // In production, this could be sent to a logging service
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  /// Registers a new user with Supabase and creates their profile.
  ///
  /// Throws an [Exception] if registration or profile creation fails.
  Future<AuthResponse> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    File? profileImage,
  }) async {
    try {
      // Validate inputs
      _validateInputs(email, password, fullName, phoneNumber);

      _logger.info('Starting user registration for email: $email');

      // Register user with Supabase Auth
      final authResponse = await _signUpUser(
        email,
        password,
        fullName,
        phoneNumber,
      );

      // Verify session
      final session = authResponse.session;
      final user = authResponse.user;

      if (user == null) {
        _logger.severe('No user returned after signup');
        throw Exception('Registration failed: No user returned');
      }

      if (session == null) {
        _logger.warning(
          'User created, but no active session — email confirmation likely required.',
        );
        // You may still proceed to insert the user profile if needed or prompt the user to confirm their email
        return authResponse;
      }

      _logger.info('User created successfully with ID: ${user.id}');

      // Upload profile image if provided
      String? profileImageUrl = await _uploadProfileImage(
        authResponse.user!.id,
        profileImage,
      );

      // Create or update user profile in database
      await _createOrUpdateProfile(
        userId: session.user.id,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      _logger.info('User registration completed successfully');
      return authResponse;
    } catch (e, stackTrace) {
      _logger.severe('Registration failed: $e', e, stackTrace);
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Validates input parameters for registration.
  void _validateInputs(
    String email,
    String password,
    String fullName,
    String phoneNumber,
  ) {
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw Exception('Invalid email address');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    if (fullName.isEmpty) {
      throw Exception('Full name is required');
    }
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required');
    }
  }

  /// Signs up a user with Supabase Auth.
  Future<AuthResponse> _signUpUser(
    String email,
    String password,
    String fullName,
    String phoneNumber,
  ) async {
    _logger.fine('Attempting to sign up user with email: $email');
    final authResponse = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone_number': phoneNumber},
    );

    if (authResponse.user == null) {
      _logger.severe('No user returned from sign up');
      throw Exception('Registration failed: No user returned');
    }

    return authResponse;
  }

  /// Uploads a profile image to Supabase storage if provided.
  Future<String?> _uploadProfileImage(String userId, File? profileImage) async {
    if (profileImage == null) return null;

    _logger.fine('Uploading profile image for user: $userId');
    try {
      final fileExt = profileImage.path.split('.').last;
      final fileName = '$userId/profile.$fileExt';
      final filePath = 'profile_images/$fileName';

      await _supabase.storage
          .from('profiles')
          .upload(
            filePath,
            profileImage,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final profileImageUrl = _supabase.storage
          .from('profiles')
          .getPublicUrl(filePath);
      _logger.fine('Profile image uploaded successfully: $profileImageUrl');
      return profileImageUrl;
    } catch (e, stackTrace) {
      _logger.warning('Failed to upload profile image: $e', e, stackTrace);
      return null; // Continue registration even if image upload fails
    }
  }

  /// Creates or updates a user profile in the database.
  Future<void> _createOrUpdateProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phoneNumber,
    String? profileImageUrl,
  }) async {
    _logger.fine('Creating/updating profile for user: $userId');
    final profileData = {
      'id': userId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'profile_image_url': profileImageUrl,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      // Check if profile exists
      final existingProfile =
          await _supabase
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      if (existingProfile != null) {
        _logger.fine('Profile exists, updating profile for user: $userId');
        await _supabase.from('profiles').update(profileData).eq('id', userId);
      } else {
        _logger.fine('Creating new profile for user: $userId');
        await _supabase.from('profiles').insert(profileData);
      }
      _logger.info('User profile created/updated successfully');
    } catch (e, stackTrace) {
      _logger.severe('Failed to create/update user profile: $e', e, stackTrace);
      if (e is PostgrestException) {
        throw Exception('Failed to create user profile: ${e.message}');
      }
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    _logger.info('Signing out user');
    try {
      await _supabase.auth.signOut();
      _logger.info('User signed out successfully');
    } catch (e, stackTrace) {
      _logger.severe('Sign out failed: $e', e, stackTrace);
      throw Exception('Sign out failed: $e');
    }
  }
}
