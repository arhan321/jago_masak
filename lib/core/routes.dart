import 'package:flutter/material.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/dashboard/admin_dashboard_page.dart';
import '../pages/recipes/manage_recipes_page.dart';
import '../pages/recipes/add_edit_recipe_page.dart';
import '../pages/feedback/feedback_inbox_page.dart';
import '../users/manage_users_page.dart';
import '../settings/change_password_page.dart';
import '../notifications/notification_page.dart';
import '../pages/user/user_shell_page.dart';
import '../pages/user/user_search_page.dart';
import '../pages/user/masak_seadanya_page.dart';
import '../pages/user/user_account_info_page.dart';
import '../pages/user/user_settings_page.dart';
import '../pages/user/user_help_page.dart';
import '../pages/user/user_terms_page.dart';
import '../pages/categories/manage_categories_page.dart';

class Routes {
  static const root = '/';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';

  static const tambahResep = '/tambah-resep';
  static const kelolaResep = '/kelola-resep';
  static const masukanPengguna = '/masukan-pengguna';
  static const kelolaPengguna = '/kelola-pengguna';
  static const kelolaAkunAdmin = '/kelola-akun-admin';
  static const kelolaNotifikasi = '/kelola-notifikasi';
  // user
  static const userShell = '/user';
  static const userSearch = '/user-search';
  static const userMasakSeadanya = '/user-masak-seadanya';
  static const userAccountInfo = '/user-account-info';
  static const userSettings = '/user-settings';
  static const userHelp = '/user-help';
  static const userTerms = '/user-terms';
  static const userPrivacy = '/user-privacy';
  static const kelolaKategori = '/kelola-kategori';
}

final Map<String, WidgetBuilder> appRoutes = {
  Routes.root: (_) => const LoginPage(),
  Routes.login: (_) => const LoginPage(),
  Routes.register: (_) => const RegisterPage(),
  Routes.dashboard: (_) => const AdminDashboardPage(),
  Routes.tambahResep: (_) => const AddEditRecipePage(mode: FormMode.add),
  Routes.kelolaResep: (_) => const ManageRecipesPage(),
  Routes.masukanPengguna: (_) => const FeedbackInboxPage(),
  Routes.kelolaPengguna: (_) => const ManageUsersPage(),
  Routes.kelolaAkunAdmin: (_) => const ChangePasswordPage(),
  Routes.kelolaNotifikasi: (_) => const NotificationPage(),
  Routes.userShell: (_) => const UserShellPage(),
  Routes.userSearch: (_) => const UserSearchPage(),
  Routes.userMasakSeadanya: (_) => const MasakSeadanyaPage(),
  Routes.userAccountInfo: (_) => const UserAccountInfoPage(),
  Routes.userSettings: (_) => const UserSettingsPage(),
  Routes.userHelp: (_) => const UserHelpPage(),
  Routes.userTerms: (_) => const UserTermsPage(),
  Routes.userPrivacy: (_) => const UserPrivacyPage(),
  Routes.kelolaKategori: (_) => const ManageCategoriesPage(),
};
