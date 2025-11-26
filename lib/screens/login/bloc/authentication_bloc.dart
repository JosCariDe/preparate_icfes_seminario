import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user_model.dart';
import '../../../repositories/auth_repository.dart';

// Events
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();
  @override
  List<Object> get props => [];
}

class AuthenticationSubscriptionRequested extends AuthenticationEvent {}

class AuthenticationLogoutRequested extends AuthenticationEvent {}

// State
enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final User? user;

  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user,
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated(User user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}

// Bloc
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthRepository _authRepository;

  AuthenticationBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthenticationState.unknown()) {
    on<AuthenticationSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onSubscriptionRequested(
    AuthenticationSubscriptionRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      final user = await _authRepository.checkAuthStatus();
      if (user != null) {
        emit(AuthenticationState.authenticated(user));
      } else {
        emit(const AuthenticationState.unauthenticated());
      }
    } catch (_) {
      emit(const AuthenticationState.unauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthenticationState.unauthenticated());
  }
}
