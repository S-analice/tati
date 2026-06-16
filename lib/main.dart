import 'package:firebase_auth/firebase_auth.dart'; // CORRIGIDO: Adicionado import que faltava
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:injustice_app/core/theme/app_theme.dart' as AppTheme;
import 'package:signals_flutter/signals_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/routes/app_routes.dart';
// ignore: unused_import
import 'core/theme/app_theme.dart' as app_theme;
import 'core/theme/theme_controller.dart';
import 'data/services/auth_service_interface.dart';
import 'presentation/controllers/account_viewmodel.dart';
import 'presentation/controllers/characters_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDXKqJmyRcdLREm_k_XQHjyxZ3woef_3Nw",
      authDomain: "projeto-injustice.firebaseapp.com",
      projectId: "projeto-injustice",
      storageBucket: "projeto-injustice.firebasestorage.app",
      messagingSenderId: "599565488547",
      appId: "1:599565488547:web:648ef7ad9fa837cef24a16"
    ),
  );

  setupDependencyInjection();
  final themeController = injector.get<ThemeController>();
  final authService = injector.get<IAuthService>();

  runApp(
    Watch(
      (_) => StreamBuilder<User?>( // CORRIGIDO: Tipagem definida para User?
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final firebaseUser = FirebaseAuth.instance.currentUser;

          // Se existe um usuário no estado local, precisamos validar se ele ainda existe no servidor
          if (firebaseUser != null) {
            return FutureBuilder(
              future: firebaseUser.reload(),
              builder: (context, reloadSnapshot) {
                // Enquanto verifica com o servidor se a conta é válida, exibe o carregamento
                if (reloadSnapshot.connectionState == ConnectionState.waiting) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    home: const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                // Se houver erro no reload (ex: user-not-found porque foi excluído no console)
                if (reloadSnapshot.hasError) {
                  // Força a higienização completa da memória e desloga o cache local
                  FirebaseAuth.instance.signOut();
                  
                  try {
                    injector.get<AccountViewModel>().clearAccountData();
                    injector.get<CharactersViewModel>().clearCharactersData();
                  } catch (_) {}

                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    title: 'Injustice App',
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeController.themeMode.value,
                    routerConfig: AppRouter.router,
                  );
                }

                // Usuário validado com sucesso no servidor, segue para o app
                return MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  title: 'Injustice App',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeController.themeMode.value,
                  routerConfig: AppRouter.router,
                );
              },
            );
          }

          // Se nenhum usuário estiver logado localmente, renderiza as rotas padrão (tela de login)
          try {
            injector.get<AccountViewModel>().clearAccountData();
            injector.get<CharactersViewModel>().clearCharactersData();
          } catch (_) {}

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Injustice App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode.value,
            routerConfig: AppRouter.router,
          );
        },
      ),
    ),
  );
}