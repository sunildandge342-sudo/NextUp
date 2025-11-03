class TokenModel {
  final int tokenId;
  final String serviceName;
  final int tokenNumber;
  final String status; // e.g., "WAITING", "SERVED", "CANCELLED"
  final int position;
  final String estimatedTime;

  TokenModel({
    required this.tokenId,
    required this.serviceName,
    required this.tokenNumber,
    required this.status,
    required this.position,
    required this.estimatedTime,
  });

  // Factory constructor to create object from backend JSON
  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      tokenId: json['tokenId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      tokenNumber: json['tokenNumber'] ?? 0,
      status: json['status'] ?? 'WAITING',
      position: json['position'] ?? 0,
      estimatedTime: json['estimatedTime'] ?? '',
    );
  }

  // Convert back to JSON (useful if sending to backend)
  Map<String, dynamic> toJson() {
    return {
      'tokenId': tokenId,
      'serviceName': serviceName,
      'tokenNumber': tokenNumber,
      'status': status,
      'position': position,
      'estimatedTime': estimatedTime,
    };
  }
}
