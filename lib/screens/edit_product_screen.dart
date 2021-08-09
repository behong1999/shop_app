import 'package:NewtypeS/providers/product.dart';
import 'package:NewtypeS/providers/products.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();

  //* Create a global key that uniquely identifies the Form widget
  //* and allows validation of the form.
  final _form = GlobalKey<FormState>();

  var _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    //* Load Product Whose Id equal to the productId for the first time
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;

      //NOTE: Check if the user wants to edit the product's information
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .searchById(productId as String);

        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  //NOTE: The function is executed whenever the focus changes
  void updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;
    _form.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != '') {
      await Provider.of<Products>(context, listen: false).updateProduct(
        _editedProduct.id,
        _editedProduct,
      );
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('An Error Occured!'),
              //* Firebase might provide error messages containing confidential information
              // content: Text(error.toString()),
              content: Text('Something Went Wrong!'),
              actions: [
                TextButton(
                    onPressed: () {
                      //* This line pops the dialog box only
                      Navigator.of(context).pop();
                    },
                    child: Text('Okay'))
              ],
            );
          },
        );
      }
    }
    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  //NOTE: We need to dispose the focus node when the state gets cleared
  @override
  void dispose() {
    // TODO: implement dispose
    _imageUrlFocusNode.removeListener(updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedProduct.id == '' ? 'Add Product' : 'Edit Product'),
        actions: [IconButton(onPressed: _save, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _editedProduct.title,
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter A Title';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          //! The properties are final
                          //! so it cannot be reassigned
                          //! Hence, we need to set this equal to a new product and override
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              isFavorite: _editedProduct.isFavorite,
                              title: value!,
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl);
                        },
                      ),
                      TextFormField(
                        initialValue: _editedProduct.price.toString(),
                        decoration: InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter A Price';
                          }
                          if (double.tryParse(value) == null)
                            return "Please Enter A Valid Number";
                          if (double.parse(value) <= 0)
                            return "Price cannot be 0 or Negative!";
                          return null;
                        },
                        onSaved: (value) => _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(value!),
                            imageUrl: _editedProduct.imageUrl),
                      ),
                      TextFormField(
                        initialValue: _editedProduct.description,
                        decoration: InputDecoration(labelText: 'Description'),
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Description';
                          }
                          if (value.length < 5)
                            return "Too Short! Must Be At Least 10 Characters Length.";
                          return null;
                        },
                        onSaved: (value) => _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: value!,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl),
                        onFieldSubmitted: (_) {},
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(
                              top: 10,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            )),
                            child: _imageUrlController.text.isEmpty
                                ? Text(
                                    'Enter an URL',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  )
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              //! CANNOT USE INITIAL VALUE AND CONTROLLER SIMULTANEOUSLY
                              // initialValue: _editedProduct.imageUrl,
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              focusNode: _imageUrlFocusNode,
                              controller: _imageUrlController,
                              onFieldSubmitted: (_) => _save(),
                              validator: (value) {
                                if (_imageUrlController.text.isEmpty)
                                  return 'Please Enter A URL';

                                if (!_imageUrlController.text
                                        .startsWith('http') &&
                                    !_imageUrlController.text
                                        .startsWith('https'))
                                  return 'Please Enter A Valid URL.';

                                if (!_imageUrlController.text
                                        .endsWith('.png') &&
                                    !_imageUrlController.text
                                        .endsWith('.jpg') &&
                                    !_imageUrlController.text
                                        .endsWith('.jpeg')) {
                                  return "The Image URL Is Not Valid!";
                                }
                              },
                              onSaved: (value) => _editedProduct = Product(
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: value!),
                            ),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
