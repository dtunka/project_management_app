import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_management_app/core/constants/app_constants.dart';
import 'package:project_management_app/core/networks/api_client.dart';
import 'package:project_management_app/features/authorization/data/repositories/auth_repo_impl.dart';
import 'package:project_management_app/features/authorization/presentation/pages/login.dart';
import 'package:project_management_app/features/authorization/presentation/providers/auth_provider.dart';
import 'package:project_management_app/features/authorization/presentation/pages/register.dart';

import './theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Create ApiClient instance here
  final ApiClient apiClient = ApiClient(baseUrl: AppConstant.baseUrl);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Provide the ApiClient
          Provider<ApiClient>.value(value: apiClient),
        //Provider<ApiClient>(create: (_) => apiClient),

        // 2. Auth Provider
        ChangeNotifierProvider(
          create: (context) {
            final client = Provider.of<ApiClient>(context, listen: false);
            return AuthProvider(
              AuthRepositoryImpl(client), 
            );
          },
        ),

       
        
       
      ],
      child: MaterialApp(
        title: 'Project Management App',
        theme: AppTheme.darkblueTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
         
        },
      ),
    );
  }
}