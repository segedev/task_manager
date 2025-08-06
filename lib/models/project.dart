import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'project.g.dart';

@HiveType(typeId: 1)
class Project extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String color;

  @HiveField(4)
  final String userId;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime updatedAt;

  @HiveField(7)
  final bool isArchived;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    color,
    userId,
    createdAt,
    updatedAt,
    isArchived,
  ];

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isArchived: json['isArchived'] ?? false,
    );
  }
}
