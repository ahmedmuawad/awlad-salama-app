import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datasource/remote/exception/api_error_handler.dart';
import '../model/response/base/api_response.dart';

class CartRepo {
  final SharedPreferences sharedPreferences;
  DioClient dioClient;
  CartRepo({@required this.dioClient, @required this.sharedPreferences});

  Future<ApiResponse> getMyCartDataList(String token, String language) async {
    try {
      final response = await dioClient.get(
        AppConstants.GET_CART,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'X-localization': language
        }),
      );
      print('Here Cart ============================================== Done ');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      print('Here Cart ============================================== Error ');
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> addToMyCart(
      String token, String language, int id, int quantity) async {
    try {
      final response = await dioClient.post(AppConstants.ADD_TO_CART,
          options: Options(headers: {
            'Authorization': 'Bearer $token',
            'X-localization': language
          }),
          data: {'id': id, 'quantity': quantity});

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> increment(String token, String language, int id) async {
    try {
      final response = await dioClient.get(
        AppConstants.INCREAMENT + '/$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'X-localization': language
        }),
      );

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> delete(String token, String language, int id) async {
    try {
      final response = await dioClient.get(
        AppConstants.DELETE + '/$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'X-localization': language
        }),
      );

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> decrement(String token, String language, int id) async {
    try {
      final response = await dioClient.get(
        AppConstants.DECREAMENT + '/$id',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'X-localization': language
        }),
      );

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  List<CartModel> getCartList() {
    List<String> carts = [];
    if (sharedPreferences.containsKey(AppConstants.CART_LIST)) {
      carts = sharedPreferences.getStringList(AppConstants.CART_LIST);
    }
    List<CartModel> cartList = [];
    carts.forEach((cart) => cartList.add(CartModel.fromJson(jsonDecode(cart))));
    return cartList;
  }

  void addToCartList(List<CartModel> cartProductList) {
    List<String> carts = [];
    cartProductList.forEach((cartModel) => carts.add(jsonEncode(cartModel)));
    sharedPreferences.setStringList(AppConstants.CART_LIST, carts);
  }
}
