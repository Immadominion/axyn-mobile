import 'package:flutter/material.dart';

enum ActivityType { paymentReceived, withdrawal, merchantCreated }

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.tint,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color tint;
}
