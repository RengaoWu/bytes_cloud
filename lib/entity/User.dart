import 'package:bytes_cloud/entity/entitys.dart';
//
//class UserEntity extends Entity {
//  String account;
//  String password;
//
//  static const String tableName = 'UserEntity';
//  static getSQL() => '''
//            CREATE TABLE $tableName(
//            account TEXT PRIMARY KEY,
//            password INTEGER ,)
//  ''';
//
//  UserEntity(this.account, this.password) : super.fromMap(null);
//
//  UserEntity.fromMap(Map<String, dynamic> map) : super.fromMap(map) {
//    account = map['account'];
//    password = map['password'];
//  }
//
//  @override
//  Map<String, dynamic> toMap() {
//    return {'account': account, 'password': password};
//  }
//}
