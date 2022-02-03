import 'package:NewtypeS/providers/cart.dart';
import 'package:NewtypeS/providers/products.dart';
import 'package:NewtypeS/screens/cart_screen.dart';
import 'package:NewtypeS/widgets/app_drawer.dart';
import 'package:NewtypeS/widgets/badge.dart';
import 'package:NewtypeS/widgets/products_grid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showOnlyFavorites = false;
  bool _isInit = true;
  bool _isLoading = true;

  Future<void> _refresh(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  void initState() {
    /**  
      * *Read More: https://stackoverflow.com/questions/49457717/flutter-get-context-in-initstate-method/49458289#49458289
      
      * ! You cannot use BuildContext.dependOnInheritedWidgetOfExactType from this method. 
      * * However, didChangeDependencies will be called immediately following this method, 
      * * and BuildContext.dependOnInheritedWidgetOfExactType can be used there.
    */

    //ANCHOR: This is regitered as a to-do action. //? Alternative Way
    // Future.delayed(Duration.zero)
    //     .then((_) =>
    //         Provider.of<Products>(context, listen: false).fetchAndSetProducts())
    //     .then((_) => _isLoading = false);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = true;
      Provider.of<Products>(context).fetchAndSetProducts().then(
            (_) => _isLoading = false,
          );
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NewTypeS'),
        actions: [
          PopupMenuButton(
              shape: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1)),
              onSelected: (FilterOptions selectedValue) {
                print(selectedValue);
                setState(() {
                  if (selectedValue == FilterOptions.Favorites) {
                    // products.showFavorites();
                    _showOnlyFavorites = true;
                  } else {
                    // products.showAll();
                    _showOnlyFavorites = false;
                  }
                });
              },
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Only Favorites'),
                      value: FilterOptions.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOptions.All,
                    )
                  ]),
          Consumer<Cart>(
            builder: (_, cart, childWidget) => Badge(
              child: childWidget as Widget,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: Icon(Icons.shopping_cart_sharp)),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ProductGrids(_showOnlyFavorites),
      ),
    );
  }
}
