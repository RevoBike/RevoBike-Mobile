import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool? isVerified; // Added isVerified field, made nullable for safety

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isVerified, // Add to constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String, // CORRECTED: Use 'id' instead of '_id'
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool?, // Safely cast to nullable bool
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id, // Use 'id' consistently for toJson if backend expects it
      'name': name,
      'email': email,
      'role': role,
    };
    if (isVerified != null) {
      data['isVerified'] = isVerified;
    }
    return data;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        role,
        isVerified, // Include in props for Equatable
      ];
}
