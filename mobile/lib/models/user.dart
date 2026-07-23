class UserModel {
  final String id;
  final String uid;
  final String name;
  final String phone;
  final String qrData;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.phone,
    required this.qrData,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      qrData: json['qrData'] ?? 'tel:${json['phone'] ?? ''}',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'uid': uid,
      'name': name,
      'phone': phone,
      'qrData': qrData,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? phone,
    String? qrData,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      qrData: qrData ?? this.qrData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
