import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/router/app_router.dart';
import 'app/router/route_names.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_provider.dart';
import 'features/documents/document_provider.dart';
import 'features/products/product_provider.dart';
import 'features/reminders/reminder_provider.dart';
import 'features/service_history/service_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartVaultRoot());
}

/// Root widget with MultiProvider injecting all state managers.
class SmartVaultRoot extends StatelessWidget {
  const SmartVaultRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: const SmartVaultApp(),
    );
  }
}

/// MaterialApp container responding dynamically to theme changes and named routing.
class SmartVaultApp extends StatelessWidget {
  const SmartVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SmartVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: RouteNames.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
