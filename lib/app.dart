import 'package:flutter/material.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/appointments/booking_screen.dart';
import 'features/appointments/booking_success_screen.dart';
import 'features/appointments/booking_failure_screen.dart';
import 'features/appointments/booking_history_screen.dart';
import 'features/repair_centers/service_center_details_screen.dart';
import 'features/chat/chat_list_screen.dart';
import 'features/chat/chat_interface_screen.dart';
import 'features/reviews/leave_review_screen.dart';
import 'features/reviews/all_reviews_screen.dart';
import 'core/theme.dart';

class CRSCLApp extends StatelessWidget {
  const CRSCLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRSCL',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/main': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/booking': (context) => const BookingScreen(),
        '/booking-success': (context) => const BookingSuccessScreen(),
        '/booking-failure': (context) => const BookingFailureScreen(),
        '/booking-history': (context) => const BookingHistoryScreen(),
        '/service-center-details':
            (context) => const ServiceCenterDetailsScreen(),
        '/chat-list': (context) => const ChatListScreen(),
        '/chat': (context) => const ChatInterfaceScreen(),
        '/leave-review': (context) => const LeaveReviewScreen(),
        '/all-reviews': (context) => const AllReviewsScreen(),
      },
    );
  }
}
