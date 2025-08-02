import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:yoga_session_app/Model/pose_model.dart';
import 'package:yoga_session_app/Screens/session_services.dart';

class SessionPreviewScreen extends StatefulWidget {
  final String? jsonFileName;
  const SessionPreviewScreen({super.key, this.jsonFileName});

  @override
  State<SessionPreviewScreen> createState() => _SessionPreviewScreenState();
}

class _SessionPreviewScreenState extends State<SessionPreviewScreen> {
  YogaSession? _session;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final String fileName = widget.jsonFileName ?? 'CatCowJson.json';
      final String jsonString = await rootBundle.loadString(
        'assets/data/$fileName',
      );

      if (jsonString.isEmpty) {
        throw Exception('$fileName file is empty');
      }

      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final sessionData = YogaSessionData.fromJson(jsonData);
      final session = YogaSession.fromYogaSessionData(sessionData);

      if (session.poses.isEmpty) {
        throw Exception('No poses found in session');
      }

      setState(() {
        _session = session;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load session: ${e.toString()}';
        _isLoading = false;
        _session = null;
      });
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  String _getCategoryDisplay(String category) {
    switch (category.toLowerCase()) {
      case 'spinal_mobility':
        return 'Spinal Mobility';
      case 'flexibility':
        return 'Flexibility';
      case 'strength':
        return 'Strength';
      default:
        return category.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9CB49F), Color(0xFFF5F9F5)],
            ),
          ),
          child: SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7C9885)),
                  )
                : _error != null
                ? _buildErrorContent()
                : _buildPreviewContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Color(0xFF7C9885), size: 64),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _error!,
              style: const TextStyle(color: Color(0xFF5A6B5D), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8F5E8),
              foregroundColor: const Color(0xFF7C9885),
            ),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Make sure your assets are properly configured and the JSON file exists in assets/data/',
              style: TextStyle(color: Color(0xFF5A6B5D), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_session == null) {
      return _buildErrorContent();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Lottie.asset(
                'assets/Animation/Yoga Se Hi hoga.json',
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.2,
                fit: BoxFit.fill,
              ),
              const SizedBox(height: 8),
              Text(
                _session!.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D4A32),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                _getCategoryDisplay(_session!.category),
                style: const TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF5A6B5D),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_session!.poses.length} poses • ${_formatDuration(_session!.totalDuration)}',
                style: const TextStyle(fontSize: 18, color: Color(0xFF5A6B5D)),
              ),
              if (_session!.tempo.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C9885).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _session!.tempo.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF2D4A32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: const Color(0xFFF5F9F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Session Preview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A5ACD),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _session!.poses.length,
                    itemBuilder: (context, index) {
                      final pose = _session!.poses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A5ACD).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: pose.images.isNotEmpty
                                      ? Image.asset(
                                          pose.images.first.path,
                                          fit: BoxFit.fill,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.self_improvement,
                                                  color: Color(0xFF6A5ACD),
                                                  size: 30,
                                                );
                                              },
                                        )
                                      : const Icon(
                                          Icons.self_improvement,
                                          color: Color(0xFF6A5ACD),
                                          size: 30,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            pose.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pose.duration} seconds',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (pose.images.isNotEmpty &&
                                  pose.images.first.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    pose.images.first.text,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: const Color(0xFF7C9885),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: const Color(0xFFF5F9F5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                YogaSessionScreen(session: _session!),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C9885),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Start Session',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF5F9F5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
