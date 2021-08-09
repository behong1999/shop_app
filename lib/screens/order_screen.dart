import 'package:NewtypeS/providers/orders.dart' show Orders;
import 'package:NewtypeS/screens/products_overview_screen.dart';
import 'package:NewtypeS/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:NewtypeS/widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';

//   @override
//   _OrderScreenState createState() => _OrderScreenState();
// }

// class _OrderScreenState extends State<OrderScreen> {
//   var _isLoading = false;
//   @override
//   void initState() {
//   Future.delayed(Duration.zero).then((_) async {
//   setState(() {
//   _isLoading = true;
//   });
//   //? listen: false` is necessary to be able to call `Provider.of` inside [State.initState]
//   Provider.of<Orders>(context, listen: false).setAndFetchOrders().then((_) {
//     setState(() {
//     _isLoading = false;
//     });
//   });
//   });
// }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).setAndFetchOrders(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );

          if (snapshot.error != null) {
            print(snapshot.error);
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No Order Found!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    textAlign: TextAlign.center),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProductsOverviewScreen())),
                    child: Text('GO TO SHOP'))
              ],
            ));
          } else {
            return Consumer<Orders>(
              builder: (context, orderData, child) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (context, index) =>
                    OrderItem(orderData.orders[index]),
              ),
            );
          }
        },
      ),
    );
  }
}
