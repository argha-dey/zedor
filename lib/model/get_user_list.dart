import 'dart:convert';

class GetUserListModel {
  String? phone_number;
  String? name;
  String? addStatus;

  GetUserListModel({
    this.phone_number,
    this.name,
    this.addStatus,
  });

  GetUserListModel.fromJson(Map<String, dynamic> json) {
    phone_number = json['phone_number'];
    name = json['name'];
    addStatus = json['addStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone_number'] = this.phone_number;
    data['name'] = this.name;
    data['addStatus'] = this.addStatus;

    return data;
  }

  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'phone_number': phone_number,
      'name': name,
      'addStatus': addStatus,
    };
  }

  factory GetUserListModel.fromMap(Map<String, dynamic> map) {
    return GetUserListModel(
      name: map['name'] ?? '',
      phone_number: map['phone_number'] ?? '',
      addStatus: map['addStatus']?.toInt() ?? '0',
    );
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'GetUserListModel(name: $name, phone_number: $phone_number, addStatus: $addStatus)';
  }
}
