class Result<T> {
  final T? value;
  final Failure? failure;

  const Result._({this.value, this.failure});

  bool get isOk => failure == null;
  bool get isError => failure != null;

  factory Result.ok(T value) => Result._(value: value);
  factory Result.err(Failure failure) => Result._(failure: failure);
}

class Failure {
  final String message;
  final Object? exception;

  Failure(this.message, {this.exception});

  @override
  String toString() => 'Failure(message: $message, exception: $exception)';
}
