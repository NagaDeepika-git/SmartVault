import 'package:flutter/material.dart';
import '../../data/models/document_model.dart';
import '../../data/models/product_model.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/documents/document_detail_screen.dart';
import '../../features/documents/document_form_screen.dart';
import '../../features/documents/document_list_screen.dart';
import '../../features/products/product_detail_screen.dart';
import '../../features/products/product_form_screen.dart';
import '../../features/products/product_list_screen.dart';
import '../../features/reminders/reminder_center_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/service_history/service_form_screen.dart';
import '../../features/service_history/service_history_screen.dart';
import '../../features/settings/security_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/warranties/warranty_overview_screen.dart';
import '../navigation/navigation_shell.dart';
import 'route_names.dart';

/// Central route configuration for SmartVault.
/// Implements declarative and named route navigation across all modules.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case RouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const NavigationShell(
            pages: [
              DashboardScreen(),
              DocumentListScreen(),
              ProductListScreen(),
              AnalyticsScreen(),
            ],
          ),
        );

      case RouteNames.documents:
        return MaterialPageRoute(builder: (_) => const DocumentListScreen());

      case RouteNames.documentDetail:
        final docId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DocumentDetailScreen(documentId: docId),
        );

      case RouteNames.documentForm:
        final docToEdit = settings.arguments as DocumentModel?;
        return MaterialPageRoute(
          builder: (_) => DocumentFormScreen(documentToEdit: docToEdit),
        );

      case RouteNames.products:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());

      case RouteNames.productDetail:
        final prodId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: prodId),
        );

      case RouteNames.productForm:
        final prodToEdit = settings.arguments as ProductModel?;
        return MaterialPageRoute(
          builder: (_) => ProductFormScreen(productToEdit: prodToEdit),
        );

      case RouteNames.warrantyOverview:
        return MaterialPageRoute(builder: (_) => const WarrantyOverviewScreen());

      case RouteNames.serviceHistory:
        return MaterialPageRoute(builder: (_) => const ServiceHistoryScreen());

      case RouteNames.serviceForm:
        final initialProdId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ServiceFormScreen(initialProductId: initialProdId),
        );

      case RouteNames.reminders:
        return MaterialPageRoute(builder: (_) => const ReminderCenterScreen());

      case RouteNames.analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());

      case RouteNames.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case RouteNames.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case RouteNames.security:
        return MaterialPageRoute(builder: (_) => const SecurityScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
