import 'package:flutter/material.dart';

class UserTermsPage extends StatelessWidget {
  const UserTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Syarat dan Ketentuan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text('KEBIJAKAN PRIVASI – JAGO MASAK\n\n'
                    'Terakhir diperbarui: ____/____/____\n\n'
                    'Terima kasih telah menggunakan Jago Masak. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi informasi Anda saat menggunakan aplikasi.\n\n'
                    '1. Informasi yang Kami Kumpulkan\n'
                    'a) Informasi Akun\n'
                    '- Nama, email, dan informasi profil yang Anda berikan saat mendaftar/login.\n\n'
                    'b) Aktivitas Penggunaan\n'
                    '- Riwayat resep yang Anda lihat, resep favorit, serta interaksi di aplikasi untuk meningkatkan pengalaman Anda.\n\n'
                    'c) Data Teknis (opsional)\n'
                    '- Informasi perangkat dan log error (misalnya saat aplikasi crash) untuk membantu perbaikan performa.\n\n'
                    '2. Cara Kami Menggunakan Informasi\n'
                    'Kami menggunakan data Anda untuk:\n'
                    '- Menyediakan fitur aplikasi (login, favorit, riwayat, notifikasi).\n'
                    '- Menampilkan konten yang relevan dan meningkatkan pengalaman pengguna.\n'
                    '- Menjaga keamanan akun dan mencegah penyalahgunaan.\n'
                    '- Menganalisis performa aplikasi dan memperbaiki bug.\n\n'
                    '3. Penyimpanan & Keamanan Data\n'
                    '- Data Anda disimpan di server dan/atau perangkat sesuai kebutuhan fitur.\n'
                    '- Kami menerapkan langkah-langkah keamanan yang wajar untuk melindungi data dari akses tidak sah, perubahan, atau penghapusan.\n'
                    '- Namun, tidak ada sistem yang 100% aman. Kami tetap berupaya semaksimal mungkin menjaga keamanan data Anda.\n\n'
                    '4. Berbagi Data dengan Pihak Ketiga\n'
                    'Kami tidak menjual data pribadi Anda.\n'
                    'Data dapat dibagikan hanya jika:\n'
                    '- Diperlukan untuk operasional layanan (misalnya penyedia infrastruktur/server).\n'
                    '- Diwajibkan oleh hukum atau permintaan resmi dari pihak berwenang.\n\n'
                    '5. Notifikasi\n'
                    'Jika Anda mengaktifkan notifikasi, kami dapat mengirimkan informasi terkait pembaruan aplikasi, fitur, atau konten. Anda dapat mengelola notifikasi melalui pengaturan perangkat Anda.\n\n'
                    '6. Hak Pengguna\n'
                    'Anda berhak untuk:\n'
                    '- Mengakses informasi akun Anda.\n'
                    '- Memperbarui data akun (nama/email/nomor telepon jika tersedia).\n'
                    '- Meminta penghapusan akun (jika fitur tersedia).\n\n'
                    '7. Retensi Data\n'
                    'Kami menyimpan data selama akun Anda aktif atau selama diperlukan untuk menyediakan layanan. Setelah akun dihapus, data akan dihapus atau dianonimkan sesuai ketentuan yang berlaku.\n\n'
                    '8. Perubahan Kebijakan\n'
                    'Kebijakan ini dapat diperbarui sewaktu-waktu. Jika ada perubahan penting, kami akan menampilkan pemberitahuan di aplikasi.\n\n'
                    '9. Kontak\n'
                    'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi kami melalui:\n'
                    'Email: support@jagomasak.com\n\n'
                    'Dengan menekan tombol “Saya Mengerti”, Anda menyatakan telah membaca dan memahami Kebijakan Privasi ini.\n'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Setuju'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UserPrivacyPage extends StatelessWidget {
  const UserPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kebijakan Privasi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                child: Text('KEBIJAKAN PRIVASI – JAGO MASAK\n\n'
                    'Terakhir diperbarui: ____/____/____\n\n'
                    'Terima kasih telah menggunakan Jago Masak. Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, menyimpan, dan melindungi informasi Anda saat menggunakan aplikasi.\n\n'
                    '1. Informasi yang Kami Kumpulkan\n'
                    'a) Informasi Akun\n'
                    '- Nama, email, dan informasi profil yang Anda berikan saat mendaftar/login.\n\n'
                    'b) Aktivitas Penggunaan\n'
                    '- Riwayat resep yang Anda lihat, resep favorit, serta interaksi di aplikasi untuk meningkatkan pengalaman Anda.\n\n'
                    'c) Data Teknis (opsional)\n'
                    '- Informasi perangkat dan log error (misalnya saat aplikasi crash) untuk membantu perbaikan performa.\n\n'
                    '2. Cara Kami Menggunakan Informasi\n'
                    'Kami menggunakan data Anda untuk:\n'
                    '- Menyediakan fitur aplikasi (login, favorit, riwayat, notifikasi).\n'
                    '- Menampilkan konten yang relevan dan meningkatkan pengalaman pengguna.\n'
                    '- Menjaga keamanan akun dan mencegah penyalahgunaan.\n'
                    '- Menganalisis performa aplikasi dan memperbaiki bug.\n\n'
                    '3. Penyimpanan & Keamanan Data\n'
                    '- Data Anda disimpan di server dan/atau perangkat sesuai kebutuhan fitur.\n'
                    '- Kami menerapkan langkah-langkah keamanan yang wajar untuk melindungi data dari akses tidak sah, perubahan, atau penghapusan.\n'
                    '- Namun, tidak ada sistem yang 100% aman. Kami tetap berupaya semaksimal mungkin menjaga keamanan data Anda.\n\n'
                    '4. Berbagi Data dengan Pihak Ketiga\n'
                    'Kami tidak menjual data pribadi Anda.\n'
                    'Data dapat dibagikan hanya jika:\n'
                    '- Diperlukan untuk operasional layanan (misalnya penyedia infrastruktur/server).\n'
                    '- Diwajibkan oleh hukum atau permintaan resmi dari pihak berwenang.\n\n'
                    '5. Notifikasi\n'
                    'Jika Anda mengaktifkan notifikasi, kami dapat mengirimkan informasi terkait pembaruan aplikasi, fitur, atau konten. Anda dapat mengelola notifikasi melalui pengaturan perangkat Anda.\n\n'
                    '6. Hak Pengguna\n'
                    'Anda berhak untuk:\n'
                    '- Mengakses informasi akun Anda.\n'
                    '- Memperbarui data akun (nama/email/nomor telepon jika tersedia).\n'
                    '- Meminta penghapusan akun (jika fitur tersedia).\n\n'
                    '7. Retensi Data\n'
                    'Kami menyimpan data selama akun Anda aktif atau selama diperlukan untuk menyediakan layanan. Setelah akun dihapus, data akan dihapus atau dianonimkan sesuai ketentuan yang berlaku.\n\n'
                    '8. Perubahan Kebijakan\n'
                    'Kebijakan ini dapat diperbarui sewaktu-waktu. Jika ada perubahan penting, kami akan menampilkan pemberitahuan di aplikasi.\n\n'
                    '9. Kontak\n'
                    'Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi kami melalui:\n'
                    'Email: support@jagomasak.com\n\n'
                    'Dengan menekan tombol “Saya Mengerti”, Anda menyatakan telah membaca dan memahami Kebijakan Privasi ini.\n'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Saya Mengerti'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
