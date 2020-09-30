import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  //1
  String vaccination;
  DateTime date;
  bool done;
  // 2
  DocumentReference reference;
  // 3
  // {}の中はoptionalで外は必須項目
  Vaccination(this.vaccination, {this.date, this.done, this.reference});
  // 4
  factory Vaccination.fromJson(Map<dynamic, dynamic> json) => _VaccinationFromJson(json);
  // 5
  Map<String, dynamic> toJson() => _VaccinationToJson(this);
  @override
  String toString() => "Vaccination<$vaccination>";
}

// 1
Vaccination _VaccinationFromJson(Map<dynamic, dynamic> json) {
  return Vaccination(
    json['vaccination'] as String,
    date: json['date'] == null ? null: (json['date'] as Timestamp).toDate(),
    done: json['done'] as bool,
  );
}

// 2
Map<String, dynamic> _VaccinationToJson(Vaccination instance) => <String, dynamic>{
  'vaccination': instance.vaccination,
  'date': instance.date,
  'done':instance.done,
};