import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/domain/repositories/auth_repository.dart';
import 'package:glovoapotheka/domain/services/city_service.dart';
import 'package:glovoapotheka/domain/services/popular_products_service.dart';
import 'package:glovoapotheka/features/auth/cart/view/cart_view.dart';
import 'package:glovoapotheka/features/auth/cubit/auth_cubit.dart';
import 'package:glovoapotheka/features/auth/view/login_view.dart';
import 'package:glovoapotheka/features/home/view/home_view.dart';


import 'package:glovoapotheka/domain/repositories/product_repository.dart'; // The abstract class/interface
import 'package:glovoapotheka/domain/repositories/product_repository_impl.dart'; // The implementation
import 'package:glovoapotheka/data/providers/product_api_provider.dart'; // The API provider
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/features/packages_menu/view/packages_view.dart';
import 'package:glovoapotheka/features/search/cubit/search_cubit.dart'; // The SearchCubit
import 'package:glovoapotheka/features/packages_menu/cubit/product_packages_cubit.dart';
import 'package:provider/provider.dart';

// NOTE: Make sure you have your firebase_options.dart file from the FlutterFire CLI
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // IMPORTANT: Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We use MultiRepositoryProvider to provide multiple repositories
    return MultiRepositoryProvider(
      providers: [
        // 1. PROVIDE AUTH REPOSITORY
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),

        // 2. PROVIDE PRODUCT REPOSITORY
        RepositoryProvider<ProductRepository>(
          // First, create the API provider instance
          create: (context) => ProductRepositoryImpl(
            ProductApiProvider(
              baseUrl: 'http://127.0.0.1:8000', // <-- BACKEND URL
            ),
          ),
        ),
        // 3. PROVIDE CITY SERVICE
        ChangeNotifierProvider<CityService>(
          create: (_) => CityService(),
        ),
        ChangeNotifierProvider<PopularProductsService>( // Use Provider for simple non-listening classes
          create: (context) => PopularProductsService(),
          child: const MyApp(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider())
      ],
      child: MultiBlocProvider(
        providers: [
          // 1. PROVIDE AUTH CUBIT
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          
          // 2. PROVIDE SEARCH CUBIT
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(
              // The Cubit gets its dependency from the RepositoryProvider above
              context.read<ProductRepository>(),
              context.read<CityService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'PharmaCompare',
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.grey[50],
          ),
          home: const HomeView(),
          routes: {
            '/login': (context) => const LoginView(),
            '/home': (context) => const HomeView(),
          }
        ),
      ),
    );
  }
}