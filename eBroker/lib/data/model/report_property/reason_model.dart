class ReportReason {
  final int id;
  final String reason;

  ReportReason({required this.id, required this.reason});

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'reason': this.reason,
    };
  }

  factory ReportReason.fromMap(Map<String, dynamic> map) {
    return ReportReason(
      id: map['id'] as int,
      reason: map['reason'] as String,
    );
  }
}
