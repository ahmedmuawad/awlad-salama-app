import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';
import '../../../../provider/cart_provider.dart';
import '../../../../provider/localization_provider.dart';

class ProductTitleView extends StatelessWidget {
  final Product product;
  final int stock;
  final int index;
  final bool isExistInCart;
  ProductTitleView(
      {@required this.product,
      this.isExistInCart,
      this.index,
      @required this.stock});

  @override
  Widget build(BuildContext context) {
    bool isLogged =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    double _startingPrice;
    double _endingPrice;
    if (product.variations.length != 0) {
      List<double> _priceList = [];
      product.variations.forEach(
          (variation) => _priceList.add(double.parse(variation.price)));
      _priceList.sort((a, b) => a.compareTo(b));
      _startingPrice = _priceList[0];
      if (_priceList[0] < _priceList[_priceList.length - 1]) {
        _endingPrice = _priceList[_priceList.length - 1];
      }
    } else {
      _startingPrice = product.price;
    }

    return Container(
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.PADDING_SIZE_DEFAULT),
            topRight: Radius.circular(Dimensions.PADDING_SIZE_DEFAULT)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? '',
                  style: poppinsMedium.copyWith(
                      fontSize: Dimensions.FONT_SIZE_LARGE,
                      color: ColorResources.getTextColor(context)),
                  maxLines: 2,
                ),

                //Product Price
                Text(
                  '${PriceConverter.convertPrice(context, _startingPrice, discount: product.discount, discountType: product.discountType)}'
                  '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(context, _endingPrice, discount: product.discount, discountType: product.discountType)}' : ''}',
                  style: poppinsBold.copyWith(
                      color: ColorResources.getTextColor(context),
                      fontSize: Dimensions.FONT_SIZE_LARGE),
                ),
                product.discount > 0
                    ? Text(
                        '${PriceConverter.convertPrice(context, _startingPrice)}'
                        '${_endingPrice != null ? ' - ${PriceConverter.convertPrice(context, _endingPrice)}' : ''}',
                        style: poppinsBold.copyWith(
                            color: Colors.red,
                            fontSize: Dimensions.FONT_SIZE_SMALL,
                            decoration: TextDecoration.lineThrough),
                      )
                    : SizedBox(),

                Row(children: [
                  Text(
                    '${product.capacity} ${product.unit}',
                    style: poppinsRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.FONT_SIZE_SMALL),
                  ),
                  Expanded(child: SizedBox.shrink()),
                  Row(children: [
                    QuantityButton(
                        isExistInCart: isExistInCart,
                        isIncrement: false,
                        quantity: productProvider.quantity,
                        stock: stock,
                        id: product.id,
                        isLogged: isLogged,
                        index: index),
                    SizedBox(width: 15),
                    Text(productProvider.quantity.toString(),
                        style: poppinsSemiBold),
                    SizedBox(width: 15),
                    QuantityButton(
                        isExistInCart: isExistInCart,
                        isIncrement: true,
                        quantity: productProvider.quantity,
                        stock: stock,
                        id: product.id,
                        isLogged: isLogged,
                        index: index),
                  ]),
                ]),
              ]);
        },
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int quantity;
  final bool isCartWidget;
  final int stock;
  final int id;
  final bool isLogged;
  final index;
  final bool isExistInCart;
  QuantityButton(
      {@required this.isExistInCart,
      @required this.index,
      @required this.id,
      @required this.isIncrement,
      @required this.quantity,
      @required this.stock,
      this.isCartWidget = false,
      @required this.isLogged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!isIncrement && quantity > 1) {
          if (isExistInCart) {
            Provider.of<CartProvider>(context, listen: false)
                .setQuantity(false, index, context);
            Provider.of<ProductProvider>(context, listen: false)
                .setQuantity(false);
            if (isLogged) {
              Provider.of<CartProvider>(context, listen: false)
                  .decreamentProduct(
                      context,
                      Provider.of<AuthProvider>(context, listen: false)
                          .getUserToken(),
                      Provider.of<LocalizationProvider>(context, listen: false)
                          .locale
                          .languageCode,
                      id);
            }
          } else {
            Provider.of<ProductProvider>(context, listen: false)
                .setQuantity(false);
            if (isLogged) {
              Provider.of<CartProvider>(context, listen: false)
                  .decreamentProduct(
                      context,
                      Provider.of<AuthProvider>(context, listen: false)
                          .getUserToken(),
                      Provider.of<LocalizationProvider>(context, listen: false)
                          .locale
                          .languageCode,
                      id);
            }
          }
        } else if (isIncrement) {
          if (quantity < stock) {
            if (isExistInCart) {
              Provider.of<CartProvider>(context, listen: false)
                  .setQuantity(true, index, context);
              Provider.of<ProductProvider>(context, listen: false)
                  .setQuantity(true);
              if (isLogged) {
                Provider.of<CartProvider>(context, listen: false)
                    .increamentProduct(
                        context,
                        Provider.of<AuthProvider>(context, listen: false)
                            .getUserToken(),
                        Provider.of<LocalizationProvider>(context,
                                listen: false)
                            .locale
                            .languageCode,
                        id);
              }
            } else {
              Provider.of<ProductProvider>(context, listen: false)
                  .setQuantity(true);
              if (isLogged) {
                Provider.of<CartProvider>(context, listen: false)
                    .increamentProduct(
                        context,
                        Provider.of<AuthProvider>(context, listen: false)
                            .getUserToken(),
                        Provider.of<LocalizationProvider>(context,
                                listen: false)
                            .locale
                            .languageCode,
                        id);
              }
            }
          } else {
            showCustomSnackBar(getTranslated('out_of_stock', context), context);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorResources.getGreyColor(context))),
        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          color: isIncrement
              ? Theme.of(context).primaryColor
              : quantity > 1
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor,
          size: isCartWidget ? 26 : 20,
        ),
      ),
    );
  }
}
