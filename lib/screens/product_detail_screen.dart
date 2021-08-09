import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // final double price;
  // ProductDetailScreen(
  //   this.title,
  //   this.price,
  // );
  static const routeName = 'product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)!.settings.arguments as String;

    //ANCHOR: Provider.of<Products>(context).items.firstWhere((product) => product.id == productId);
    //! Set listen to false which is true in default to avoid rebuilding the widget when the data changes
    //! Hence, notifyListener won't be called
    final detailedProduct =
        Provider.of<Products>(context, listen: false).searchById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: SingleChildScrollView(
      //       scrollDirection: Axis.horizontal,
      //       child: Text(detailedProduct.title)),
      // ),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 350,
          flexibleSpace: FlexibleSpaceBar(
            title: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20)),
                  color: Colors.black26),
              child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Text(
                  detailedProduct.title,
                  // textAlign: TextAlign.center,
                ),
              ),
            ),
            background: Hero(
              tag: detailedProduct.title,
              child: Image.network(
                detailedProduct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          SizedBox(
            height: 10,
          ),
          Text(
            '\$${detailedProduct.price}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
          ),
          Divider(
            thickness: 1,
          ),
          Text(
            'DESCRIPTION',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Text(
              detailedProduct.description,
              softWrap: true,
              style: TextStyle(),
            ),
          ),
          //* Testing Sliver App Bar
          SizedBox(height: 600),
        ])),
      ]),
    );
  }
}
