import 'package:NewtypeS/providers/auth.dart';
import 'package:NewtypeS/providers/cart.dart';
import 'package:NewtypeS/providers/product.dart';
import 'package:NewtypeS/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(
  //   this.id,
  //   this.title,
  //   this.imageUrl,
  // );

  @override
  Widget build(BuildContext context) {
    //* This line is used to call the properties
    //* of the Product object outside the Consumer
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              //* Pass the arguments. The ProductDetailScreen reads the arguments from the settings
              arguments: product.id,
            );

            //? Alternative
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) =>  ProductDetailScreen(),
            //       //? Pass the arguments as part of the RouteSettings. The
            //       //? ProductDetailScreen reads the arguments from these settings.
            //       settings: RouteSettings(
            //         arguments: product.id,
            //       ),
            //     ),
            //   );
          },
          child: Container(
            width: double.infinity,
            child: Hero(
              tag: product.title,
              child: FadeInImage(
                fit: BoxFit.cover,
                placeholder: AssetImage('assets/icon/unicorn_placeholder.jpg'),
                image: NetworkImage(
                  product.imageUrl,
                ),
              ),
            ),
          ),
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (ctx, product, _) => SizedBox(
              width: 35,
              child: IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  product.toggleFavoriteStatus(authData.token, authData.userId);
                  print('Favorite Status: ${product.isFavorite}');
                },
              ),
            ),
          ),
          backgroundColor: Colors.black87,
          title: MediaQuery.of(context).orientation == Orientation.portrait
              ? Marquee(
                  scrollAxis: Axis.horizontal,
                  text: '${product.title} ',
                  velocity: 18,
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    product.title,
                    textAlign: TextAlign.center,
                  )),
          trailing: Container(
            width: 35,
            child: IconButton(
              icon: Icon(Icons.add_shopping_cart_sharp),
              onPressed: () {
                cart.addItem(product.id, product.title, product.price);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added To Cart',
                      textAlign: TextAlign.center,
                    ),
                    duration: Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ),
                );
              },
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ),
    );
  }
}
