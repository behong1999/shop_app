import 'package:NewtypeS/providers/auth.dart';
import 'package:NewtypeS/providers/cart.dart';
import 'package:NewtypeS/providers/orders.dart';
import 'package:NewtypeS/screens/auth_screen.dart';
import 'package:NewtypeS/screens/cart_screen.dart';
import 'package:NewtypeS/screens/edit_product_screen.dart';
import 'package:NewtypeS/screens/order_screen.dart';
import 'package:NewtypeS/screens/splash_screen.dart';
import 'package:NewtypeS/screens/user_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'animation/custom_route.dart';
import 'providers/products.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          //* ChangeNotifierProvider is a specific type of Provider
          //* which will listen to the object and rebuild its dependent widgets
          //* when this object has been updated.
          ChangeNotifierProvider<Auth>.value(value: Auth()),

          //* This will be rebuilt when Auth object changes
          //? The first argument is the class or the type of data we DEPEND ON, the second is the class that we PROVIDE
          //! When this one gets rebuilt, it will create new instance but we don't want to lose the previous data
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products('', '', []),
            update: (context, auth, previousProducts) =>
                Products(auth.token, auth.userId, previousProducts!.items),
          ),

          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),

          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('', '', []),
            update: (context, auth, previousOrders) =>
                Orders(auth.token, auth.userId, previousOrders!.orders),
          ),

          //* Provider of Orders
          // ChangeNotifierProvider(
          //   create: (context) => Orders(),
          // )
        ],
        //*
        //* This ensures that the MaterialApp is rebuilt whenever auth object changes or we call notifyListener
        //*
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
            title: 'NewTypeS',
            theme: ThemeData(
                primarySwatch: Colors.pink,
                accentColor: Colors.red.shade800,
                fontFamily: 'Lato',
                pageTransitionsTheme: PageTransitionsTheme(builders: {
                  TargetPlatform.android: CustomPageTransitionBuild(),
                  TargetPlatform.iOS: CustomPageTransitionBuild()
                })),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen();
                    },
                  ),
            // initialRoute: '/',
            routes: {
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) => CartScreen(),
              OrderScreen.routeName: (context) => OrderScreen(),
              UserProductsScreen.routeName: (context) => UserProductsScreen(),
              EditProductScreen.routeName: (context) => EditProductScreen(),
            },
          ),
        ));
  }
}
