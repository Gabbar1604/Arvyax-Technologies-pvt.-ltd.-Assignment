import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:yoga_session_app/Model/pose_model.dart';

class YogaSessionScreen extends StatefulWidget {
  final YogaSession session;

  const YogaSessionScreen({super.key, required this.session});

  @override
  State<YogaSessionScreen> createState() => _YogaSessionScreenState();
}

class _YogaSessionScreenState extends State<YogaSessionScreen>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;

  // Current state
  int _currentPoseIndex = 0;
  bool _isPaused = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  // Current segment state
  int _currentSegmentIndex = 0;
  String _currentImagePath = '';
  String _currentInstruction = '';

  // Audio tracking
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _audioLoaded = false;

  // Lifecycle state
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _setupAudioListeners();
    _startCurrentPose();
  }

  // Improved lifecycle management
  @override
  void dispose() {
    print('Disposing YogaSessionScreen - stopping all audio and timers');
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    _audioPlayer
        .stop()
        .then((_) {
          _audioPlayer.dispose();
        })
        .catchError((error) {
          print('Error stopping audio during dispose: $error');
          _audioPlayer.dispose();
        });
    super.dispose();
  }

  // App lifecycle management
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        print('App going to background - pausing audio');
        if (!_isPaused) {
          _togglePlayPause(); // This will pause the session
        }
        break;
      case AppLifecycleState.resumed:
        print('App resumed from background');
        // Don't auto-resume, let user decide
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  // Start the current pose and initialize content
  void _setupAudioListeners() {
    // Track audio completion
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed && !_isPaused) {
        print('Audio completed, moving to next pose');
        _nextPose();
      }
    });

    // Track audio duration
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _audioDuration = duration;
        _audioLoaded = true;
      });
      print('Audio duration: ${duration.inSeconds}s');
    });

    // Track audio position for content updates (more frequent updates)
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _audioPosition = position;
      });

      // Only update content every 0.5 seconds to avoid too frequent changes
      if (position.inMilliseconds % 500 < 100) {
        _updateContentBasedOnAudio();
      }
    });
  }

  YogaPose get _currentPose => widget.session.poses[_currentPoseIndex];

  void _startCurrentPose() async {
    if (_currentPoseIndex >= widget.session.poses.length) {
      _completeSession();
      return;
    }

    _timer?.cancel();
    _elapsedSeconds = 0;
    _currentSegmentIndex = 0;
    _audioLoaded = false;

    final pose = _currentPose;
    print('Starting pose: ${pose.name}');

    // Set initial content (first segment)
    _setInitialContent();

    // Play audio
    await _playPoseAudio();

    // Start fallback timer (only for safety)
    _startFallbackTimer();
  }

  void _setInitialContent() {
    final pose = _currentPose;
    if (pose.images.isNotEmpty) {
      final firstSegment = pose.images.first;
      setState(() {
        _currentImagePath = firstSegment.path;
        _currentInstruction = firstSegment.text;
        _currentSegmentIndex = 0;
      });
    }
  }

  Future<void> _playPoseAudio() async {
    final pose = _currentPose;
    if (pose.audioPath.isEmpty) return;

    try {
      await _audioPlayer.stop();

      // Clean path and fix case issues
      String audioFile = pose.audioPath;
      if (audioFile.startsWith('assets/audio/')) {
        audioFile = audioFile.substring(13);
      }

      // Fix known case issues
      if (audioFile == 'cat_cow_intro.mp3') {
        audioFile = 'cat_cow_Intro.mp3';
      }

      print('Playing audio: $audioFile');
      await _audioPlayer.play(AssetSource('audio/$audioFile'));
    } catch (e) {
      print('Audio error: $e');
      // If audio fails, use timer-based approach
      _startTimerBasedSession();
    }
  }

  void _updateContentBasedOnAudio() {
    final pose = _currentPose;
    if (pose.images.isEmpty || !_audioLoaded) return;

    final audioSeconds = _audioPosition.inSeconds;

    // Calculate the actual timing based on audio duration vs JSON duration
    final jsonDuration = pose.duration;
    final audioDuration = _audioDuration.inSeconds;

    // If audio duration is different from JSON, scale the timing
    double timeScale = 1.0;
    if (audioDuration > 0 && jsonDuration > 0) {
      timeScale = audioDuration / jsonDuration;
    }

    // Find appropriate segment based on scaled audio position
    for (int i = 0; i < pose.images.length; i++) {
      final segment = pose.images[i];

      // Scale the segment timings to match actual audio length
      final scaledStartSec = (segment.startSec * timeScale).round();
      final scaledEndSec = (segment.endSec * timeScale).round();

      if (audioSeconds >= scaledStartSec && audioSeconds < scaledEndSec) {
        // Only update if segment actually changed and we're in the right time window
        if (i != _currentSegmentIndex) {
          setState(() {
            _currentSegmentIndex = i;
            _currentImagePath = segment.path;
            _currentInstruction = segment.text;
          });

          print(
            'Audio-sync update at ${audioSeconds}s (scaled from ${segment.startSec}s): Segment ${i + 1} - ${segment.text}',
          );
        }
        return; // Exit once we find the right segment
      }
    }

    // If no exact match found, keep current content (don't change randomly)
    print(
      'Audio at ${audioSeconds}s - keeping current segment ${_currentSegmentIndex + 1}',
    );
  }

  void _startFallbackTimer() {
    // This timer is only for safety if audio doesn't work
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) {
        timer.cancel();
        return;
      }

      _elapsedSeconds++;

      // Only use timer if audio is not working
      if (!_audioLoaded) {
        _updateContentBasedOnTimer();
      }

      // Safety check for pose completion (in case audio doesn't trigger)
      if (_elapsedSeconds >= _currentPose.duration + 5) {
        print('Safety timer triggered - moving to next pose');
        timer.cancel();
        _nextPose();
      }
    });
  }

  void _updateContentBasedOnTimer() {
    final pose = _currentPose;
    if (pose.images.isEmpty) return;

    // Find segment based on elapsed time (fallback method)
    for (int i = 0; i < pose.images.length; i++) {
      final segment = pose.images[i];

      if (_elapsedSeconds >= segment.startSec &&
          _elapsedSeconds < segment.endSec) {
        if (i != _currentSegmentIndex) {
          setState(() {
            _currentSegmentIndex = i;
            _currentImagePath = segment.path;
            _currentInstruction = segment.text;
          });

          print(
            'Timer-driven update at ${_elapsedSeconds}s: Segment ${i + 1} - ${segment.text}',
          );
        }
        break;
      }
    }
  }

  void _startTimerBasedSession() {
    // Fallback method if audio completely fails
    print('Starting timer-based session (audio failed)');

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) {
        timer.cancel();
        return;
      }

      setState(() {
        _elapsedSeconds++;
      });

      _updateContentBasedOnTimer();

      // Check if pose is complete
      if (_elapsedSeconds >= _currentPose.duration) {
        timer.cancel();
        _nextPose();
      }
    });
  }

  void _nextPose() {
    if (_currentPoseIndex < widget.session.poses.length - 1) {
      _currentPoseIndex++;
      _startCurrentPose();
    } else {
      _completeSession();
    }
  }

  void _previousPose() {
    if (_currentPoseIndex > 0) {
      _currentPoseIndex--;
      _startCurrentPose();
    }
  }

  void _togglePlayPause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      _timer?.cancel();
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
      _startFallbackTimer();
    }
  }

  void _completeSession() {
    _timer?.cancel();
    _audioPlayer.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete!'),
        content: const Text(
          'Congratulations! You completed your yoga session.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF2D4A32),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Finish',
              style: TextStyle(
                color: Color(0xFF7C9885),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pose = _currentPose;
    final totalDuration = _audioLoaded
        ? _audioDuration.inSeconds
        : pose.duration;
    final currentPosition = _audioLoaded
        ? _audioPosition.inSeconds
        : _elapsedSeconds;
    final remainingSeconds = totalDuration - currentPosition;
    final progress = totalDuration > 0 ? currentPosition / totalDuration : 0.0;

    return WillPopScope(
      onWillPop: () async {
        print('Back button pressed - stopping session');
        _timer?.cancel();
        _timer = null;
        try {
          await _audioPlayer.stop();
        } catch (e) {
          print('Error stopping audio: $e');
        }
        return true;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                colors: [Color(0xFF7C9885), Color(0xFFB8CDB8)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                print(
                                  'Close button pressed - stopping session',
                                );
                                _timer?.cancel();
                                _timer = null;
                                _audioPlayer.stop().catchError((error) {
                                  print('Error stopping audio: $error');
                                });
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.close,
                                color: Color(0xFFF5F9F5),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${_currentPoseIndex + 1} of ${widget.session.poses.length}',
                                  style: const TextStyle(
                                    color: Color(0xFFF5F9F5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Segment ${_currentSegmentIndex + 1}/${pose.images.length}',
                                  style: const TextStyle(
                                    color: Color(0xFFE8F5E8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              _audioLoaded ? Icons.volume_up : Icons.timer,
                              color: Color(0xFFE8F5E8),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Color(0xFFF5F9F5).withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2D4A32),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Image
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F9F5),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF2D4A32).withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _currentImagePath.isNotEmpty
                            ? Image.asset(
                                _currentImagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.self_improvement,
                                      size: 100,
                                      color: Color(0xFF7C9885),
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Icon(
                                  Icons.self_improvement,
                                  size: 100,
                                  color: Color(0xFF7C9885),
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Content
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Pose name
                          Text(
                            pose.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF5F9F5),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          // Instruction
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F9F5).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  _currentInstruction.isNotEmpty
                                      ? _currentInstruction
                                      : 'Follow the pose shown above',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFFF5F9F5),
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Timer
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFF5F9F5).withOpacity(0.4),
                                width: 3,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: CircularProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      strokeWidth: 4,
                                      backgroundColor: Color(
                                        0xFFF5F9F5,
                                      ).withOpacity(0.3),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFF5F9F5),
                                          ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${remainingSeconds.clamp(0, double.infinity).toInt()}',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF5F9F5),
                                        ),
                                      ),
                                      const Text(
                                        'seconds',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFE8F5E8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Previous
                              IconButton(
                                onPressed: _currentPoseIndex > 0
                                    ? _previousPose
                                    : null,
                                icon: Icon(
                                  Icons.skip_previous,
                                  color: _currentPoseIndex > 0
                                      ? Color(0xFFF5F9F5)
                                      : Color(0xFFF5F9F5).withOpacity(0.5),
                                  size: 36,
                                ),
                              ),

                              // Play/Pause
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF5F9F5),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: _togglePlayPause,
                                  icon: Icon(
                                    _isPaused ? Icons.play_arrow : Icons.pause,
                                    color: const Color(0xFF7C9885),
                                    size: 36,
                                  ),
                                ),
                              ),

                              // Next
                              IconButton(
                                onPressed: _nextPose,
                                icon: const Icon(
                                  Icons.skip_next,
                                  color: Color(0xFFF5F9F5),
                                  size: 36,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
