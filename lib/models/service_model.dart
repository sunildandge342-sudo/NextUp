
class ServiceModel {
  final int id;
  final String name;
  final String description;
  final bool isActive;
  final int? maxCapacity;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    this.maxCapacity,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['isActive'],
      maxCapacity: json['maxCapacity'],
    );
  }
}