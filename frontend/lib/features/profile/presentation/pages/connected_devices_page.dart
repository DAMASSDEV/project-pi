import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  final Map<String, String> _deviceStatus = {
    'Apple Watch Series 9': 'disconnected',
    'Mi Smart Band 8': 'disconnected',
    'Samsung Galaxy Watch 6': 'disconnected',
  };

  final Map<String, bool> _deviceLoading = {
    'Apple Watch Series 9': false,
    'Mi Smart Band 8': false,
    'Samsung Galaxy Watch 6': false,
  };

  void _toggleDevice(String deviceName) {
    final status = _deviceStatus[deviceName];
    if (status == 'connected') {
      setState(() {
        _deviceStatus[deviceName] = 'disconnected';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deviceName berhasil diputuskan.'),
          backgroundColor: Colors.grey.shade800,
        ),
      );
    } else {
      setState(() {
        _deviceLoading[deviceName] = true;
      });

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _deviceLoading[deviceName] = false;
            _deviceStatus[deviceName] = 'connected';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$deviceName berhasil dihubungkan!'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
      });
    }
  }

  Widget _buildDeviceCard({
    required String name,
    required String brand,
    required IconData icon,
  }) {
    final status = _deviceStatus[name];
    final isLoading = _deviceLoading[name] ?? false;
    final isConnected = status == 'connected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isConnected ? AppTheme.primaryColor.withOpacity(0.3) : Colors.grey.shade100),
        boxShadow: isConnected
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isConnected ? AppTheme.secondaryColor : const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isConnected ? AppTheme.primaryColor : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutralColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isConnected ? 'Sinkronisasi Aktif' : 'Belum Terhubung',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
                    color: isConnected ? AppTheme.primaryColor : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 36,
            child: isLoading
                ? const SizedBox(
                    width: 36,
                    height: 36,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _toggleDevice(name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected ? Colors.grey.shade100 : AppTheme.primaryColor,
                      foregroundColor: isConnected ? Colors.redAccent : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Text(
                      isConnected ? 'Putus' : 'Hubungkan',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
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
          'Connected Devices',
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
              'SINKRONISASI AKTIVITAS HARI INI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungkan perangkat wearable Anda agar kalori aktivitas harian tersinkronisasi secara otomatis dengan target harian Nutrify.',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildDeviceCard(
              name: 'Apple Watch Series 9',
              brand: 'Apple',
              icon: Icons.watch_rounded,
            ),
            _buildDeviceCard(
              name: 'Mi Smart Band 8',
              brand: 'Xiaomi',
              icon: Icons.watch_rounded,
            ),
            _buildDeviceCard(
              name: 'Samsung Galaxy Watch 6',
              brand: 'Samsung',
              icon: Icons.watch_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
