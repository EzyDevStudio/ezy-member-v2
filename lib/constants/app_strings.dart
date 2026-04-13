import 'package:ezymember/language/globalization.dart';
import 'package:ezymember/models/category_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'enum.dart';

class AppStrings {
  // App Name
  static const String appName = "EzyMember";

  // App Server Url
  static const String serverUrl = "https://ezymember.sigma-connect.xyz";
  static const String serverEzyPos = "https://ezypos.ezysolutions.com.my";
  static const String serverDirectory = "api";
  static const String deepLinkUrl = "https://www.ezymember.com"; // TODO: 1. Deep Linking

  static List<CategoryModel> categories = [
    CategoryModel(
      title: "Groceries / Daily Essentials",
      description:
          "Vegetables & Fruits, Meat & Seafood, Eggs & Dairy, Rice & Grains, Noodles, Spices & Ingredients, Canned & Dry Foods, Frozen Foods, Snacks & Instant Foods",
      image: "assets/images/cat_groceries.png",
    ),
    CategoryModel(
      title: "Fashion / Lifestyle",
      description: "Clothing & Fashion, Shoes & Accessories, Bags & Watches, Jewelry & Accessories, Fashion Figures & Collectibles",
      image: "assets/images/cat_fashion.png",
    ),
    CategoryModel(
      title: "Electronics & Gadgets",
      description: "Mobile Phones & Accessories, Computers & Accessories, Home Electronics, Smart Devices, Gaming Products",
      image: "assets/images/cat_electronics.png",
    ),
    CategoryModel(
      title: "Home & Living",
      description: "Furniture, Home Decor, Kitchenware, Lighting, Bedding & Household Items",
      image: "assets/images/cat_home.png",
    ),
    CategoryModel(
      title: "Health & Wellness",
      description: "Pharmacy Items, Health Products, Supplements, Fitness Products, Traditional Medicine, Beauty Products",
      image: "assets/images/cat_health.png",
    ),
    CategoryModel(
      title: "Agriculture & Pets",
      description: "Plants & Gardening, Livestock Products, Pet Food, Pet Accessories",
      image: "assets/images/cat_agriculture.png",
    ),
    CategoryModel(
      title: "Automotive",
      description: "Car Accessories, Motorbike Accessories, Car Care Products, Car Electronics",
      image: "assets/images/cat_automotive.png",
    ),
    CategoryModel(
      title: "Baby Products",
      description: "Clothing & Accessories, Feeding & Nursing, Diapering & Potty, Baby Gear, Toys & Educational Items, Bath & Skincare",
      image: "assets/images/tmp_cat_baby.png",
    ),
    CategoryModel(
      title: "Food & Beverage",
      description: "Restaurants & Cafes, Home-Based Food, Bakeries, Beverages, Frozen Food",
      image: "assets/images/tmp_cat_food.png",
    ),
    CategoryModel(
      title: "Others / Miscellaneous",
      description:
          "Handmade Items, Seasonal Products, Repair & Maintenance, Printing Services, Cleaning Services, Education & Tuition, Freelance Services",
      image: "assets/images/tmp_cat_others.png",
    ),
  ];

  Map<HistoryType, String> historyTypes = {
    HistoryType.all: Globalization.all.tr,
    HistoryType.point: Globalization.points.tr,
    HistoryType.voucher: Globalization.vouchers.tr,
    HistoryType.credit: Globalization.credits.tr,
  };
  Map<ImageSource, String> imageSrc = {ImageSource.camera: Globalization.camera.tr, ImageSource.gallery: Globalization.gallery.tr};
  Map<String, String> genders = {"M": Globalization.male.tr, "F": Globalization.female.tr, "O": Globalization.preferNotToSay.tr};
}
