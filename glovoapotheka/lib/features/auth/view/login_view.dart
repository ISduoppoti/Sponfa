import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/features/auth/cubit/auth_cubit.dart';

import 'package:glovoapotheka/features/auth/view/login_view_desktop.dart';

import 'package:glovoapotheka/features/auth/widgets/pc_right_login_side.dart';
import 'package:glovoapotheka/features/auth/widgets/animated_bubles.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final double screenWidth = MediaQuery.of(context).size.width;
          const double mobileBreakpoint = 768.0;
          final bool isMobile = screenWidth < mobileBreakpoint;

          if (state.status == AuthStatus.unknown || state.status == AuthStatus.unauthenticated) {
            // If the state is unauthorized, show responsive login screens.
            if (isMobile) {
              return Scaffold(
                body: Stack(
                  children: [
                    AnimatedBubles(),
                    Center(
                      child: LoginRegisterForm(), // Mobile view
                    ),
                  ],
                ),
              );
            } else {
              return LoginViewDesktop(); // Desktop
            }
          }
          // Fallback for AuthInitial or other unexpected states (e.g., a loading spinner)
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
    );
  }
}