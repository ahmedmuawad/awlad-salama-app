import 'package:flutter_grocery/data/model/response/product_model.dart';

class CartApiModel {
  /* "id": 1,
        "user_id": 10,
        "product_id": 81,
        "quantity": 2,
        "created_at": "2022-08-25T11:40:12.000000Z",
        "updated_at": "2022-08-25T11:40:42.000000Z",
        "product" */

  int _id;
  int _user_id;
  int _product_id;
  int _quantity;
  CartProduct _cartProduct;

  CartApiModel(
      {int id,
      int userId,
      int productId,
      int quantity,
      CartProduct cartProduct}) {
    this._cartProduct = cartProduct;
    this._id = id;
    this._product_id = productId;
    this._quantity = quantity;
    this._user_id = userId;
  }

  int get id => _id;
  int get userId => _user_id;
  int get quantity => _quantity;
  int get productId => _product_id;
  CartProduct get cartProduct => _cartProduct;

  CartApiModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _user_id = json['user_id'];
    _product_id = json['product_id'];
    _quantity = json['quantity'];
    _cartProduct =
        json['product'] != null ? CartProduct.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['user_id'] = this._user_id;
    data['product_id'] = this._product_id;
    data['quantity'] = this._quantity;
    if (this._cartProduct != null) {
      data['product'] = this._cartProduct.toJson();
    }

    return data;
  }
}

class CartProduct {
  int _id;
  String _name;
  String _description;
  /* List<String> _image; */
  String _image;
  double _price;
  /* List<Variations> _variations; */
  double _tax;
  int _status;
  String _createdAt;
  String _updatedAt;
  /* List<String> _attributes;
  List<CategoryIds> _categoryIds;
  List<ChoiceOptions> _choiceOptions; */
  double _discount;
  String _discountType;
  String _taxType;
  String _unit;
  double _capacity;
  int _totalStock;
  /* List<Rating> _rating; */

  CartProduct({
    int id,
    String name,
    String description,
    String image,
    double price,
    /* List<Variations> variations, */
    double tax,
    int status,
    String createdAt,
    String updatedAt,
    /* List<String> attributes,
      List<CategoryIds> categoryIds,
      List<ChoiceOptions> choiceOptions, */
    double discount,
    String discountType,
    String taxType,
    String unit,
    double capacity,
    int totalStock,
    /* List<Null> rating */
  }) {
    this._id = id;
    this._name = name;
    this._description = description;
    this._image = image;
    this._price = price;
    /* this._variations = variations; */
    this._tax = tax;
    this._status = status;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
    /* this._attributes = attributes;
    this._categoryIds = categoryIds;
    this._choiceOptions = choiceOptions; */
    this._discount = discount;
    this._discountType = discountType;
    this._taxType = taxType;
    this._unit = unit;
    this._capacity = capacity;
    this._totalStock = totalStock;
    /* this._rating = rating; */
  }

  int get id => _id;
  String get name => _name;
  String get description => _description;
  String get image => _image;
  double get price => _price;
  /* List<Variations> get variations => _variations; */
  double get tax => _tax;
  int get status => _status;
  String get createdAt => _createdAt;
  String get updatedAt => _updatedAt;
  /* List<String> get attributes => _attributes;
  List<CategoryIds> get categoryIds => _categoryIds;
  List<ChoiceOptions> get choiceOptions => _choiceOptions; */
  double get discount => _discount;
  String get discountType => _discountType;
  String get taxType => _taxType;
  String get unit => _unit;
  double get capacity => _capacity;
  int get totalStock => _totalStock;
  /* List<Rating> get rating => _rating; */

  CartProduct.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
    _description = json['description'];
    _image = json['img'];
    _price = json['price'].toDouble();
    /* if (json['variations'] != null) {
      _variations = [];
      json['variations'].forEach((v) {
        _variations.add(new Variations.fromJson(v));
      });
    } */
    _tax = json['tax'].toDouble();
    _status = json['status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    /* _attributes = json['attributes'].cast<String>();
    if (json['category_ids'] != null) {
      _categoryIds = [];
      json['category_ids'].forEach((v) {
        _categoryIds.add(new CategoryIds.fromJson(v));
      });
    }
    if (json['choice_options'] != null) {
      _choiceOptions = [];
      json['choice_options'].forEach((v) {
        _choiceOptions.add(new ChoiceOptions.fromJson(v));
      });
    } */
    _discount = json['discount'].toDouble();
    _discountType = json['discount_type'];
    _taxType = json['tax_type'];
    _unit = json['unit'];
    _capacity = json['capacity'] != null
        ? json['capacity'].toDouble()
        : json['capacity'];
    _totalStock = json['total_stock'];
    /*  if (json['rating'] != null) {
      _rating = [];
      json['rating'].forEach((v) {
        _rating.add(new Rating.fromJson(v));
      });
    } */
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['name'] = this._name;
    data['description'] = this._description;
    data['img'] = this._image;
    data['price'] = this._price;
    /* if (this._variations != null) {
      data['variations'] = this._variations.map((v) => v.toJson()).toList();
    } */
    data['tax'] = this._tax;
    data['status'] = this._status;
    data['created_at'] = this._createdAt;
    data['updated_at'] = this._updatedAt;
    /* data['attributes'] = this._attributes;
    if (this._categoryIds != null) {
      data['category_ids'] = this._categoryIds.map((v) => v.toJson()).toList();
    }
    if (this._choiceOptions != null) {
      data['choice_options'] =
          this._choiceOptions.map((v) => v.toJson()).toList();
    } */
    data['discount'] = this._discount;
    data['discount_type'] = this._discountType;
    data['tax_type'] = this._taxType;
    data['unit'] = this._unit;
    data['capacity'] = this._capacity;
    data['total_stock'] = this._totalStock;
    /* if (this._rating != null) {
      data['rating'] = this._rating.map((v) => v.toJson()).toList();
    } */
    return data;
  }
}
