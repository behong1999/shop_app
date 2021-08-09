import 'package:NewtypeS/providers/products.dart';
import 'package:NewtypeS/screens/edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed(
                EditProductScreen.routeName,
                arguments: id,
              ),
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
              ),
              color: Theme.of(context).errorColor,
              onPressed: () async {
                return showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(
                      'Confirm',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Are You Sure You Want To Delete This Product From The List?',
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DeleteProductButton(id: id),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: Text('CANCEL',
                                style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.grey),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteProductButton extends StatefulWidget {
  const DeleteProductButton({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;

  @override
  _DeleteProductButtonState createState() => _DeleteProductButtonState();
}

class _DeleteProductButtonState extends State<DeleteProductButton> {
  var _inProgress = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: _inProgress
          ? SizedBox(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
              width: 10,
              height: 10,
            )
          : Text(
              'DELETE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all(Size.fromWidth(80)),
        backgroundColor:
            MaterialStateProperty.all(Theme.of(context).primaryColor),
      ),
      onPressed: () async {
        setState(() {
          _inProgress = true;
        });
        try {
          await Provider.of<Products>(
            context,
            listen: false,
          ).deleteProduct(widget.id);
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 8),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.system_security_update_warning_rounded,
                      color: Colors.orange),
                  Text(' FAILED TO DELETE '),
                  Icon(Icons.system_security_update_warning_rounded,
                      color: Colors.orange)
                ],
              ),
            ),
          );
        }

        //* Close The Dialog Box when finishing deleting the product or failing to delete
        Navigator.of(context).pop();

        _inProgress = false;
      },
    );
  }
}
