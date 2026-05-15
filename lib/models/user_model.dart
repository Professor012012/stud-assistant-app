class UserModel {
  final String id;
  final String email;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? studentNumber;
  final String? yearOfStudy;
  final String? phone;
  final bool isDisabled;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.studentNumber,
    this.yearOfStudy,
    this.phone,
    this.isDisabled = false,
  });

  String get uid => id;
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'role': role,
        'first_name': firstName,
        'last_name': lastName,
        'student_number': studentNumber,
        'year_of_study': yearOfStudy,
        'phone': phone,
        'is_disabled': isDisabled,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      firstName: map['first_name'] ?? map['fullName']?.toString().split(' ').first,
      lastName: map['last_name'],
      studentNumber: map['student_number'] ?? map['studentNumber'],
      yearOfStudy: map['year_of_study'],
      phone: map['phone'],
      isDisabled: map['is_disabled'] == true || map['disabled'] == true,
    );
  }

  UserModel copyWith({
    String? fullName,
    String? studentNumber,
    String? email,
    String? yearOfStudy,
    String? phone,
    bool? isDisabled,
  }) {
    final parts = (fullName ?? this.fullName).trim().split(RegExp(r'\s+'));
    return UserModel(
      id: id,
      email: email ?? this.email,
      role: role,
      firstName: parts.isEmpty || parts.first.isEmpty ? firstName : parts.first,
      lastName: parts.length > 1 ? parts.skip(1).join(' ') : lastName,
      studentNumber: studentNumber ?? this.studentNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      phone: phone ?? this.phone,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }
}
