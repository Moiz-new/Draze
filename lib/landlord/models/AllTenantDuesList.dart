class DuesResponse {
  final Landlord? landlord;
  final List<TenantDue>? tenants;

  DuesResponse({this.landlord, this.tenants});

  factory DuesResponse.fromJson(Map<String, dynamic> json) {
    return DuesResponse(
      landlord: json['landlord'] != null
          ? Landlord.fromJson(json['landlord'])
          : null,
      tenants: json['tenants'] != null
          ? (json['tenants'] as List)
          .map((tenant) => TenantDue.fromJson(tenant))
          .toList()
          : null,
    );
  }
}

class Landlord {
  final String? id;
  final String? name;
  final String? email;

  Landlord({this.id, this.name, this.email});

  factory Landlord.fromJson(Map<String, dynamic> json) {
    return Landlord(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class TenantDue {
  final Tenant? tenant;
  final double? totalAmount;
  final List<Due>? dues;

  TenantDue({this.tenant, this.totalAmount, this.dues});

  factory TenantDue.fromJson(Map<String, dynamic> json) {
    return TenantDue(
      tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null,
      totalAmount: json['totalAmount']?.toDouble(),
      dues: json['dues'] != null
          ? (json['dues'] as List).map((due) => Due.fromJson(due)).toList()
          : null,
    );
  }
}

class Tenant {
  final String? id;
  final String? name;
  final String? email;

  Tenant({this.id, this.name, this.email});

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class Due {
  final String? name;
  final double? amount;
  final String? status;
  final DateTime? dueDate;

  Due({this.name, this.amount, this.status, this.dueDate});

  factory Due.fromJson(Map<String, dynamic> json) {
    return Due(
      name: json['name'],
      amount: json['amount']?.toDouble(),
      status: json['status'],
      dueDate:
      json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}