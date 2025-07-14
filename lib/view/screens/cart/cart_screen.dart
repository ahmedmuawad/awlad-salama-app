import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';
import 'package:flutter_grocery/view/base/main_app_bar.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/screens/cart/widget/cart_product_widget.dart';
import 'package:flutter_grocery/view/screens/cart/widget/delivery_option_button.dart';
import 'package:flutter_grocery/view/screens/checkout/checkout_screen.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/profile_provider.dart';
import '../../../provider/theme_provider.dart';
import '../../../utill/images.dart';
import '../../base/custom_snackbar.dart';

class CartScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _couponController = TextEditingController();
  bool _isLogged;
  String balance;
  bool _isLoading = false;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    Future<void> reload() {
      if (widget._isLogged) {
        Provider.of<CartProvider>(context, listen: false).getMyCartData(
            context,
            Provider.of<AuthProvider>(context, listen: false).getUserToken(),
            Provider.of<LocalizationProvider>(context, listen: false)
                .locale
                .languageCode);
      }
    }

    print('first of screen ======================== ');
    Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
    bool _isSelfPickupActive =
        Provider.of<SplashProvider>(context, listen: false)
                .configModel
                .selfPickup ==
            1;
    bool _kmWiseCharge = Provider.of<SplashProvider>(context, listen: false)
            .configModel
            .deliveryManagement
            .status ==
        1;
    print('after kmWise ================================');
    widget._isLogged =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (widget._isLogged) {
      Provider.of<ProfileProvider>(context, listen: false).getUserInfo(context);
    }
    print('after user info ===============================');
    if (widget._isLogged) {
      Provider.of<CartProvider>(context, listen: false).getMyCartData(
          context,
          Provider.of<AuthProvider>(context, listen: false).getUserToken(),
          Provider.of<LocalizationProvider>(context, listen: false)
              .locale
              .languageCode);
    }

    print('after cart info ===============================');

    return Scaffold(
      key: widget._scaffoldKey,
      body: Center(
        child: widget._isLogged
            ? Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                return Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    print(
                        'after cart Consumer ===============================');

                    widget.balance = profileProvider.userInfoModel.balance;
                    print(
                        'after cart foreach =============================== ${widget.balance}');
                    if (widget.balance == null) {
                      widget.balance = '0.0';
                    } else {
                      widget.balance = widget.balance;
                    }
                    double _oldBalance = double.parse(widget.balance);

                    double disBalance = 0.00;
                    double deliveryCharge = 0;

                    (Provider.of<OrderProvider>(context).orderType ==
                                'delivery' &&
                            !_kmWiseCharge)
                        ? deliveryCharge =
                            Provider.of<SplashProvider>(context, listen: false)
                                .configModel
                                .deliveryCharge
                        : deliveryCharge = 0;
                    double _itemPrice = 0;
                    double _discount = 0;
                    double _tax = 0;

                    cart.cartApiList.forEach((cartModel) {
                      _itemPrice = _itemPrice +
                          (cartModel.cartProduct.price * cartModel.quantity);
                      _discount = _discount +
                          (cartModel.cartProduct.discount * cartModel.quantity);
                      _tax = _tax +
                          (cartModel.cartProduct.tax * cartModel.quantity);
                    });

                    double _subTotal = _itemPrice + _tax;

                    double _total = _subTotal -
                        _discount -
                        Provider.of<CouponProvider>(context).discount +
                        deliveryCharge;
                    if (_oldBalance > _total) {
                      disBalance = _total;
                      _oldBalance = _oldBalance - _total;
                      _total = 0.00;
                    } else if (_oldBalance < _total && _oldBalance == 0) {
                      disBalance = _oldBalance;
                      _total = _total - _oldBalance;
                      _oldBalance = 0.00;
                    } else if (_oldBalance < _total) {
                      _total = _total - _oldBalance;
                      disBalance = _oldBalance;
                      _oldBalance = 0.00;
                    }
                    return cart.cartApiList.length > 0
                        ? Column(
                            children: [
                              Expanded(
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    physics: BouncingScrollPhysics(),
                                    child: Center(
                                      child: SizedBox(
                                        width: 1170,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Product
                                              ListView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount:
                                                    cart.cartApiList.length,
                                                itemBuilder: (context, index) {
                                                  return !widget._isLoading
                                                      ? Container(
                                                          margin: EdgeInsets.only(
                                                              bottom: Dimensions
                                                                  .PADDING_SIZE_DEFAULT),
                                                          decoration: BoxDecoration(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Stack(
                                                              children: [
                                                                Positioned(
                                                                  top: 0,
                                                                  bottom: 0,
                                                                  right: 0,
                                                                  left: 0,
                                                                  child: Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 50),
                                                                ),
                                                                Dismissible(
                                                                    key:
                                                                        UniqueKey(),
                                                                    onDismissed:
                                                                        (DismissDirection
                                                                            direction) async {
                                                                      setState(
                                                                          () {
                                                                        widget._isLoading =
                                                                            true;
                                                                      });
                                                                      await Future.delayed(Duration(
                                                                          seconds:
                                                                              5));
                                                                      Provider.of<CouponProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .removeCouponData(
                                                                              false);

                                                                      Provider.of<CartProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .removeFromCart(
                                                                              index,
                                                                              context);

                                                                      setState(
                                                                          () {
                                                                        widget._isLoading =
                                                                            false;
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          95,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical: Dimensions
                                                                              .PADDING_SIZE_EXTRA_SMALL,
                                                                          horizontal:
                                                                              Dimensions.PADDING_SIZE_SMALL),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .cardColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme
                                                                                ? 700
                                                                                : 300],
                                                                            blurRadius:
                                                                                5,
                                                                            spreadRadius:
                                                                                1,
                                                                          )
                                                                        ],
                                                                      ),
                                                                      child: Row(
                                                                          children: [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              child: FadeInImage.assetNetwork(
                                                                                placeholder: Images.placeholder,
                                                                                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${cart.cartApiList[index].cartProduct.image}',
                                                                                height: 70,
                                                                                width: 85,
                                                                                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder, height: 70, width: 85),
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
                                                                                    Expanded(flex: 2, child: Text(cart.cartApiList[index].cartProduct.name, style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                                                                    Column(
                                                                                      children: [
                                                                                        Text(
                                                                                          PriceConverter.convertPrice(context, cart.cartApiList[index].cartProduct.price, discount: cart.cartApiList[index].cartProduct.discount, discountType: cart.cartApiList[index].cartProduct.discountType),
                                                                                          style: poppinsBold.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
                                                                                        ),
                                                                                        cart.cartApiList[index].cartProduct.discount > 0
                                                                                            ? Text(
                                                                                                PriceConverter.convertPrice(context, cart.cartApiList[index].cartProduct.price),
                                                                                                style: poppinsRegular.copyWith(
                                                                                                  fontSize: Dimensions.FONT_SIZE_EXTRA_SMALL,
                                                                                                  decoration: TextDecoration.lineThrough,
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
                                                                                  Expanded(child: Text('${cart.cartApiList[index].cartProduct.capacity} ${cart.cartApiList[index].cartProduct.unit}', style: poppinsRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL))),
                                                                                  InkWell(
                                                                                    onTap: () async {
                                                                                      if (cart.cartApiList[index].quantity > 0) {
                                                                                        if (cart.cartApiList[index].quantity > 1) {
                                                                                          Provider.of<CartProvider>(context, listen: false).decreamentProduct(context, Provider.of<AuthProvider>(context, listen: false).getUserToken(), Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode, cart.cartApiList[index].cartProduct.id);
                                                                                          if (cart.cartApiList[index].quantity > 0) {
                                                                                            Provider.of<CartProvider>(context, listen: false).setQuantity(false, index, context);
                                                                                          }

                                                                                          setState(() {});
                                                                                        } else if (cart.cartApiList[index].quantity == 1) {
                                                                                          Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
                                                                                          Provider.of<CartProvider>(context, listen: false).removeFromCart(index, context);
                                                                                          setState(() {});
                                                                                        }
                                                                                      } else if (cart.cartApiList[index].quantity == 0) {
                                                                                        Provider.of<CartProvider>(context, listen: false).removeFromCart(index, context);
                                                                                        setState(() {});
                                                                                      }
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                                      child: Icon(Icons.remove, size: 20, color: Theme.of(context).primaryColor),
                                                                                    ),
                                                                                  ),
                                                                                  Text(cart.cartApiList[index].quantity.toString(), style: poppinsSemiBold.copyWith(fontSize: Dimensions.FONT_SIZE_EXTRA_LARGE, color: Theme.of(context).primaryColor)),
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      if (cart.cartApiList[index].quantity < cart.cartApiList[index].cartProduct.totalStock) {
                                                                                        Provider.of<CartProvider>(context, listen: false).increamentProduct(context, Provider.of<AuthProvider>(context, listen: false).getUserToken(), Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode, cart.cartApiList[index].cartProduct.id);
                                                                                        Provider.of<CouponProvider>(context, listen: false).removeCouponData(false);
                                                                                        Provider.of<CartProvider>(context, listen: false).setQuantity(true, index, context);
                                                                                        setState(() {});
                                                                                      } else {
                                                                                        showCustomSnackBar(getTranslated('out_of_stock', context), context);
                                                                                      }
                                                                                    },
                                                                                    child: Padding(
                                                                                      padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                                      child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                                                                                    ),
                                                                                  ),
                                                                                ]),
                                                                              ],
                                                                            )),
                                                                            !ResponsiveHelper.isMobile(context)
                                                                                ? Padding(
                                                                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                                                                                    child: IconButton(
                                                                                      onPressed: () {
                                                                                        Provider.of<CartProvider>(context, listen: false).removeFromCart(index, context);
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
                                                      : Center(
                                                          child: Container(
                                                          width: 50,
                                                          height: 50,
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ));
                                                },
                                              ),
                                              SizedBox(
                                                  height: Dimensions
                                                      .PADDING_SIZE_LARGE),

                                              // Coupon
                                              Consumer<CouponProvider>(
                                                builder:
                                                    (context, coupon, child) {
                                                  return Row(children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller: widget
                                                            ._couponController,
                                                        style: poppinsMedium,
                                                        decoration: InputDecoration(
                                                            hintText: getTranslated(
                                                                'enter_promo_code',
                                                                context),
                                                            hintStyle: poppinsRegular
                                                                .copyWith(
                                                                    color: ColorResources.getHintColor(
                                                                        context)),
                                                            isDense: true,
                                                            filled: true,
                                                            enabled: coupon
                                                                    .discount ==
                                                                0,
                                                            fillColor:
                                                                Theme.of(context)
                                                                    .cardColor,
                                                            border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.horizontal(
                                                                        left: Radius.circular(10)),
                                                                borderSide: BorderSide.none)),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        if (widget
                                                                ._couponController
                                                                .text
                                                                .isNotEmpty &&
                                                            !coupon.isLoading) {
                                                          if (coupon.discount <
                                                              1) {
                                                            coupon
                                                                .applyCoupon(
                                                                    widget
                                                                        ._couponController
                                                                        .text,
                                                                    _total)
                                                                .then(
                                                                    (discount) {
                                                              if (discount >
                                                                  0) {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                  content: Text(
                                                                      'You got ${PriceConverter.convertPrice(context, discount)} discount'),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                ));
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                        SnackBar(
                                                                  content: Text(
                                                                      getTranslated(
                                                                          'invalid_code_or_failed',
                                                                          context)),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                ));
                                                              }
                                                            });
                                                          } else {
                                                            coupon
                                                                .removeCouponData(
                                                                    true);
                                                          }
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: Text(
                                                                getTranslated(
                                                                    'enter_a_coupon_code',
                                                                    context)),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ));
                                                        }
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        width: 100,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .horizontal(
                                                            right: Radius.circular(
                                                                Provider.of<LocalizationProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .isLtr
                                                                    ? 10
                                                                    : 0),
                                                            left: Radius.circular(
                                                                Provider.of<LocalizationProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .isLtr
                                                                    ? 0
                                                                    : 10),
                                                          ),
                                                        ),
                                                        child: coupon
                                                                    .discount <=
                                                                0
                                                            ? !coupon.isLoading
                                                                ? Text(
                                                                    getTranslated(
                                                                        'apply',
                                                                        context),
                                                                    style: poppinsMedium
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.white),
                                                                  )
                                                                : CircularProgressIndicator(
                                                                    valueColor: AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Colors
                                                                            .white))
                                                            : Icon(Icons.clear,
                                                                color: Colors
                                                                    .white),
                                                      ),
                                                    ),
                                                  ]);
                                                },
                                              ),
                                              SizedBox(
                                                  height: Dimensions
                                                      .PADDING_SIZE_LARGE),

                                              // Order type
                                              _isSelfPickupActive
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                          Text(
                                                              getTranslated(
                                                                  'delivery_option',
                                                                  context),
                                                              style: poppinsMedium
                                                                  .copyWith(
                                                                      fontSize:
                                                                          Dimensions
                                                                              .FONT_SIZE_LARGE)),
                                                          DeliveryOptionButton(
                                                              value: 'delivery',
                                                              title:
                                                                  getTranslated(
                                                                      'delivery',
                                                                      context),
                                                              kmWiseFee:
                                                                  _kmWiseCharge),
                                                          DeliveryOptionButton(
                                                              value:
                                                                  'self_pickup',
                                                              title: getTranslated(
                                                                  'self_pickup',
                                                                  context),
                                                              kmWiseFee:
                                                                  _kmWiseCharge),
                                                          SizedBox(
                                                              height: Dimensions
                                                                  .PADDING_SIZE_LARGE),
                                                        ])
                                                  : SizedBox(),

                                              // Total
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        getTranslated(
                                                            'items_price',
                                                            context),
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE)),
                                                    Text(
                                                        PriceConverter
                                                            .convertPrice(
                                                                context,
                                                                _itemPrice),
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE)),
                                                  ]),
                                              SizedBox(height: 10),

                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        getTranslated(
                                                            'tax', context),
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE)),
                                                    Text(
                                                        '(+) ${PriceConverter.convertPrice(context, _tax)}',
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE)),
                                                  ]),
                                              SizedBox(height: 10),

                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        getTranslated(
                                                            'discount',
                                                            context),
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE)),
                                                    Text(
                                                        '(-) ${PriceConverter.convertPrice(context, _discount)}',
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE)),
                                                  ]),
                                              SizedBox(height: 10),

                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        getTranslated(
                                                            'coupon_discount',
                                                            context),
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE)),
                                                    Text(
                                                      '(-) ${PriceConverter.convertPrice(context, Provider.of<CouponProvider>(context).discount)}',
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE),
                                                    ),
                                                  ]),
                                              SizedBox(height: 10),

                                              _kmWiseCharge
                                                  ? SizedBox()
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                          Text(
                                                            getTranslated(
                                                                'delivery_fee',
                                                                context),
                                                            style: poppinsRegular
                                                                .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .FONT_SIZE_LARGE),
                                                          ),
                                                          Text(
                                                            '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                                                            style: poppinsRegular
                                                                .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .FONT_SIZE_LARGE),
                                                          ),
                                                        ]),
                                              SizedBox(height: 10),
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        getTranslated(
                                                            'balance', context),
                                                        style: poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE)),
                                                    Text(
                                                      '(-) ${profileProvider.userInfoModel.balance}',
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE),
                                                    ),
                                                  ]),
                                              SizedBox(height: 10),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: Dimensions
                                                        .PADDING_SIZE_SMALL),
                                                child: CustomDivider(),
                                              ),

                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        getTranslated(
                                                            _kmWiseCharge
                                                                ? 'subtotal'
                                                                : 'total_amount',
                                                            context),
                                                        style: poppinsMedium
                                                            .copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_EXTRA_LARGE,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        )),
                                                    Text(
                                                      PriceConverter
                                                          .convertPrice(
                                                              context, _total),
                                                      style: poppinsMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_EXTRA_LARGE,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ]),
                                            ]),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1170,
                                padding: EdgeInsets.all(
                                    Dimensions.PADDING_SIZE_SMALL),
                                child: CustomButton(
                                  buttonText: getTranslated(
                                      'continue_checkout', context),
                                  onPressed: () {
                                    if (_itemPrice <
                                        Provider.of<SplashProvider>(context,
                                                listen: false)
                                            .configModel
                                            .minimumOrderValue) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                'Minimum order amount is ${PriceConverter.convertPrice(context, Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue)}, you have ${PriceConverter.convertPrice(context, _itemPrice)} in your cart, please add more item.',
                                              ),
                                              backgroundColor: Colors.red));
                                    } else {
                                      String _orderType =
                                          Provider.of<OrderProvider>(context,
                                                  listen: false)
                                              .orderType;
                                      double _discount =
                                          Provider.of<CouponProvider>(context,
                                                  listen: false)
                                              .discount;
                                      Navigator.pushNamed(
                                        context,
                                        RouteHelper.getCheckoutRoute(
                                          _total,
                                          _discount,
                                          _orderType,
                                          Provider.of<CouponProvider>(context,
                                                  listen: false)
                                              .code,
                                        ),
                                        arguments: CheckoutScreen(
                                          amount: _total,
                                          orderType: _orderType,
                                          discount: _discount,
                                          couponCode:
                                              Provider.of<CouponProvider>(
                                                      context,
                                                      listen: false)
                                                  .code,
                                          balance: disBalance,
                                        ),
                                      );
                                    }
                                    Provider.of<ProfileProvider>(context,
                                            listen: false)
                                        .updateUserBalance(
                                            _oldBalance,
                                            Provider.of<AuthProvider>(context,
                                                    listen: false)
                                                .getUserToken());
                                  },
                                ),
                              ),
                            ],
                          )
                        : NoDataScreen(isCart: true);
                  },
                );
              })
            : Consumer<CartProvider>(
                builder: (context, cart, child) {
                  double deliveryCharge = 0;
                  (Provider.of<OrderProvider>(context).orderType ==
                              'delivery' &&
                          !_kmWiseCharge)
                      ? deliveryCharge =
                          Provider.of<SplashProvider>(context, listen: false)
                              .configModel
                              .deliveryCharge
                      : deliveryCharge = 0;
                  double _itemPrice = 0;
                  double _discount = 0;
                  double _tax = 0;
                  cart.cartList.forEach((cartModel) {
                    _itemPrice =
                        _itemPrice + (cartModel.price * cartModel.quantity);
                    _discount =
                        _discount + (cartModel.discount * cartModel.quantity);
                    _tax = _tax + (cartModel.tax * cartModel.quantity);
                  });
                  double _subTotal = _itemPrice + _tax;
                  double _total = _subTotal -
                      _discount -
                      Provider.of<CouponProvider>(context).discount +
                      deliveryCharge;

                  return cart.cartList.length > 0
                      ? Column(
                          children: [
                            Expanded(
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  padding: EdgeInsets.all(
                                      Dimensions.PADDING_SIZE_SMALL),
                                  physics: BouncingScrollPhysics(),
                                  child: Center(
                                    child: SizedBox(
                                      width: 1170,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Product
                                            ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: cart.cartList.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: Dimensions
                                                          .PADDING_SIZE_DEFAULT),
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Stack(children: [
                                                    Positioned(
                                                      top: 0,
                                                      bottom: 0,
                                                      right: 0,
                                                      left: 0,
                                                      child: Icon(Icons.delete,
                                                          color: Colors.white,
                                                          size: 50),
                                                    ),
                                                    Dismissible(
                                                      key: UniqueKey(),
                                                      onDismissed:
                                                          (DismissDirection
                                                              direction) {
                                                        Provider.of<CouponProvider>(
                                                                context,
                                                                listen: false)
                                                            .removeCouponData(
                                                                false);

                                                        Provider.of<CartProvider>(
                                                                context,
                                                                listen: false)
                                                            .removeFromCart(
                                                                index, context);
                                                      },
                                                      child: Container(
                                                        height: 95,
                                                        padding: EdgeInsets.symmetric(
                                                            vertical: Dimensions
                                                                .PADDING_SIZE_EXTRA_SMALL,
                                                            horizontal: Dimensions
                                                                .PADDING_SIZE_SMALL),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .grey[Provider.of<
                                                                              ThemeProvider>(
                                                                          context)
                                                                      .darkTheme
                                                                  ? 700
                                                                  : 300],
                                                              blurRadius: 5,
                                                              spreadRadius: 1,
                                                            )
                                                          ],
                                                        ),
                                                        child: Row(children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: FadeInImage
                                                                .assetNetwork(
                                                              placeholder: Images
                                                                  .placeholder,
                                                              image:
                                                                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls.productImageUrl}/${cart.cartList[index].image}',
                                                              height: 70,
                                                              width: 85,
                                                              imageErrorBuilder: (c,
                                                                      o, s) =>
                                                                  Image.asset(
                                                                      Images
                                                                          .placeholder,
                                                                      height:
                                                                          70,
                                                                      width:
                                                                          85),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width: Dimensions
                                                                  .PADDING_SIZE_SMALL),
                                                          Expanded(
                                                              child: Column(
                                                            children: [
                                                              SizedBox(
                                                                  height: 10),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                      flex: 2,
                                                                      child: Text(
                                                                          cart
                                                                              .cartList[
                                                                                  index]
                                                                              .name,
                                                                          style: poppinsRegular.copyWith(
                                                                              fontSize: Dimensions
                                                                                  .FONT_SIZE_SMALL),
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis)),
                                                                  Text(
                                                                    PriceConverter.convertPrice(
                                                                        context,
                                                                        cart.cartList[index]
                                                                            .price),
                                                                    style: poppinsSemiBold.copyWith(
                                                                        fontSize:
                                                                            Dimensions.FONT_SIZE_SMALL),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 1),
                                                              Row(children: [
                                                                Expanded(
                                                                    child: Text(
                                                                        '${cart.cartList[index].capacity} ${cart.cartList[index].unit}',
                                                                        style: poppinsRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.FONT_SIZE_SMALL))),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Provider.of<CouponProvider>(
                                                                            context,
                                                                            listen:
                                                                                false)
                                                                        .removeCouponData(
                                                                            false);
                                                                    if (cart.cartList[index]
                                                                            .quantity >
                                                                        1) {
                                                                      Provider.of<CartProvider>(context, listen: false).setQuantity(
                                                                          false,
                                                                          index,
                                                                          context);
                                                                    } else if (cart
                                                                            .cartList[index]
                                                                            .quantity ==
                                                                        1) {
                                                                      Provider.of<CartProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .removeFromCart(
                                                                              index,
                                                                              context);
                                                                    }
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            Dimensions
                                                                                .PADDING_SIZE_SMALL,
                                                                        vertical:
                                                                            Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                    child: Icon(
                                                                        Icons
                                                                            .remove,
                                                                        size:
                                                                            20,
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                                  ),
                                                                ),
                                                                Text(
                                                                    cart
                                                                        .cartList[
                                                                            index]
                                                                        .quantity
                                                                        .toString(),
                                                                    style: poppinsSemiBold.copyWith(
                                                                        fontSize:
                                                                            Dimensions
                                                                                .FONT_SIZE_EXTRA_LARGE,
                                                                        color: Theme.of(context)
                                                                            .primaryColor)),
                                                                InkWell(
                                                                  onTap: () {
                                                                    if (cart
                                                                            .cartList[
                                                                                index]
                                                                            .quantity <
                                                                        cart.cartList[index]
                                                                            .stock) {
                                                                      Provider.of<CouponProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .removeCouponData(
                                                                              false);
                                                                      Provider.of<CartProvider>(context, listen: false).setQuantity(
                                                                          true,
                                                                          index,
                                                                          context);
                                                                    } else {
                                                                      showCustomSnackBar(
                                                                          getTranslated(
                                                                              'out_of_stock',
                                                                              context),
                                                                          context);
                                                                    }
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            Dimensions
                                                                                .PADDING_SIZE_SMALL,
                                                                        vertical:
                                                                            Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                                                    child: Icon(
                                                                        Icons
                                                                            .add,
                                                                        size:
                                                                            20,
                                                                        color: Theme.of(context)
                                                                            .primaryColor),
                                                                  ),
                                                                ),
                                                              ]),
                                                            ],
                                                          )),
                                                          !ResponsiveHelper
                                                                  .isMobile(
                                                                      context)
                                                              ? Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          Dimensions
                                                                              .PADDING_SIZE_SMALL),
                                                                  child:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      Provider.of<CartProvider>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .removeFromCart(
                                                                              index,
                                                                              context);
                                                                    },
                                                                    icon: Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                )
                                                              : SizedBox(),
                                                        ]),
                                                      ),
                                                    ),
                                                  ]),
                                                );
                                                /*CartProductWidget(
                                                  cartL: cart.cartList[index],
                                                  cart: null,
                                                  index: index,
                                                )*/
                                              },
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_LARGE),

                                            // Coupon
                                            Consumer<CouponProvider>(
                                              builder:
                                                  (context, coupon, child) {
                                                return Row(children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller: widget
                                                          ._couponController,
                                                      style: poppinsMedium,
                                                      decoration: InputDecoration(
                                                          hintText: getTranslated(
                                                              'enter_promo_code',
                                                              context),
                                                          hintStyle: poppinsRegular.copyWith(
                                                              color: ColorResources
                                                                  .getHintColor(
                                                                      context)),
                                                          isDense: true,
                                                          filled: true,
                                                          enabled:
                                                              coupon.discount ==
                                                                  0,
                                                          fillColor: Theme.of(context)
                                                              .cardColor,
                                                          border: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.horizontal(
                                                                      left: Radius.circular(10)),
                                                              borderSide: BorderSide.none)),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      if (widget
                                                              ._couponController
                                                              .text
                                                              .isNotEmpty &&
                                                          !coupon.isLoading) {
                                                        if (coupon.discount <
                                                            1) {
                                                          coupon
                                                              .applyCoupon(
                                                                  widget
                                                                      ._couponController
                                                                      .text,
                                                                  _total)
                                                              .then((discount) {
                                                            if (discount > 0) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                content: Text(
                                                                    'You got ${PriceConverter.convertPrice(context, discount)} discount'),
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                              ));
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                content: Text(
                                                                    getTranslated(
                                                                        'invalid_code_or_failed',
                                                                        context)),
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ));
                                                            }
                                                          });
                                                        } else {
                                                          coupon
                                                              .removeCouponData(
                                                                  true);
                                                        }
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              getTranslated(
                                                                  'enter_a_coupon_code',
                                                                  context)),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ));
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 50,
                                                      width: 100,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .horizontal(
                                                          right: Radius.circular(
                                                              Provider.of<LocalizationProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .isLtr
                                                                  ? 10
                                                                  : 0),
                                                          left: Radius.circular(
                                                              Provider.of<LocalizationProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .isLtr
                                                                  ? 0
                                                                  : 10),
                                                        ),
                                                      ),
                                                      child: coupon.discount <=
                                                              0
                                                          ? !coupon.isLoading
                                                              ? Text(
                                                                  getTranslated(
                                                                      'apply',
                                                                      context),
                                                                  style: poppinsMedium
                                                                      .copyWith(
                                                                          color:
                                                                              Colors.white),
                                                                )
                                                              : CircularProgressIndicator(
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white))
                                                          : Icon(Icons.clear,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                  ),
                                                ]);
                                              },
                                            ),
                                            SizedBox(
                                                height: Dimensions
                                                    .PADDING_SIZE_LARGE),

                                            // Order type
                                            _isSelfPickupActive
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                        Text(
                                                            getTranslated(
                                                                'delivery_option',
                                                                context),
                                                            style: poppinsMedium
                                                                .copyWith(
                                                                    fontSize:
                                                                        Dimensions
                                                                            .FONT_SIZE_LARGE)),
                                                        DeliveryOptionButton(
                                                            value: 'delivery',
                                                            title:
                                                                getTranslated(
                                                                    'delivery',
                                                                    context),
                                                            kmWiseFee:
                                                                _kmWiseCharge),
                                                        DeliveryOptionButton(
                                                            value:
                                                                'self_pickup',
                                                            title: getTranslated(
                                                                'self_pickup',
                                                                context),
                                                            kmWiseFee:
                                                                _kmWiseCharge),
                                                        SizedBox(
                                                            height: Dimensions
                                                                .PADDING_SIZE_LARGE),
                                                      ])
                                                : SizedBox(),

                                            // Total
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      getTranslated(
                                                          'items_price',
                                                          context),
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE)),
                                                  Text(
                                                      PriceConverter
                                                          .convertPrice(context,
                                                              _itemPrice),
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE)),
                                                ]),
                                            SizedBox(height: 10),

                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      getTranslated(
                                                          'tax', context),
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE)),
                                                  Text(
                                                      '(+) ${PriceConverter.convertPrice(context, _tax)}',
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE)),
                                                ]),
                                            SizedBox(height: 10),

                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      getTranslated(
                                                          'discount', context),
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE)),
                                                  Text(
                                                      '(-) ${PriceConverter.convertPrice(context, _discount)}',
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE)),
                                                ]),
                                            SizedBox(height: 10),

                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      getTranslated(
                                                          'coupon_discount',
                                                          context),
                                                      style: poppinsRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .FONT_SIZE_LARGE)),
                                                  Text(
                                                    '(-) ${PriceConverter.convertPrice(context, Provider.of<CouponProvider>(context).discount)}',
                                                    style:
                                                        poppinsRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .FONT_SIZE_LARGE),
                                                  ),
                                                ]),
                                            SizedBox(height: 10),

                                            _kmWiseCharge
                                                ? SizedBox()
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                        Text(
                                                          getTranslated(
                                                              'delivery_fee',
                                                              context),
                                                          style: poppinsRegular
                                                              .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .FONT_SIZE_LARGE),
                                                        ),
                                                        Text(
                                                          '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                                                          style: poppinsRegular
                                                              .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .FONT_SIZE_LARGE),
                                                        ),
                                                      ]),

                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: Dimensions
                                                      .PADDING_SIZE_SMALL),
                                              child: CustomDivider(),
                                            ),

                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      getTranslated(
                                                          _kmWiseCharge
                                                              ? 'subtotal'
                                                              : 'total_amount',
                                                          context),
                                                      style: poppinsMedium
                                                          .copyWith(
                                                        fontSize: Dimensions
                                                            .FONT_SIZE_EXTRA_LARGE,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      )),
                                                  Text(
                                                    PriceConverter.convertPrice(
                                                        context, _total),
                                                    style: poppinsMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .FONT_SIZE_EXTRA_LARGE,
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                  ),
                                                ]),
                                          ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 1170,
                              padding:
                                  EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                              child: CustomButton(
                                buttonText:
                                    getTranslated('continue_checkout', context),
                                onPressed: () {
                                  if (_itemPrice <
                                      Provider.of<SplashProvider>(context,
                                              listen: false)
                                          .configModel
                                          .minimumOrderValue) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                            content: Text(
                                              'Minimum order amount is ${PriceConverter.convertPrice(context, Provider.of<SplashProvider>(context, listen: false).configModel.minimumOrderValue)}, you have ${PriceConverter.convertPrice(context, _itemPrice)} in your cart, please add more item.',
                                            ),
                                            backgroundColor: Colors.red));
                                  } else {
                                    String _orderType =
                                        Provider.of<OrderProvider>(context,
                                                listen: false)
                                            .orderType;
                                    double _discount =
                                        Provider.of<CouponProvider>(context,
                                                listen: false)
                                            .discount;
                                    Navigator.pushNamed(
                                      context,
                                      RouteHelper.getCheckoutRoute(
                                        _total,
                                        _discount,
                                        _orderType,
                                        Provider.of<CouponProvider>(context,
                                                listen: false)
                                            .code,
                                      ),
                                      arguments: CheckoutScreen(
                                        amount: _total,
                                        orderType: _orderType,
                                        discount: _discount,
                                        couponCode: Provider.of<CouponProvider>(
                                                context,
                                                listen: false)
                                            .code,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        )
                      : NoDataScreen(isCart: true);
                },
              ),
      ),
    );
  }
}


  

  
/**/