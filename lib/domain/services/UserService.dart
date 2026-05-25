import 'package:flutter/material.dart';
import 'package:guardians/domain/repositories/i_user_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:guardians/domain/entities/user_entity.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// ** DTOs **

class RegisterUserDto{
  final String name;
  final String email;
  final String passwordHash;
  final String confirmPassword;

  const RegisterUserDto({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.confirmPassword,
  });
}

class LoginUserDto{
  final String email;
  final String passwordHash;

  const LoginUserDto({
    required this.email,
    required this.passwordHash,
  });
}

class UpdateUserDto{
  final String? name;
  final String? email;

  const UpdateUserDto({
    required this.name,
    required this.email,
  });
}


// ** EXCEÇÕES **

abstract class UserException implements Exception{
  final String message;
  const UserException(this.message);

  @override
  String toString() => message;
}

class EmailAlreadyInUseException extends UserException{
  const EmailAlreadyInUseException() :super('Este e-mail já está em uso. Tente outro ou faça login');
}

class UserNotFoundException extends UserException{
  const UserNotFoundException() :super ('Usuário não encontrado');
}

class InvalidCredentialsException extends UserException{
  const InvalidCredentialsException() :super ('E-mail ou senha incorretos');
}

class WeakPasswordException extends UserException{
  const WeakPasswordException(super.message);
}

class InvalidEmailException extends UserException{
  const InvalidEmailException() :super ('Formato do e-mail inválido');
}

class PasswordMissmatchException extends UserException{
  const PasswordMissmatchException() :super ('As senhas não coincidem');
}

class InvalidNameException extends UserException{
  const InvalidNameException(super.message);
}

class UnauthorizedException extends UserException{
  const UnauthorizedException() :super ('Você não tem permissão para realizar esta ação');
}


// ** VALIDAÇÕES **

class _UserValidator{
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  static void validateName(String name){
    final trimmed = name.trim();
    if(trimmed.length < 2){
      throw const InvalidNameException('O nome deve ter pelo menos 2 caracteres');
    }
    if(trimmed.length > 100){
      throw const InvalidNameException('O nome deve ter no máximo  100 caracters');
    }
  }

  static void validateEmail(String email){
    if(!_emailRegex.hasMatch(email.trim().toLowerCase())){
      throw const InvalidEmailException();
    }
  }

  static void validatePassword(String passwordHash){
    if(passwordHash.length < 8){
      throw const WeakPasswordException('A senha deve ter pelo menos 8 caracteres.');
    }
    if(!passwordHash.contains(RegExp(r'[A-Z]'))){
      throw const WeakPasswordException('A senha deve ter pelo menos uma letra maiúscula.');
    }
    if(!passwordHash.contains(RegExp(r'[a-z]'))){
      throw const WeakPasswordException('A senha deve ter pelo menos uma letra minúscula.');
    }
    if(!passwordHash.contains(RegExp(r'[0-9]'))){
      throw const WeakPasswordException('A senha deve ter pelo menos um número.');
    }
    if (!passwordHash.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
      throw const WeakPasswordException(
          r'A senha deve conter pelo menos um caractere especial (!@#$%^&*...).');
    }
  }

  static void validatePasswordMatch(String passwordHash, String confirmPassword){
    if(passwordHash != confirmPassword) throw const PasswordMissmatchException();
  }

  static void validateRegister(RegisterUserDto dto){
    validateName(dto.name);
    validateEmail(dto.email);
    validatePassword(dto.passwordHash);
    validatePasswordMatch(dto.passwordHash, dto.confirmPassword);
  }

  static void validateLogin(LoginUserDto dto){
    if(dto.email.trim().isEmpty) throw const InvalidEmailException();
    if(dto.passwordHash.isEmpty) throw const InvalidCredentialsException();
    validateEmail(dto.email);
  }

  static void validateUpdate(UpdateUserDto dto) {
    if (dto.name != null) validateName(dto.name!);
    if (dto.email != null) validateEmail(dto.email!);
  }

  static String? nameErrorMessage(String ? v){
    if(v == null || v.trim().isEmpty) return 'Nome obrigatório.';
    try{
      validateName(v);
      return null;
    } on InvalidNameException catch (e){
      return e.message;
    }
  }

