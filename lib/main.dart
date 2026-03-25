import 'package:flutter/material.dart';
import 'package:project_management_app/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:project_management_app/features/dashboard/presentation/pages/dashboard_pages.dart';
import 'package:project_management_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:project_management_app/features/teams/data/repositories/team_repository.dart';
import 'package:project_management_app/features/teams/presentation/providers/team_provider.dart';
import 'package:project_management_app/features/users/data/repositories/user_repository.dart';
import 'package:project_management_app/features/users/presentation/providers/user_provider.dart';

import 'package:project_management_app/features/projects/data/repositories/project_repository.dart';
import 'package:project_management_app/features/projects/presentation/providers/project_provider.dart';
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

        // 2. Auth Provider
        ChangeNotifierProvider(
          create: (context) {
            final client = Provider.of<ApiClient>(context, listen: false);
            return AuthProvider(
              AuthRepositoryImpl(client), 
            );
          },
        ),
        
        // 3. Admin Dashboard Provider
        ChangeNotifierProvider(
          create: (context) {
            final client = Provider.of<ApiClient>(context, listen: false);
            return DashboardProvider(
              repository: DashboardRepository(apiClient: client), 
            );
          },
        ),
        
        // 4. User Provider 
        ChangeNotifierProvider(
          create: (context) {
            final client = Provider.of<ApiClient>(context, listen: false);
            return UserProvider(
              repository: UserRepository(apiClient: client),
            );
          },
        ),
        
        // 5. Projects Provider 
        ChangeNotifierProvider(
          create: (context) {
            final client = Provider.of<ApiClient>(context, listen: false);
            return ProjectProvider(
              repository: ProjectRepository(apiClient: client),
            );
          },
        ),
        //6 TEAMS PROVIDER
        ChangeNotifierProvider(
          create: (context) {
            final client = Provider.of<ApiClient>(context, listen: false);
            return TeamProvider(
              repository: TeamRepository(apiClient: client),
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
          '/adminDashboard': (context) => const AdminDashboardPage(),
        },
      ),
    );
  }
}