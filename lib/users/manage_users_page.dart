import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../core/routes.dart';
import '../../widgets/admin_drawer.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  bool _loading = true;
  String? _error;

  List<_ApiUserRow> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = ApiClient.instance.dio;

      // ✅ pastikan backend punya GET /api/users (admin only biasanya)
      final res = await dio.get('/users');
      final data = res.data;

      List<_ApiUserRow> parsed = [];

      // 1) Kalau backend return List langsung: [ {...}, {...} ]
      if (data is List) {
        parsed = data
            .map((e) => e is Map
                ? _ApiUserRow.fromJson(Map<String, dynamic>.from(e))
                : null)
            .whereType<_ApiUserRow>()
            .toList();
      }

      // 2) Kalau backend return paginate: { data: [ ... ], ... }
      else if (data is Map && data['data'] is List) {
        final list = List.from(data['data'] as List);
        parsed = list
            .map((e) => e is Map
                ? _ApiUserRow.fromJson(Map<String, dynamic>.from(e))
                : null)
            .whereType<_ApiUserRow>()
            .toList();
      }

      // 3) paginate nested: { data: { data: [...] } }
      else if (data is Map &&
          data['data'] is Map &&
          (data['data'] as Map)['data'] is List) {
        final nested = data['data'] as Map;
        final list = List.from(nested['data'] as List);
        parsed = list
            .map((e) => e is Map
                ? _ApiUserRow.fromJson(Map<String, dynamic>.from(e))
                : null)
            .whereType<_ApiUserRow>()
            .toList();
      } else {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'Format response tidak sesuai';
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _users = parsed;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      // token invalid/expired
      if (e.response?.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
        return;
      }

      setState(() {
        _loading = false;
        _error = (e.response?.data is Map)
            ? ((e.response?.data['message'] ?? 'Gagal memuat users').toString())
            : 'Gagal memuat users';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat users';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Kelola Pengguna',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _fetchUsers,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),

            // ===== CONTENT =====
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                      ? _ErrorBox(message: _error!, onRetry: _fetchUsers)
                      : RefreshIndicator(
                          onRefresh: _fetchUsers,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemCount: _users.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final u = _users[index];
                              return _UserCard(
                                index: index + 1,
                                user: u,
                              );
                            },
                          ),
                        ),
            ),

            // ===== FOOTER BUTTON (tetap ada biar struktur kamu aman) =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Belum ada aksi simpan (API read-only).'),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final int index;
  final _ApiUserRow user;

  const _UserCard({
    required this.index,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role.toLowerCase() == 'admin';

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          // nuansa biru muda biar nyambung sama dashboard
          color: AppTheme.softBlue,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== NUMBER BADGE =====
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.navy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ===== MAIN CONTENT =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + role chip
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          user.name.isEmpty ? '-' : user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _RoleChip(
                        text: user.role.isEmpty ? '-' : user.role,
                        isAdmin: isAdmin,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Email
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  const SizedBox(height: 6),

                  // Phone
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'No. HP',
                    value: user.phone,
                  ),
                  const SizedBox(height: 6),

                  // Created at
                  _InfoRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Dibuat',
                    value: user.createdAtText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String text;
  final bool isAdmin;

  const _RoleChip({required this.text, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.redAccent.withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAdmin ? Colors.redAccent.withOpacity(0.35) : Colors.white24,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: isAdmin ? Colors.redAccent : AppTheme.navy,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.isEmpty ? '-' : value;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.navy),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _ApiUserRow {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String createdAtText;

  _ApiUserRow({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAtText,
  });

  factory _ApiUserRow.fromJson(Map<String, dynamic> json) {
    final createdAt = (json['created_at'] ?? '').toString();

    final roleVal = (json['role'] ?? json['roles'] ?? '-').toString();
    final phoneVal =
        (json['nomor_telfon'] ?? json['phone'] ?? json['no_hp'] ?? '-')
            .toString();

    return _ApiUserRow(
      id: (json['id'] ?? 0) is int
          ? (json['id'] as int)
          : int.tryParse('${json['id']}') ?? 0,
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: phoneVal,
      role: roleVal,
      createdAtText: _formatCreatedAt(createdAt),
    );
  }

  static String _formatCreatedAt(String iso) {
    if (iso.isEmpty) return '-';
    final s = iso.replaceAll('T', ' ');
    final noMs = s.split('.').first;
    final noZ = noMs.replaceAll('Z', '');
    return noZ.length >= 16 ? noZ.substring(0, 16) : noZ;
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
