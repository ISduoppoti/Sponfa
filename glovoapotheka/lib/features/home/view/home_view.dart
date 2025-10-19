import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/features/auth/cubit/auth_cubit.dart';

import 'package:glovoapotheka/features/home/view/home_view_desktop.dart';
import 'package:glovoapotheka/features/home/view/home_view_mobile.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final double screenWidth = MediaQuery.of(context).size.width;
        const double mobileBreakpoint = 768.0;
        final bool isMobile = screenWidth < mobileBreakpoint;

        if (isMobile) {
          return HomeViewMobile();
        } else {
          return HomeViewDesktop(); // Desktop
        }
      },
    );
  }
}