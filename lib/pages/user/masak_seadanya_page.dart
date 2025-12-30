import 'package:flutter/material.dart';
import '../../core/routes.dart';

class MasakSeadanyaPage extends StatefulWidget {
  const MasakSeadanyaPage({super.key});

  @override
  State<MasakSeadanyaPage> createState() => _MasakSeadanyaPageState();
}

class _MasakSeadanyaPageState extends State<MasakSeadanyaPage> {
  final items = <String, bool>{
    'Ayam': false,
    'Sapi': false,
    'Ikan': false,
    'Sayur': false,
    'Telur': false,
    'Tahu': false,
    'Tempe': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masak Seadanya')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Klik salah satu bahan masakan utama disini, sesuai dengan bahan masakan yang ada di rumah mu!',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            ...items.entries.map((e) {
              return CheckboxListTile(
                value: e.value,
                title: Text(e.key),
                onChanged: (v) => setState(() => items[e.key] = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.userSearch),
                child: const Text('Cari Sekarang!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
