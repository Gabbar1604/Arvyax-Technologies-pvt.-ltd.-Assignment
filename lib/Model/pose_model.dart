class YogaSessionData {
  final Metadata metadata;
  final Assets assets;
  final List<SequenceItem> sequence;

  YogaSessionData({
    required this.metadata,
    required this.assets,
    required this.sequence,
  });

  factory YogaSessionData.fromJson(Map<String, dynamic> json) {
    return YogaSessionData(
      metadata: Metadata.fromJson(json['metadata']),
      assets: Assets.fromJson(json['assets']),
      sequence: (json['sequence'] as List)
          .map((item) => SequenceItem.fromJson(item))
          .toList(),
    );
  }

  // Convert to YogaPoses with improved loop handling
  List<YogaPose> toYogaPoses({int defaultLoopCount = 1}) {
    final List<YogaPose> poses = [];

    for (var seq in sequence) {
      if (seq.type == 'loop' && seq.loopable == true) {
        // Handle looped sequences - create individual poses for each loop
        int loops = seq.iterations != null
            ? _parseIterations(seq.iterations!, defaultLoopCount)
            : defaultLoopCount;

        for (int i = 0; i < loops; i++) {
          poses.add(_createLoopPose(seq, i + 1, loops));
        }
      } else {
        // Handle regular segments
        poses.add(_createRegularPose(seq));
      }
    }
    return poses;
  }

  YogaPose _createRegularPose(SequenceItem seq) {
    final List<PoseImage> poseImages = seq.script.map((scriptItem) {
      return PoseImage(
        path: 'assets/images/${assets.images[scriptItem.imageRef] ?? ''}',
        startSec: scriptItem.startSec,
        endSec: scriptItem.endSec,
        text: scriptItem.text,
      );
    }).toList();

    return YogaPose(
      name: seq.name,
      images: poseImages,
      audioPath: 'assets/audio/${assets.audio[seq.audioRef] ?? ''}',
      duration: seq.durationSec,
      isLoop: false,
    );
  }

  YogaPose _createLoopPose(SequenceItem seq, int currentLoop, int totalLoops) {
    // For loop poses, we need to adjust the timing to fit within the loop duration
    final List<PoseImage> poseImages = seq.script.map((scriptItem) {
      return PoseImage(
        path: 'assets/images/${assets.images[scriptItem.imageRef] ?? ''}',
        startSec: scriptItem.startSec,
        endSec: scriptItem.endSec,
        text: scriptItem.text,
      );
    }).toList();

    String poseName = '${seq.name} (Round $currentLoop/$totalLoops)';

    return YogaPose(
      name: poseName,
      images: poseImages,
      audioPath: 'assets/audio/${assets.audio[seq.audioRef] ?? ''}',
      duration: seq.durationSec,
      isLoop: true,
      loopIteration: currentLoop,
      totalLoops: totalLoops,
    );
  }

  int _parseIterations(String iterations, int defaultValue) {
    if (iterations.contains('{{loopCount}}')) {
      return metadata.defaultLoopCount;
    }
    return int.tryParse(iterations) ?? defaultValue;
  }
}

class Metadata {
  final String id;
  final String title;
  final String category;
  final int defaultLoopCount;
  final String tempo;

  Metadata({
    required this.id,
    required this.title,
    required this.category,
    required this.defaultLoopCount,
    required this.tempo,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      defaultLoopCount: json['defaultLoopCount'] ?? 1,
      tempo: json['tempo'] ?? 'medium',
    );
  }
}

class Assets {
  final Map<String, String> images;
  final Map<String, String> audio;

  Assets({required this.images, required this.audio});

  factory Assets.fromJson(Map<String, dynamic> json) {
    return Assets(
      images: Map<String, String>.from(json['images'] ?? {}),
      audio: Map<String, String>.from(json['audio'] ?? {}),
    );
  }
}

class SequenceItem {
  final String type;
  final String name;
  final String audioRef;
  final int durationSec;
  final List<ScriptItem> script;
  final String? iterations;
  final bool? loopable;

  SequenceItem({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    required this.script,
    this.iterations,
    this.loopable,
  });

