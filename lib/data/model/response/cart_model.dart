import 'package:flutter_grocery/data/model/response/product_model.dart';

class CartModel {
  int _id;
  String _image;
  String _name;
  double _price;
  double _discountedPrice;
  int _quantity;
  Variations _variation;
  double _discount;
  double _tax;
  double _capacity;
  String _unit;
  int _stock;

  // Constructor عادي
  CartModel(
      int id,
      String image,
      String name,
      double price,
      double discountedPrice,
      int quantity,
      Variations variation,
      double discount,
      double tax,
      double capacity,
      String unit,
      int stock,
      ) {
    _id = id;
    _image = image;
    _name = name;
    _price = price;
    _discountedPrice = discountedPrice;
    _quantity = quantity;
    _variation = variation;
    _discount = discount;
    _tax = tax;
    _capacity = capacity;
    _unit = unit;
    _stock = stock;
  }

  // Getters
  int get id => _id;
  String get image => _image;
  String get name => _name;
  double get price => _price;
  double get discountedPrice => _discountedPrice;
  int get quantity => _quantity;
  Variations get variation => _variation;
  double get discount => _discount;
  double get tax => _tax;
  double get capacity => _capacity;
  String get unit => _unit;
  int get stock => _stock;

  // Setter
  set quantity(int value) {
    _quantity = value;
  }

  // JSON methods
  CartModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _image = json['image'];
    _price = json['price'];
    _discountedPrice = json['discounted_price'];
    _quantity = json['quantity'];
    _variation = json['variations'] != null
        ? Variations.fromJson(json['variations'])
        : null;
    _discount = json['discount'];
    _tax = json['tax'];
    _capacity = json['capacity'];
    _unit = json['unit'];
    _stock = json['stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = _id;
    data['name'] = _name;
    data['image'] = _image;
    data['price'] = _price;
    data['discounted_price'] = _discountedPrice;
    data['quantity'] = _quantity;
    if (_variation != null) {
      data['variations'] = _variation.toJson();
    }
    data['discount'] = _discount;
    data['tax'] = _tax;
    data['capacity'] = _capacity;
    data['unit'] = _unit;
    data['stock'] = _stock;
    return data;
  }
}
