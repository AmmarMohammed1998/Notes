import 'package:notes/database/constant.dart';

class UserModel {
  final int? id;
  final String? title;
  final String? note;

  const UserModel({
    this.id,
    this.title,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    columnID: id,
    columnTitle: title,
    columnNote: note,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[columnID],
      title: map[columnTitle],
      note: map[columnNote],
    );
  }
}
