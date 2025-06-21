import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About L.O.F.I')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headphones,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // App Name
              Text(
                'L.O.F.I',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // App Description
              const Text(
                'A lofi-themed educational app that rewards users for staying focused and not using their phone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Thank You Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Thank You!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thank you for using L.O.F.I - Learn. Organize. Focus. Improve. This app was created to help you stay focused and productive while enjoying lofi beats. Your support means a lot!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Links Section
              Text(
                'Connect & Contribute',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // GitHub Link
              _buildLinkCard(
                context: context,
                title: 'GitHub Profile',
                description: 'Check out my other projects',
                icon: Icons.code,
                onTap: () => _launchUrl('https://github.com/HokageM'),
              ),
              const SizedBox(height: 12),

              // Feature Requests Link
              _buildLinkCard(
                context: context,
                title: 'Feature Requests',
                description: 'Suggest new features or report bugs',
                icon: Icons.lightbulb,
                onTap: () =>
                    _launchUrl('https://github.com/L-I-B-R-E/L.I.B.R.E'),
              ),
              const SizedBox(height: 12),

              // YouTube Channel Link
              _buildLinkCard(
                context: context,
                title: 'YouTube Channel',
                description: 'Find more lofi beats for your focus sessions',
                icon: Icons.music_note,
                onTap: () =>
                    _launchUrl('https://www.youtube.com/@HokageBeats6'),
              ),

              const SizedBox(height: 32),

              // Version info
              Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '© 2025 LofiFocus',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
