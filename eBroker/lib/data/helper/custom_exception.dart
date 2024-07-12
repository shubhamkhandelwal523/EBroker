class CustomException implements Exception {
  final dynamic _message;
  // ignore: unused_field
  final dynamic _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    return "$_message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException([message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class VerificationException extends CustomException {
  VerificationException([message])
      : super(message, "Please verify email first ");
}

class InvalidInputException extends CustomException {
  InvalidInputException([message]) : super(message, "Invalid Input: ");
}