  static String? emailErrorMessage(String? v) {
    if (v == null || v.trim().isEmpty) return 'E-mail obrigatório.';
    try {
      validateEmail(v);
      return null;
    } on InvalidEmailException catch (e) {
      return e.message;
    }
  }

  static String? passwordHashErrorMessage(String? v){
    if(v == null || v.isEmpty) return 'Senha obrigatória.';
    try{
      validatePassword(v);
      return null;
    } on WeakPasswordException catch (e){
      return e.message;
    }
  }

  static String? confirmPasswordErrorMessage(String? v, String passwordHash) {
    if (v == null || v.isEmpty) return 'Confirmação obrigatória.';
    try {
      validatePasswordMatch(passwordHash, v);
      return null;
    } on PasswordMissmatchException catch (e){
      return e.message;
    }
  }
}

// ** SERVICE **

class UserService{
  final i_user_repository _repository;
  final Uuid _uuid;

  UserService({required i_user_repository repository, Uuid? uuid})
    : _repository = repository,
      _uuid = uuid?? const Uuid();

  //Registrar novo usuário
  Future<void> register(RegisterUserDto dto) async {
    _UserValidator.validateRegister(dto);

    final email = dto.email.trim().toLowerCase();

    if(await _repository.emailExists(email)){
      throw const EmailAlreadyInUseException();
    }

    final user = UserEntity(
      id: _uuid.v4(),
      name: dto.name.trim(),
      email: email,
      passwordHash: _hash(dto.passwordHash),
      createdAt: DateTime.now(),
    );

    await _repository.create(user);
  }

  //Autenticar o usuário
  Future<UserEntity> login(LoginUserDto dto) async{
    _UserValidator.validateLogin(dto);

    final user = await _repository.findByEmail(dto.email.trim().toLowerCase());

    if (user == null) throw const InvalidCredentialsException();
    if (_hash(dto.passwordHash) != user.passwordHash) throw const InvalidCredentialsException();

    return user;
  }

  //Retornar usuário pela ID
  Future<UserEntity> getUserById(String id) async{
    final user = await _repository.findById(id);
    if (user == null) throw const UserNotFoundException();
    return user;
  }
  
   // Atualizar nome e/ou e-mail do usuário autenticado.
   Future<void> updateUser({
    required String requestingUserId,
    required String targetUserId,
    required UpdateUserDto dto,
   }) async {
      if(requestingUserId != targetUserId) throw const UnauthorizedException();
      if(dto.name == null && dto.email == null){
        throw const InvalidNameException("Nenhum campo para atualizar foi informado");
      }

      _UserValidator.validateUpdate(dto);

      final user = await _repository.findById(targetUserId);
      if (user == null) throw const UserNotFoundException();

      if(dto.email != null){
        final newEmail = dto.email!.trim().toLowerCase();
        if(newEmail != user.email && await _repository.emailExists(newEmail)){
          throw const EmailAlreadyInUseException();
        }
      }

      await _repository.update(
        user.copyWith(
          name:dto.name?.trim() ?? user.name,
          email:dto.email?.trim().toLowerCase() ?? user.email,
          updatedAt: DateTime.now(),
        ),
      );
   }
   
   //Deletar conta do usuário exigindo confirmação de senha.
   Future<void> deleteUser({
    required String requestingUserId,
    required String targetUserId,
    required String confirmationPassword,
   }) async {
    if (requestingUserId != targetUserId) throw const UnauthorizedException();

    final user  = await _repository.findById(targetUserId);
    if(user == null) throw const UserNotFoundException();
    if(_hash(confirmationPassword) != user.passwordHash) throw const InvalidCredentialsException();

    await _repository.delete(targetUserId);
   }

   //Validação de formulários
   static String? Function(String?) get nameValidator =>
      _UserValidator.nameErrorMessage;
 
  static String? Function(String?) get emailValidator =>
      _UserValidator.emailErrorMessage;
 
  static String? Function(String?) get passwordValidator =>
      _UserValidator.passwordHashErrorMessage;
 
  static String? Function(String?, String) get confirmPasswordValidator =>
      _UserValidator.confirmPasswordErrorMessage;

  //Criptografar a senha
String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();
}