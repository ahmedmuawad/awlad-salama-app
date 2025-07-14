import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/cart_api_model.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/localization_provider.dart';

import 'package:flutter/material.dart';

import '../cart_screen.dart';

class CartProductWidget extends StatefulWidget {
  final CartApiModel cart;
  final CartModel cartL;
  final int index;
  bool _isLoading = false;

  CartProductWidget({this.cart, this.cartL, @required this.index});

  @override
  State<CartProductWidget> createState() => _CartProductWidgetState();
}

class _CartProductWidgetState extends State<CartProductWidget> {
  @override
  void initState() {
    super.initState();
    Provider.of<CartProvider>(context, listen: false).getMyCartData(
      context,
      Provider.of<AuthProvider>(context, listen: false).getUserToken(),
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isLogged =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();

    return widget.cart != null
        ? !widget._isLoading
            ? Container(
                margin:
                    EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_DEFAULT),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Stack(children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Icon(Icons.delete, color: Colors.white, size: 50),
                  ),
                  Dismissible(
                      key: UniqueKey(),
                      onDismissed: (DismissDirection direction) async {
                        setState(() {
                          widget._isLoading = true;
                        });
                        await Future.delayed(Duration(seconds: 5));
                        Provider.of<CouponProvider>(context, listen: false)
                            .removeCouponData(false);

                        Provider.of<CartProvider>(context, listen: false)
                            .removeFromCart(widget.index, context);
                        setState(() {
                          widget._isLoading = false;
                        });
                        setState(() {});
                      },
                      child: Container(
                        height: 95,
                        padding: EdgeInsets.symmetric(
                            vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                            horizontal: Dimensions.PADDING_SIZE_SMALL),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[
                                  Provider.of<ThemeProvider>(context).darkTheme
                                      ? 700
                                      : 300],
                              blurRadius: 5,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FadeInImage.assetNetwork(
                              placeholder: Images.placeholder,
                              image:
                                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${widget.cart.cartProduct.image}',
                              height: 70,
                              width: 85,
                              imageErrorBuilder: (c, o, s) => Image.asset(
                                  Images.placeholder,
                                  height: 70,
                                  width: 85),
                            ),
                          ),
                          SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                          Expanded(
                              child: Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(widget.cart.cartProduct.name,
                                          style: poppinsRegular.copyWith(
                                              fontSize: Dimensions
                                                  .FONT_SIZE_EXTRA_SMALL),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis)),
                                  Column(
                                    children: [
                                      Text(
                                        PriceConverter.convertPrice(context,
                                            widget.cart.cartProduct.price,
                                            discount: widget
                                                .cart.cartProduct.discount,
                                            discountType: widget
                                                .cart.cartProduct.discountType),
                                        style: poppinsBold.copyWith(
                                            fontSize:
                                                Dimensions.FONT_SIZE_SMALL),
                                      ),
                                      widget.cart.cartProduct.discount > 0
                                          ? Text(
                                              PriceConverter.convertPrice(
                                                  context,
                                                  widget
                                                      .cart.cartProduct.price),
                                              style: poppinsRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_EXTRA_SMALL,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                color: Colors.red,
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(children: [
                                Expanded(
                                    child: Text(
                                        '${widget.cart.cartProduct.capacity} ${widget.cart.cartProduct.unit}',
                                        style: poppinsRegular.copyWith(
                                            fontSize:
                                                Dimensions.FONT_SIZE_SMALL))),
                                InkWell(
                                  onTap: () async {
                                    if (widget.cart.quantity > 0) {
                                      if (widget.cart.quantity > 1) {
                                        Provider.of<CartProvider>(context,
                                                listen: false)
                                            .decreamentProduct(
                                                context,
                                                Provider.of<AuthProvider>(
                                                        context,
                                                        listen: false)
                                                    .getUserToken(),
                                                Provider.of<LocalizationProvider>(
                                                        context,
                                                        listen: false)
                                                    .locale
                                                    .languageCode,
                                                widget.cart.cartProduct.id);
                                        if (widget.cart.quantity > 0) {
                                          Provider.of<CartProvider>(context,
                                                  listen: false)
                                              .setQuantity(
                                                  false, widget.index, context);
                                        }

                                        setState(() {});
                                      } else if (widget.cart.quantity == 1) {
                                        Loader.show(context,
                                            progressIndicator:
                                                CircularProgressIndicator());
                                        Provider.of<CouponProvider>(context,
                                                listen: false)
                                            .removeCouponData(false);
                                        Provider.of<CartProvider>(context,
                                                listen: false)
                                            .removeFromCart(
                                                widget.index, context);
                                        setState(() {});
                                        Loader.hide();
                                      }
                                    } else if (widget.cart.quantity == 0) {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .removeFromCart(
                                              widget.index, context);
                                      setState(() {});
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.PADDING_SIZE_SMALL,
                                        vertical: Dimensions
                                            .PADDING_SIZE_EXTRA_SMALL),
                                    child: Icon(Icons.remove,
                                        size: 20,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                Text(widget.cart.quantity.toString(),
                                    style: poppinsSemiBold.copyWith(
                                        fontSize:
                                            Dimensions.FONT_SIZE_EXTRA_LARGE,
                                        color: Theme.of(context).primaryColor)),
                                InkWell(
                                  onTap: () {
                                    if (widget.cart.quantity <
                                        widget.cart.cartProduct.totalStock) {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .increamentProduct(
                                              context,
                                              Provider.of<AuthProvider>(context,
                                                      listen: false)
                                                  .getUserToken(),
                                              Provider.of<LocalizationProvider>(
                                                      context,
                                                      listen: false)
                                                  .locale
                                                  .languageCode,
                                              widget.cart.cartProduct.id);
                                      Provider.of<CouponProvider>(context,
                                              listen: false)
                                          .removeCouponData(false);
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .setQuantity(
                                              true, widget.index, context);
                                      setState(() {});
                                    } else {
                                      showCustomSnackBar(
                                          getTranslated(
                                              'out_of_stock', context),
                                          context);
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            Dimensions.PADDING_SIZE_SMALL,
                                        vertical: Dimensions
                                            .PADDING_SIZE_EXTRA_SMALL),
                                    child: Icon(Icons.add,
                                        size: 20,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ]),
                            ],
                          )),
                          !ResponsiveHelper.isMobile(context)
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal:
                                          Dimensions.PADDING_SIZE_SMALL),
                                  child: IconButton(
                                    onPressed: () {
                                      /* Provider.of<CartProvider>(context, listen: false)
                              .delete(
                                  context,
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .getUserToken(),
                                  Provider.of<LocalizationProvider>(context,
                                          listen: false)
                                      .locale
                                      .languageCode,
                                  cart.id); */
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .removeFromCart(
                                              widget.index, context);
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                )
                              : SizedBox(),
                        ]),
                      )),
                ]),
              )
            : CircularProgressIndicator()
        : Container(
            margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_DEFAULT),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10)),
            child: Stack(children: [
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Icon(Icons.delete, color: Colors.white, size: 50),
              ),
              Dismissible(
                key: UniqueKey(),
                onDismissed: (DismissDirection direction) {
                  Provider.of<CouponProvider>(context, listen: false)
                      .removeCouponData(false);

                  Provider.of<CartProvider>(context, listen: false)
                      .removeFromCart(widget.index, context);
                },
                child: Container(
                  height: 95,
                  padding: EdgeInsets.symmetric(
                      vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                      horizontal: Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[
                            Provider.of<ThemeProvider>(context).darkTheme
                                ? 700
                                : 300],
                        blurRadius: 5,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FadeInImage.assetNetwork(
                        placeholder: Images.placeholder,
                        image:
                            '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${widget.cartL.image}',
                        height: 70,
                        width: 85,
                        imageErrorBuilder: (c, o, s) => Image.asset(
                            Images.placeholder,
                            height: 70,
                            width: 85),
                      ),
                    ),
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    Expanded(
                        child: Column(
                      children: [
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(widget.cartL.name,
                                    style: poppinsRegular.copyWith(
                                        fontSize: Dimensions.FONT_SIZE_SMALL),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis)),
                            Text(
                              PriceConverter.convertPrice(
                                  context, widget.cartL.price),
                              style: poppinsSemiBold.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_SMALL),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                        SizedBox(height: 1),
                        Row(children: [
                          Expanded(
                              child: Text(
                                  '${widget.cartL.capacity} ${widget.cartL.unit}',
                                  style: poppinsRegular.copyWith(
                                      fontSize: Dimensions.FONT_SIZE_SMALL))),
                          InkWell(
                            onTap: () {
                              Provider.of<CouponProvider>(context,
                                      listen: false)
                                  .removeCouponData(false);
                              if (widget.cartL.quantity > 1) {
                                if (_isLogged) {
                                  Provider.of<CartProvider>(context,
                                          listen: false)
                                      .decreamentProduct(
                                          context,
                                          Provider.of<AuthProvider>(context,
                                                  listen: false)
                                              .getUserToken(),
                                          Provider.of<LocalizationProvider>(
                                                  context,
                                                  listen: false)
                                              .locale
                                              .languageCode,
                                          widget.cartL.id);
                                }
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .setQuantity(false, widget.index, context);
                              } else if (widget.cartL.quantity == 1) {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .removeFromCart(widget.index, context);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_SMALL,
                                  vertical:
                                      Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              child: Icon(Icons.remove,
                                  size: 20,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                          Text(widget.cartL.quantity.toString(),
                              style: poppinsSemiBold.copyWith(
                                  fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE,
                                  color: Theme.of(context).primaryColor)),
                          InkWell(
                            onTap: () {
                              /* if (isExistInCart) {
                            showCustomSnackBar(
                                getTranslated('already_added', context),
                                context);
                          } else if (_stock < 1) {
                            showCustomSnackBar(
                                getTranslated('out_of_stock', context),
                                context);
                          } else {
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(_cartModel);
                            Provider.of<CartProvider>(context, listen: false)
                                .addToMyCart(
                                    context,
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .getUserToken(),
                                    Provider.of<LocalizationProvider>(context,
                                            listen: false)
                                        .locale
                                        .languageCode,
                                    product.id,
                                    1);

                            showCustomSnackBar(
                                getTranslated('added_to_cart', context),
                                context,
                                isError: false);
                          } */
                              if (widget.cartL.quantity < widget.cartL.stock) {
                                if (_isLogged) {
                                  Provider.of<CartProvider>(context,
                                          listen: false)
                                      .increamentProduct(
                                          context,
                                          Provider.of<AuthProvider>(context,
                                                  listen: false)
                                              .getUserToken(),
                                          Provider.of<LocalizationProvider>(
                                                  context,
                                                  listen: false)
                                              .locale
                                              .languageCode,
                                          widget.cartL.id);
                                }
                                Provider.of<CouponProvider>(context,
                                        listen: false)
                                    .removeCouponData(false);
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .setQuantity(true, widget.index, context);
                              } else {
                                showCustomSnackBar(
                                    getTranslated('out_of_stock', context),
                                    context);
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_SMALL,
                                  vertical:
                                      Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              child: Icon(Icons.add,
                                  size: 20,
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ]),
                      ],
                    )),
                    !ResponsiveHelper.isMobile(context)
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_SMALL),
                            child: IconButton(
                              onPressed: () {
                                /* Provider.of<CartProvider>(context, listen: false)
                              .delete(
                                  context,
                                  Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .getUserToken(),
                                  Provider.of<LocalizationProvider>(context,
                                          listen: false)
                                      .locale
                                      .languageCode,
                                  cart.id); */
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .removeFromCart(widget.index, context);
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          )
                        : SizedBox(),
                  ]),
                ),
              ),
            ]),
          );
  }
}
