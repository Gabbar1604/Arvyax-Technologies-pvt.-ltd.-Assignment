import 'package:flutter/material.dart';

class SessionCatalog {
  final String version;
  final String lastUpdated;
  final List<SessionMetadata> sessions;

  SessionCatalog({
    required this.version,
    required this.lastUpdated,
    required this.sessions,
  });

  factory SessionCatalog.fromJson(Map<String, dynamic> json) {
    final catalogData = json['catalog'] as Map<String, dynamic>;
    return SessionCatalog(
      version: catalogData['version'] ?? '1.0',
      lastUpdated: catalogData['lastUpdated'] ?? '',
      sessions: (catalogData['sessions'] as List? ?? [])
          .map((session) => SessionMetadata.fromJson(session))
          .toList(),
    );
  }

  // Get only active sessions
  List<SessionMetadata> get activeSessions =>
      sessions.where((session) => session.isActive).toList();

  // Get sessions by category
  List<SessionMetadata> getSessionsByCategory(String category) =>
      activeSessions.where((session) => session.category == category).toList();

  // Get sessions by difficulty
  List<SessionMetadata> getSessionsByDifficulty(String difficulty) =>
      activeSessions
          .where((session) => session.difficulty == difficulty)
          .toList();
}

class SessionMetadata {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final int duration;
  final String description;
  final String thumbnail;
  final String jsonFile;
  final List<String> tags;
  final String instructor;
  final bool isActive;

  SessionMetadata({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.description,
    required this.thumbnail,
    required this.jsonFile,
    required this.tags,
    required this.instructor,
    required this.isActive,
  });

  factory SessionMetadata.fromJson(Map<String, dynamic> json) {
    return SessionMetadata(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'beginner',
      duration: json['duration'] ?? 0,
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      jsonFile: json['jsonFile'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      instructor: json['instructor'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  // Format duration for display
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  // Get difficulty color
  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
