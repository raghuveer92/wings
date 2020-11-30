import 'package:backendless_sdk/backendless_sdk.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:wings/screens/address/add_address.dart';
import 'package:wings/screens/address/addresses.dart';
import 'package:wings/screens/authenticate/my_profile.dart';
import 'package:wings/screens/authenticate/register.dart';
import 'package:wings/screens/authenticate/sign_in.dart';
import 'package:wings/screens/base/base_stateful_screen.dart';
import 'package:wings/screens/cart/cart_items.dart';
import 'package:wings/screens/cart/place_order.dart';
import 'package:wings/screens/category/add_category.dart';
import 'package:wings/screens/category/categories.dart';
import 'package:wings/screens/home/home.dart';
import 'package:wings/screens/home/items_by_category.dart';
import 'package:wings/screens/home/items_details.dart';
import 'package:wings/screens/image/full_Image.dart';
import 'package:wings/screens/itemColors/add_color.dart';
import 'package:wings/screens/itemColors/item_colors.dart';
import 'package:wings/screens/items/add_item.dart';
import 'package:wings/screens/items/items.dart';
import 'package:wings/screens/order/my_orders.dart';
import 'package:wings/screens/order/order_details.dart';
import 'package:wings/screens/splash/splash_screen.dart';
import 'package:wings/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(MyApp());
  Backendless.setUrl("https://api.backendless.com");
  Backendless.initApp("A7022B68-A0C2-4C72-FFB3-7CF208A05A00", "DE798394-E6D1-41BF-936C-15099A9E4259", "571C46F9-B572-4BBE-8F9F-17CCDED01643");
  Backendless.initWebApp("A7022B68-A0C2-4C72-FFB3-7CF208A05A00", "92DA0FCC-7D87-42FA-865D-58021BD3324B");
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends BaseState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) => Home(),
        '/login': (context) => SignIn(),
        '/signUp': (context) => Register(),
        '/myProfile': (context) => MyProfile(),
        '/myOrders': (context) => MyOrders(),
        '/categories': (context) => Categories(),
        '/addCategories': (context) => AddCategory(),
        '/updateCategories': (context) => AddCategory(
              categoryId: ModalRoute.of(context).settings.arguments,
            ),
        '/products': (context) => Items(),
        '/addProduct': (context) => AddItem(),
        '/updateProduct': (context) => AddItem(
              itemId: ModalRoute.of(context).settings.arguments,
            ),
        '/productsByCategory': (context) => ItemsByCategory(
              categoryId: ModalRoute.of(context).settings.arguments,
            ),
        '/product': (context) => ItemsDetails(
              itemId: ModalRoute.of(context).settings.arguments,
            ),
        '/cartItems': (context) => CartItems(),
        '/addresses': (context) => Addresses(),
        '/addAddress': (context) => AddAddress(),
        '/updateAddress': (context) => AddAddress(
              addressId: ModalRoute.of(context).settings.arguments,
            ),
        '/orderDetails': (context) => OrderDetails(
              orderId: ModalRoute.of(context).settings.arguments,
            ),
        '/orders': (context) => MyOrders(),
        '/productColors': (context) => ItemColors(
              itemId: ModalRoute.of(context).settings.arguments,
            ),
        '/addProductColor': (context) => AddColor(),
        '/updateProductColor': (context) => AddColor(
              colorId: ModalRoute.of(context).settings.arguments,
            ),
        '/fullImage': (context) => FullImage(
              image: ModalRoute.of(context).settings.arguments,
            ),
        '/placeOrder': (context) => PlaceOrder(),
      },
      title: 'Wings',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        appBarTheme: AppBarTheme(
          brightness: Brightness.light,
          color: AppColors.appBarColor,
        ),
        accentIconTheme: Theme.of(context).accentIconTheme.copyWith(color: Colors.white),
        primaryColor: AppColors.primaryColor,
        primaryColorDark: AppColors.primaryDarkColor,
        accentColor: AppColors.accentColor,
        buttonColor: AppColors.primaryColor,
        scaffoldBackgroundColor: AppColors.windowBackground,
        backgroundColor: AppColors.windowBackground,
        hintColor: AppColors.hintColor,
        primaryIconTheme: Theme.of(context).primaryIconTheme.copyWith(color: AppColors.titleTextColor),
        primaryTextTheme: Theme.of(context).primaryTextTheme.apply(fontFamily: 'GothamRounded', bodyColor: AppColors.titleTextColor),
        textTheme: Theme.of(context).primaryTextTheme.apply(fontFamily: 'GothamRounded', bodyColor: AppColors.titleTextColor),
      ),
      home: SplashScreen(),
    );
  }
}
