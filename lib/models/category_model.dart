class CategoryModel {
  final String title;
  final String description;
  final String image;
  final String code;

  CategoryModel({required this.title, required this.description, required this.image}) : code = title.split(" ").first;
}
