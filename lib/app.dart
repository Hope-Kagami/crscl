import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/appointments/appointment_screen.dart';
import 'features/appointments/appointments_screen.dart';
import 'features/repair_centers/models/repair_center.dart';
import 'features/repair_centers/service_center_details_screen.dart';
import 'features/chat/chat_list_screen.dart';
import 'features/chat/chat_interface_screen.dart';
import 'features/reviews/leave_review_screen.dart';
import 'features/reviews/all_reviews_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'core/theme/app_theme.dart';

class CRSCLApp extends StatelessWidget {
  const CRSCLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRSCL',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/booking': (context) {
          final repairCenter =
              ModalRoute.of(context)!.settings.arguments as RepairCenter;
          return AppointmentScreen(repairCenter: repairCenter);
        },
        '/appointments': (context) => const AppointmentsScreen(),
        '/service-center-details':
            (context) => const ServiceCenterDetailsScreen(),
        '/chat-list': (context) => const ChatListScreen(),
        '/chat': (context) => const ChatInterfaceScreen(),
        '/leave-review': (context) => const LeaveReviewScreen(),
        '/all-reviews': (context) => const AllReviewsScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}
