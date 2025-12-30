import 'package:flutter/material.dart';
import '../../core/mock_db.dart';
import '../../widgets/admin_drawer.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final ScrollController _hCtrl = ScrollController();

  @override
  void dispose() {
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = MockDb.instance.users;

    return Scaffold(
      appBar: AppBar(title: const Text('Jago Masak')),
      drawer: const AdminDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kelola Pengguna',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Scrollbar(
                      controller: _hCtrl,
                      thumbVisibility: true,
                      trackVisibility: true,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      child: SingleChildScrollView(
                        controller: _hCtrl,
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          // ✅ paksa tabel lebih lebar dari layar, jadi pasti bisa geser
                          constraints: const BoxConstraints(minWidth: 820),
                          child: DataTable(
                            headingRowHeight: 48,
                            dataRowHeight: 56,
                            columnSpacing: 28,
                            horizontalMargin: 16,
                            dividerThickness: 0.8,
                            headingRowColor: MaterialStatePropertyAll(
                              Colors.blueGrey.shade300,
                            ),
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                            columns: const [
                              DataColumn(
                                  label:
                                      SizedBox(width: 60, child: Text('No.'))),
                              DataColumn(
                                  label: SizedBox(
                                      width: 160, child: Text('Nama'))),
                              DataColumn(
                                  label: SizedBox(
                                      width: 220, child: Text('Email'))),
                              DataColumn(
                                  label: SizedBox(
                                      width: 140, child: Text('No. HP'))),
                              DataColumn(
                                  label: SizedBox(
                                      width: 200, child: Text('Tgl Dibuat'))),
                            ],
                            rows: List.generate(users.length, (i) {
                              final u = users[i];
                              return DataRow(
                                cells: [
                                  DataCell(SizedBox(
                                      width: 60, child: Text('${i + 1}.'))),
                                  DataCell(
                                    SizedBox(
                                      width: 160,
                                      child: Text(
                                        u.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 220,
                                      child: Text(
                                        u.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  DataCell(SizedBox(
                                      width: 140, child: Text(u.phone))),
                                  DataCell(
                                    SizedBox(
                                      width: 200,
                                      child: Text(u.createdAtText),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tersimpan (dummy).')),
                ),
                child: const Text('Simpan'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
