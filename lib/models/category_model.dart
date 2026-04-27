class CategoryModel {
  final String title;
  final String description;
  final String icon;
  final String image;
  final String code;

  CategoryModel({required this.title, required this.description, required this.icon, required this.image}) : code = title.split(" ").first;
}
