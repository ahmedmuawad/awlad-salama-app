import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constrants.dart';
import 'package:flutter_grocery/provider/banner_provider.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/main_app_bar.dart';
import 'package:flutter_grocery/view/base/title_widget.dart';
import 'package:flutter_grocery/view/screens/home/widget/banners_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/category_details_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/category_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/daily_item_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/product_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/sub_sub_category_view.dart';
import 'package:provider/provider.dart';

import '../../../provider/auth_provider.dart';
import '../../../provider/cart_provider.dart';

class HomeScreen extends StatelessWidget {
  Future<void> _loadData(BuildContext context, bool reload) async {
    // await Provider.of<CategoryProvider>(context, listen: false).getCategoryList(context, reload);

    await Provider.of<CategoryProvider>(context, listen: false).getCategoryList(
      context,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
      reload,
    );

    /**/

    await Provider.of<BannerProvider>(context, listen: false)
        .getBannerList(context, reload);

    await Provider.of<ProductProvider>(context, listen: false).getDailyItemList(
      context,
      reload,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
    );
    // await Provider.of<ProductProvider>(context, listen: false).getPopularProductList(context, '1', true);
    Provider.of<ProductProvider>(context, listen: false).getPopularProductList(
      context,
      '1',
      reload,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
    );
    await Provider.of<CategoryProvider>(context, listen: false).getSubCategory(
      context,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
      reload,
    );
    await Provider.of<CategoryProvider>(context, listen: false)
        .getSubSubCategory(
      context,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .languageCode,
      reload,
    );
    bool _isLogged =
        Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (_isLogged) {
      await Provider.of<CartProvider>(context, listen: false).getMyCartData(
          context,
          Provider.of<AuthProvider>(context, listen: false).getUserToken(),
          Provider.of<LocalizationProvider>(context, listen: false)
              .locale
              .languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    _loadData(context, false);
    print('');
    return RefreshIndicator(
      onRefresh: () async {
        await _loadData(context, true);
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: Scaffold(
        appBar: ResponsiveHelper.isDesktop(context) ? MainAppBar() : null,
        body: Scrollbar(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    // controller: _scrollController,
                    children: [
                      Consumer<BannerProvider>(
                          builder: (context, banner, child) {
                        return banner.bannerList == null
                            ? BannersView()
                            : banner.bannerList.length == 0
                                ? SizedBox()
                                : BannersView();
                      }),

                      // Category
                      Consumer<CategoryProvider>(
                          builder: (context, category, child) {
                        return category.categoryList == null
                            ? CategoryView()
                            : category.categoryList.length == 0
                                ? SizedBox()
                                : CategoryView();
                      }),

                      Consumer<CategoryProvider>(
                          builder: (context, category, child) {
                        return category.subCategoryData == null
                            ? CategoryDetails()
                            : category.subCategoryData.length == 0
                                ? SizedBox()
                                : CategoryDetails();
                      }),
                      Consumer<CategoryProvider>(
                          builder: (context, category, child) {
                        return category.ssHomecate == null
                            ? SubSubCategory()
                            : category.ssHomecate.length == 0
                                ? SizedBox()
                                : SubSubCategory();
                      }),
                      // Category
                      Consumer<ProductProvider>(
                          builder: (context, product, child) {
                        return product.dailyItemList == null
                            ? DailyItemView()
                            : product.dailyItemList.length == 0
                                ? SizedBox()
                                : DailyItemView();
                      }),

                      // Popular Item
                      Padding(
                        padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        child: TitleWidget(
                            title: getTranslated('popular_item', context)),
                      ),
                      ProductView(
                          productType: ProductType.POPULAR_PRODUCT,
                          scrollController: _scrollController),
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
