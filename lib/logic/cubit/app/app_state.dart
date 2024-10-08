// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_cubit.dart';

class AuthError extends AppState {
  final String message;

  AuthError(this.message);
}

class AuthInitial extends AppState {}

class AuthLoading extends AppState {}

@immutable
abstract class AppState {}

class IsNewUser extends AppState {
  final OAuthCredential credential;
  IsNewUser({
    required this.credential,
  });
}

class ResetPasswordSent extends AppState {}

class UserNotVerified extends AppState {}

class UserSignedOut extends AppState {}

class UserSignIn extends AppState {}

class UserSignupButNotVerified extends AppState {}