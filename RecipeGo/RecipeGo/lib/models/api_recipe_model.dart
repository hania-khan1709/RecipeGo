class ApiRecipeModel {
  final int id;
  final String title;
  final String image;
  final int readyInMinutes;

  ApiRecipeModel({
    required this.id,
    required this.title,
    required this.image,
    required this.readyInMinutes,
  });

  factory ApiRecipeModel.fromJson(Map<String, dynamic> json) {
    return ApiRecipeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Recipe',
      image: json['image'] ?? '',
      readyInMinutes: json['readyInMinutes'] ?? 30,
    );
  }
}
