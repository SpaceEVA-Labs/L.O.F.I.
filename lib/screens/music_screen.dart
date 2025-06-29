import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({Key? key}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioService _audioService = AudioService();
  String? _currentTrack;
  double _volume = 0.5;
  bool _isPlaying = false;
  final List<String> _tracks = [
    'None',
    'Space Café.mp3',
    'Pharaohs Horizon.mp3',
    'Homunculi.mp3',
    'Pulse.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentTrack = prefs.getString('selectedTrack') ?? 'None';
        _volume = prefs.getDouble('volume') ?? 0.5;
        _isPlaying = _currentTrack != 'None';
      });

      await _audioService.initialize();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTrack', _currentTrack ?? 'None');
    await prefs.setDouble('volume', _volume);
  }

  Future<void> _selectTrack(String track) async {
    try {
      setState(() {
        _currentTrack = track;
        _isPlaying = track != 'None';
      });

      await _audioService.playTrack(track, _volume);
      _saveSettings();
    } catch (e) {
      print('Error selecting track: $e');
    }
  }

  Future<void> _setVolume(double volume) async {
    setState(() {
      _volume = volume;
    });
    await _audioService.setVolume(volume);
    _saveSettings();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Music icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.music_note,
                  size: 50,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Track selection
            Text(
              'Select Background Music',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Track options
            ..._tracks.map((track) => _buildTrackOption(track)),

            const SizedBox(height: 32),

            // Volume control
            Text(
              'Volume',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.volume_down, color: Theme.of(context).primaryColor),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    activeColor: Theme.of(context).primaryColor,
                    onChanged: _setVolume,
                  ),
                ),
                Icon(Icons.volume_up, color: Theme.of(context).primaryColor),
              ],
            ),

            const Spacer(),

            // YouTube link
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.music_note),
                label: const Text('More lofi beats on my YouTube Channel'),
                onPressed: () =>
                    _launchUrl('https://www.youtube.com/@HokageBeats6'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackOption(String track) {
    final bool isSelected = _currentTrack == track;
    final String displayName = track == 'None' ? 'No Music' : track;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _selectTrack(track),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              const SizedBox(width: 16),
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
              ),
              const Spacer(),
              if (track != 'None') Icon(Icons.music_note, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