  factory SequenceItem.fromJson(Map<String, dynamic> json) {
    return SequenceItem(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      audioRef: json['audioRef'] ?? '',
      durationSec: json['durationSec'] ?? 0,
      script: (json['script'] as List? ?? [])
          .map((item) => ScriptItem.fromJson(item))
          .toList(),
      iterations: json['iterations'],
      loopable: json['loopable'],
    );
  }
}

class ScriptItem {
  final String text;
  final int startSec;
  final int endSec;
  final String imageRef;

  ScriptItem({
    required this.text,
    required this.startSec,
    required this.endSec,
    required this.imageRef,
  });

  factory ScriptItem.fromJson(Map<String, dynamic> json) {
    return ScriptItem(
      text: json['text'] ?? '',
      startSec: json['startSec'] ?? 0,
      endSec: json['endSec'] ?? 0,
      imageRef: json['imageRef'] ?? '',
    );
  }
}

// Enhanced compatibility classes
class PoseImage {
  final String path;
  final int startSec;
  final int endSec;
  final String text;

  PoseImage({
    required this.path,
    required this.startSec,
    required this.endSec,
    required this.text,
  });
}

class YogaPose {
  final String name;
  final List<PoseImage> images;
  final String audioPath;
  final int duration;
  final bool isLoop;
  final int? loopIteration;
  final int? totalLoops;

  YogaPose({
    required this.name,
    required this.images,
    required this.audioPath,
    required this.duration,
    this.isLoop = false,
    this.loopIteration,
    this.totalLoops,
  });

  // Improved image selection for consistent display
  String getImagePathForTime(int elapsedSeconds) {
    if (images.isEmpty) {
      return '';
    }

    // For loop poses, we want more stable image transitions
    if (isLoop) {
      // Find the appropriate image based on timing, but prioritize stability
      final image = images.firstWhere(
        (img) => elapsedSeconds >= img.startSec && elapsedSeconds < img.endSec,
        orElse: () {
          // If no exact match, find the closest one
          if (elapsedSeconds < images.first.startSec) {
            return images.first;
          } else if (elapsedSeconds >= images.last.endSec) {
            return images.last;
          }
          // Find the image with the smallest gap
          return images.reduce((a, b) {
            final aGap = (elapsedSeconds - a.startSec).abs();
            final bGap = (elapsedSeconds - b.startSec).abs();
            return aGap < bGap ? a : b;
          });
        },
      );
      return image.path;
    }

    // For regular poses, use the standard logic
    final image = images.firstWhere(
      (img) => elapsedSeconds >= img.startSec && elapsedSeconds < img.endSec,
      orElse: () => images.first,
    );
    return image.path;
  }

  // Get the instruction text for the current time
  String getInstructionForTime(int elapsedSeconds) {
    if (images.isEmpty) {
      return '';
    }

    final image = images.firstWhere(
      (img) => elapsedSeconds >= img.startSec && elapsedSeconds < img.endSec,
      orElse: () => images.first,
    );
    return image.text;
  }

  // Get the current instruction segment based on elapsed time
  PoseImage? getCurrentSegment(int elapsedSeconds) {
    if (images.isEmpty) {
      return null;
    }

    return images.firstWhere(
      (img) => elapsedSeconds >= img.startSec && elapsedSeconds < img.endSec,
      orElse: () => images.first,
    );
  }
}

class YogaSession {
  final List<YogaPose> poses;
  final String? backgroundMusicPath;
  final String title;
  final String category;
  final String tempo;

  YogaSession({
    required this.poses,
    this.backgroundMusicPath,
    required this.title,
    this.category = '',
    this.tempo = 'medium',
  });

  int get totalDuration => poses.fold(0, (sum, pose) => sum + pose.duration);

  factory YogaSession.fromYogaSessionData(YogaSessionData data) {
    // Don't use background music for now to avoid audio conflicts
    String? bgMusicPath;

    // Only use background music if explicitly configured and all poses are loops
    final allLoops = data.sequence.every((seq) => seq.type == 'loop');
    if (allLoops && data.assets.audio.containsKey('background')) {
      bgMusicPath = 'assets/audio/${data.assets.audio['background']}';
    }

    return YogaSession(
      title: data.metadata.title,
      category: data.metadata.category,
      tempo: data.metadata.tempo,
      poses: data.toYogaPoses(defaultLoopCount: data.metadata.defaultLoopCount),
      backgroundMusicPath: bgMusicPath, // Set to null to avoid conflicts
    );
  }
}
