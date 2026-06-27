import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/top_toast.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.neutralColor,
            ),
          ),
          iconColor: AppTheme.primaryColor,
          collapsedIconColor: Colors.grey.shade500,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neutralColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: AppTheme.neutralColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PERTANYAAN POPULER (FAQ)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              'Bagaimana cara memindai makanan?',
              'Ketuk ikon Kamera di menu navigasi bawah. Arahkan kamera ke makanan Anda secara tegak lurus dan tekan tombol Shutter. Pilih menu makanan yang sesuai untuk mendapatkan detail analisis AI.',
            ),
            _buildFAQItem(
              'Apakah data makanan saya aman?',
              'Ya, data Anda sepenuhnya aman. Kami mengenkripsi seluruh rekam medis dan data asupan makanan harian Anda. Data tersebut hanya diolah oleh AI untuk memberikan rekomendasi nutrisi pribadi.',
            ),
            _buildFAQItem(
              'Bagaimana AI menghitung kalori makanan?',
              'AI mengidentifikasi komponen makanan berdasarkan citra visual, memperkirakan porsi standar, dan melakukan kalkulasi nilai kalori serta makronutrisi (karbohidrat, protein, lemak) menggunakan basis data gizi terpercaya.',
            ),
            _buildFAQItem(
              'Bisakah saya mencatat makanan secara manual?',
              'Tentu saja. Di tab Riwayat atau Beranda, Anda bisa menekan tombol "+" untuk menambahkan nama makanan, jumlah kalori, dan makronutrisi secara manual jika makanan Anda tidak terdeteksi oleh pemindai kamera.',
            ),
            const SizedBox(height: 24),
            const Text(
              'HUBUNGI KAMI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0FAF7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Punya Kendala Lain?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tim Customer Support Nutrify siap membantu menyelesaikan kendala teknis atau memberikan informasi gizi lainnya.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.teal.shade900,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showTopToast(context, 'Membuka aplikasi WhatsApp Support...'),
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: const Text('WhatsApp Chat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => showTopToast(context, 'Membuka aplikasi Email Client...'),
                          icon: const Icon(Icons.email_outlined, size: 18),
                          label: const Text('Kirim Email'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
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
