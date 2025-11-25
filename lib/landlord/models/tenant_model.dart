class Tenant {
  final String? id;
  final String? tenantId;
  final String? name;
  final String? email;
  final String? aadhaar;
  final String? mobile;
  final String? permanentAddress;
  final String? work;
  final DateTime? dob;
  final String? maritalStatus;
  final String? fatherName;
  final String? fatherMobile;
  final String? motherName;
  final String? motherMobile;
  final String? photo;
  final List<Accommodation>? accommodations;
  final TenantStatus status;
  final DateTime? startDate;
  final double? monthlyRent;
  final double? deposit;
  final String? notes;
  final String? propertyId;
  final String? roomId;

  Tenant({
    this.id,
    this.tenantId,
    this.name,
    this.email,
    this.aadhaar,
    this.mobile,
    this.permanentAddress,
    this.work,
    this.dob,
    this.maritalStatus,
    this.fatherName,
    this.fatherMobile,
    this.motherName,
    this.motherMobile,
    this.photo,
    this.accommodations,
    this.status = TenantStatus.pending,
    this.startDate,
    this.monthlyRent,
    this.deposit,
    this.notes,
    this.propertyId,
    this.roomId,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    // Get active accommodation if exists
    Accommodation? activeAccommodation;
    if (json['accommodations'] != null && (json['accommodations'] as List).isNotEmpty) {
      try {
        activeAccommodation = (json['accommodations'] as List)
            .map((e) => Accommodation.fromJson(e))
            .firstWhere(
              (acc) => acc.isActive == true,
          orElse: () => Accommodation.fromJson((json['accommodations'] as List).first),
        );
      } catch (e) {
        // If no active accommodation, use first one
        if ((json['accommodations'] as List).isNotEmpty) {
          activeAccommodation = Accommodation.fromJson((json['accommodations'] as List).first);
        }
      }
    }

    return Tenant(
      id: json['_id']?.toString(),
      tenantId: json['tenantId']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      aadhaar: json['aadhaar']?.toString(),
      mobile: json['mobile']?.toString(),
      permanentAddress: json['permanentAddress']?.toString(),
      work: json['work']?.toString(),
      dob: json['dob'] != null ? DateTime.tryParse(json['dob'].toString()) : null,
      maritalStatus: json['maritalStatus']?.toString(),
      fatherName: json['fatherName']?.toString(),
      fatherMobile: json['fatherMobile']?.toString(),
      motherName: json['motherName']?.toString(),
      motherMobile: json['motherMobile']?.toString(),
      photo: json['photo']?.toString(),
      accommodations: json['accommodations'] != null
          ? (json['accommodations'] as List)
          .map((e) => Accommodation.fromJson(e))
          .toList()
          : null,
      status: activeAccommodation?.isActive == true
          ? TenantStatus.active
          : TenantStatus.inactive,
      startDate: activeAccommodation?.moveInDate,
      monthlyRent: activeAccommodation?.rentAmount,
      deposit: activeAccommodation?.securityDeposit,
      notes: activeAccommodation?.remarks,
      propertyId: activeAccommodation?.propertyId,
      roomId: activeAccommodation?.roomId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'tenantId': tenantId,
      'name': name,
      'email': email,
      'aadhaar': aadhaar,
      'mobile': mobile,
      'permanentAddress': permanentAddress,
      'work': work,
      'dob': dob?.toIso8601String(),
      'maritalStatus': maritalStatus,
      'fatherName': fatherName,
      'fatherMobile': fatherMobile,
      'motherName': motherName,
      'motherMobile': motherMobile,
      'photo': photo,
      'accommodations': accommodations?.map((e) => e.toJson()).toList(),
    };
  }
}

class Accommodation {
  final String? landlordId;
  final String? propertyId;
  final String? propertyName;
  final String? roomId;
  final String? bedId;
  final String? localTenantId;
  final DateTime? moveInDate;
  final DateTime? moveOutDate;
  final double? rentAmount;
  final double? securityDeposit;
  final double? pendingDues;
  final double? monthlyCollection;
  final bool? isActive;
  final String? securityDepositStatus;
  final double? securityDepositRefundAmount;
  final int? noticePeriod;
  final int? agreementPeriod;
  final String? agreementPeriodType;
  final int? rentOnDate;
  final String? rentDateOption;
  final String? rentalFrequency;
  final String? referredBy;
  final String? remarks;
  final String? bookedBy;
  final Electricity? electricity;
  final OpeningBalance? openingBalance;

  Accommodation({
    this.landlordId,
    this.propertyId,
    this.propertyName,
    this.roomId,
    this.bedId,
    this.localTenantId,
    this.moveInDate,
    this.moveOutDate,
    this.rentAmount,
    this.securityDeposit,
    this.pendingDues,
    this.monthlyCollection,
    this.isActive,
    this.securityDepositStatus,
    this.securityDepositRefundAmount,
    this.noticePeriod,
    this.agreementPeriod,
    this.agreementPeriodType,
    this.rentOnDate,
    this.rentDateOption,
    this.rentalFrequency,
    this.referredBy,
    this.remarks,
    this.bookedBy,
    this.electricity,
    this.openingBalance,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      landlordId: json['landlordId']?.toString(),
      propertyId: json['propertyId']?.toString(),
      propertyName: json['propertyName']?.toString(),
      roomId: json['roomId']?.toString(),
      bedId: json['bedId']?.toString(),
      localTenantId: json['localTenantId']?.toString(),
      moveInDate: json['moveInDate'] != null
          ? DateTime.tryParse(json['moveInDate'].toString())
          : null,
      moveOutDate: json['moveOutDate'] != null
          ? DateTime.tryParse(json['moveOutDate'].toString())
          : null,
      rentAmount: json['rentAmount'] != null
          ? double.tryParse(json['rentAmount'].toString())
          : null,
      securityDeposit: json['securityDeposit'] != null
          ? double.tryParse(json['securityDeposit'].toString())
          : null,
      pendingDues: json['pendingDues'] != null
          ? double.tryParse(json['pendingDues'].toString())
          : null,
      monthlyCollection: json['monthlyCollection'] != null
          ? double.tryParse(json['monthlyCollection'].toString())
          : null,
      isActive: json['isActive'] as bool?,
      securityDepositStatus: json['securityDepositStatus']?.toString(),
      securityDepositRefundAmount: json['securityDepositRefundAmount'] != null
          ? double.tryParse(json['securityDepositRefundAmount'].toString())
          : null,
      noticePeriod: json['noticePeriod'] as int?,
      agreementPeriod: json['agreementPeriod'] as int?,
      agreementPeriodType: json['agreementPeriodType']?.toString(),
      rentOnDate: json['rentOnDate'] as int?,
      rentDateOption: json['rentDateOption']?.toString(),
      rentalFrequency: json['rentalFrequency']?.toString(),
      referredBy: json['referredBy']?.toString(),
      remarks: json['remarks']?.toString(),
      bookedBy: json['bookedBy']?.toString(),
      electricity: json['electricity'] != null
          ? Electricity.fromJson(json['electricity'])
          : null,
      openingBalance: json['openingBalance'] != null
          ? OpeningBalance.fromJson(json['openingBalance'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'landlordId': landlordId,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'roomId': roomId,
      'bedId': bedId,
      'localTenantId': localTenantId,
      'moveInDate': moveInDate?.toIso8601String(),
      'moveOutDate': moveOutDate?.toIso8601String(),
      'rentAmount': rentAmount,
      'securityDeposit': securityDeposit,
      'pendingDues': pendingDues,
      'monthlyCollection': monthlyCollection,
      'isActive': isActive,
      'securityDepositStatus': securityDepositStatus,
      'securityDepositRefundAmount': securityDepositRefundAmount,
      'noticePeriod': noticePeriod,
      'agreementPeriod': agreementPeriod,
      'agreementPeriodType': agreementPeriodType,
      'rentOnDate': rentOnDate,
      'rentDateOption': rentDateOption,
      'rentalFrequency': rentalFrequency,
      'referredBy': referredBy,
      'remarks': remarks,
      'bookedBy': bookedBy,
      'electricity': electricity?.toJson(),
      'openingBalance': openingBalance?.toJson(),
    };
  }
}

class Electricity {
  final double? perUnit;
  final double? initialReading;
  final double? finalReading;
  final DateTime? initialReadingDate;
  final DateTime? finalReadingDate;
  final String? dueDescription;

  Electricity({
    this.perUnit,
    this.initialReading,
    this.finalReading,
    this.initialReadingDate,
    this.finalReadingDate,
    this.dueDescription,
  });

  factory Electricity.fromJson(Map<String, dynamic> json) {
    return Electricity(
      perUnit: json['perUnit'] != null
          ? double.tryParse(json['perUnit'].toString())
          : null,
      initialReading: json['initialReading'] != null
          ? double.tryParse(json['initialReading'].toString())
          : null,
      finalReading: json['finalReading'] != null
          ? double.tryParse(json['finalReading'].toString())
          : null,
      initialReadingDate: json['initialReadingDate'] != null
          ? DateTime.tryParse(json['initialReadingDate'].toString())
          : null,
      finalReadingDate: json['finalReadingDate'] != null
          ? DateTime.tryParse(json['finalReadingDate'].toString())
          : null,
      dueDescription: json['dueDescription']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'perUnit': perUnit,
      'initialReading': initialReading,
      'finalReading': finalReading,
      'initialReadingDate': initialReadingDate?.toIso8601String(),
      'finalReadingDate': finalReadingDate?.toIso8601String(),
      'dueDescription': dueDescription,
    };
  }
}

class OpeningBalance {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? amount;

  OpeningBalance({
    this.startDate,
    this.endDate,
    this.amount,
  });

  factory OpeningBalance.fromJson(Map<String, dynamic> json) {
    return OpeningBalance(
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'amount': amount,
    };
  }
}

enum TenantStatus {
  active,
  pending,
  inactive;

  String get displayName {
    switch (this) {
      case TenantStatus.active:
        return 'Active';
      case TenantStatus.pending:
        return 'Pending';
      case TenantStatus.inactive:
        return 'Inactive';
    }
  }
}