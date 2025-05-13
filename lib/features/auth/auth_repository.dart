import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Future<AuthResponse> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    File? profileImage,
  }) async {
    try {
      print('AuthRepository: Starting user registration...');
      print(
        'AuthRepository: Supabase URL: ${_supabase.auth.currentSession?.accessToken != null ? 'Initialized' : 'Not initialized'}',
      );

      // 1. Register the user with Supabase Auth
      print('AuthRepository: Attempting to sign up user with email: $email');
      try {
        final authResponse = await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName, 'phone_number': phoneNumber},
        );

        print('AuthRepository: Sign up response received');
        print(
          'AuthRepository: Response status: ${authResponse.session != null ? 'Success' : 'No session'}',
        );
        print(
          'AuthRepository: Response user: ${authResponse.user != null ? 'User created' : 'No user'}',
        );

        if (authResponse.user == null) {
          print('AuthRepository: No user returned from sign up');
          if (authResponse.session == null) {
            print('AuthRepository: No session created');
          }
          throw Exception('Registration failed: No user returned from sign up');
        }

        // Wait for a short moment to ensure the user is fully created
        await Future.delayed(const Duration(seconds: 1));

        // Verify the session
        final session = _supabase.auth.currentSession;
        print(
          'AuthRepository: Current session: ${session != null ? 'Exists' : 'None'}',
        );
        print('AuthRepository: User ID from session: ${session?.user.id}');
        print(
          'AuthRepository: User ID from response: ${authResponse.user!.id}',
        );

        if (session == null) {
          print('AuthRepository: No active session after signup');
          throw Exception(
            'Registration failed: No active session after signup',
          );
        }

        print(
          'AuthRepository: User created successfully with ID: ${authResponse.user!.id}',
        );

        // 2. Upload profile image if provided
        String? profileImageUrl;
        if (profileImage != null) {
          print('AuthRepository: Uploading profile image...');
          final fileExt = profileImage.path.split('.').last;
          final fileName = '${authResponse.user!.id}/profile.$fileExt';
          final filePath = 'profile_images/$fileName';

          try {
            await _supabase.storage
                .from('profiles')
                .upload(
                  filePath,
                  profileImage,
                  fileOptions: const FileOptions(
                    cacheControl: '3600',
                    upsert: true,
                  ),
                );
            print('AuthRepository: Profile image uploaded successfully');

            profileImageUrl = _supabase.storage
                .from('profiles')
                .getPublicUrl(filePath);
            print('AuthRepository: Profile image URL: $profileImageUrl');
          } catch (e, stack) {
            print('AuthRepository: Error uploading profile image: $e');
            print('AuthRepository: Stack trace: $stack');
            // Continue with registration even if image upload fails
          }
        }

        // 3. Create user profile in the database
        print('AuthRepository: Creating user profile in database...');
        try {
          final profileData = {
            'id': session.user.id, // Use ID from session instead of response
            'full_name': fullName,
            'phone_number': phoneNumber,
            'email': email,
            'profile_image_url': profileImageUrl,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          print(
            'AuthRepository: Attempting to insert profile data: $profileData',
          );

          // First check if profile already exists
          final existingProfile =
              await _supabase
                  .from('profiles')
                  .select()
                  .eq('id', session.user.id)
                  .single();

          if (existingProfile != null) {
            print('AuthRepository: Profile already exists, updating instead');
            final response = await _supabase
                .from('profiles')
                .update(profileData)
                .eq('id', session.user.id);
            print('AuthRepository: Profile update response: $response');
          } else {
            print('AuthRepository: Creating new profile');
            final response =
                await _supabase.from('profiles').insert(profileData).select();
            print('AuthRepository: Profile insert response: $response');
          }

          print('AuthRepository: User profile created/updated successfully');
        } catch (e, stack) {
          print('AuthRepository: Error creating user profile: $e');
          print('AuthRepository: Stack trace: $stack');
          if (e is PostgrestException) {
            throw Exception('Failed to create user profile: ${e.message}');
          }
          throw Exception('Failed to create user profile: $e');
        }

        return authResponse;
      } catch (e, stack) {
        print('AuthRepository: Supabase auth error: $e');
        print('AuthRepository: Stack trace: $stack');
        if (e is AuthException) {
          throw Exception('Registration failed: ${e.message}');
        }
        rethrow;
      }
    } catch (e, stack) {
      print('AuthRepository: Registration failed with error: $e');
      print('AuthRepository: Stack trace: $stack');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
