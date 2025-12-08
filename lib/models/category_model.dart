const String fieldID = "id";
const String fieldCategoryID = "category_id";
const String fieldCategoryTitle = "category_title";
const String fieldCategoryImage = "category_image";

class CategoryModel {
  static const String keyCategory = "categories";

  final int id;
  final String categoryID;
  final String categoryTitle;
  final String categoryImage;

  CategoryModel({this.id = 0, this.categoryID = "", this.categoryTitle = "", this.categoryImage = ""});

  CategoryModel.empty() : this();

  factory CategoryModel.fromJson(Map<String, dynamic> data) => CategoryModel(
    id: data[fieldID] ?? 0,
    categoryID: data[fieldCategoryID] ?? "",
    categoryTitle: data[fieldCategoryTitle] ?? "",
    categoryImage: data[fieldCategoryImage] ?? "",
  );

  @override
  String toString() => "CategoryModel(id: $id, categoryID: $categoryID, categoryTitle: $categoryTitle, categoryImage: $categoryImage)\n";
}
