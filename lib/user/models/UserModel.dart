class User {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final Address address;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.address,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      userName: json['userName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      role: json['role'] ?? '',
    );
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  String get fullAddress {
    return '$street, $city, $state $postalCode, $country';
  }
}