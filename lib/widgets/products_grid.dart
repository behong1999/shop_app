import 'package:NewtypeS/providers/products.dart';
import 'package:NewtypeS/widgets/product_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductGrids extends StatelessWidget {
  final bool showFavs;

  const ProductGrids(this.showFavs);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context, listen: false);
    final showProducts =
        showFavs ? productsData.favoriteItems : productsData.items;

    return OrientationBuilder(builder: (context, orientation) {
      return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: showProducts.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          value: showProducts[i],
          child: ProductItem(),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
          childAspectRatio: orientation == Orientation.portrait ? 2 / 3 : 4 / 6,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      );
    });
  }
}
