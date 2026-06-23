class AppFailure implements Exception {
  AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class DatabaseFailure extends AppFailure {
  DatabaseFailure(super.message);
}

class ValidationFailure extends AppFailure {
  ValidationFailure(super.message);
}

class NotFoundFailure extends AppFailure {
  NotFoundFailure(super.message);
}
