import 'package:guardians/domain/entities/user_entity.dart';

abstract interface class i_user_repository{
  Future <void> create(UserEntity user);
  Future<UserEntity?> findById(String id);
  Future<void> update(UserEntity vault);
  Future<void> delete(String id);
  Future<UserEntity?> findByEmail(String email);  
  Future<bool> emailExists(String email);          

}