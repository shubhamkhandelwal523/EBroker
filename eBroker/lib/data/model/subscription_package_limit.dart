// ignore_for_file: public_member_api_docs, sort_constructors_first
// To parse this JSON data, do
//
//     final subcriptionPackageLimit = subcriptionPackageLimitFromMap(jsonString);

class SubcriptionPackageLimit {
  final bool error;
  final String message;
  final bool hasPackage;
  final bool isPremium;

  const SubcriptionPackageLimit({
    required this.error,
    required this.isPremium,
    required this.message,
    required this.hasPackage,
  });

  Map<String, dynamic> toMap() {
    return {
      'error': error,
      'message': message,
      'package': hasPackage,
      'isPremium': isPremium
    };
  }

  factory SubcriptionPackageLimit.fromMap(Map<String, dynamic> map) {
    return SubcriptionPackageLimit(
      error: map['error'] as bool,
      message: map['message'] as String,
      hasPackage: map['package'] as bool,
      isPremium: map['is_premium'] as bool,
    );
  }
}

//*{
//     "error": false,
//     "message": "User able to upload",
//     "package": true
// }
