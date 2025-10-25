import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/data/models/package_details_page_args.dart';
import 'package:glovoapotheka/data/models/product.dart';
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
import 'package:glovoapotheka/features/package_details/view/package_details.dart';
import 'package:glovoapotheka/features/packages_menu/view/packages_view.dart';
import 'package:glovoapotheka/features/pharma_map/view/pharma_search_page.dart';
import 'package:glovoapotheka/features/search/cubit/search_cubit.dart'; // The SearchCubit
import 'package:glovoapotheka/features/packages_menu/cubit/product_packages_cubit.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';

// NOTE: Make sure you have your firebase_options.dart file from the FlutterFire CLI
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Create the router
  final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/packages/:productId',
        name: 'packages',
        builder: (context, state) { 
          final String productId = state.pathParameters['productId']!;
          return ProductPackagesPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/packages/:productId/package_details/:packageId',
        name: 'package_details',
        builder: (context, state) {
          final package = state.extra as PackageAvailabilityInfo;
          // Pass additional data via query parameters or state.extra
          final descr = state.uri.queryParameters['descr'] ?? '';
          final strength = state.uri.queryParameters['strength'] ?? '';
          final form = state.uri.queryParameters['form'] ?? '';
          
          // You'll need to fetch the package object here or pass minimal data
          return PackageDetailsPage(
            package: package,
            descr: descr,
            strength: strength,
            form: form,
          );
        },
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) {
          // For complex objects like List<CartItem>, use extra
          final packages = state.extra as List<CartItem>?;
          return PharmacySearchPage(packages: packages ?? []);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // 1. PROVIDE ALL REPOSITORIES AND CHANGE NOTIFIERS
    return MultiProvider(
      providers: [
        // REPOSITORIES
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<ProductRepository>(
          create: (context) => ProductRepositoryImpl(
            ProductApiProvider(
              //baseUrl: 'http://127.0.0.1:8000',
              baseUrl: 'http://192.168.0.105:25565'
            ),
          ),
        ),

        // CHANGE NOTIFIERS
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<CityService>(
          create: (_) => CityService(),
        ),
        ChangeNotifierProvider<PopularProductsService>(
          create: (_) => PopularProductsService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // BLOCS/CUBITS
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<SearchCubit>(
            create: (context) => SearchCubit(
              context.read<ProductRepository>(),
              context.read<CityService>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'PharmaCompare',
          theme: ThemeData(
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.grey[50],
          ),
          routerConfig: _router,
        ),
      ),
    );
  }
}
