import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/products_provider.dart';

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
  final _form = GlobalKey<FormState>();
  var _isLoading = false;

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  var _product = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  var _hasBeenInitialized = false;

  @override
  void initState() {
    super.initState();

    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasBeenInitialized) {
      return;
    }

    _hasBeenInitialized = true;

    final productId = ModalRoute.of(context).settings.arguments as String;

    if (productId != null) {
      _product = Provider.of<ProductsProvider>(context, listen: false)
          .findById(productId);

      if (_product != null) {
        _initValues = {
          'title': _product.title,
          'description': _product.description,
          'price': _product.price.toString(),
          'imageUrl': '',
        };

        _imageUrlController.text = _product.imageUrl;
      }
    }
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }

      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);

    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();

    _imageUrlController.dispose();

    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();

    if (!isValid) {
      return;
    }

    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    if (_product.id == null) {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_product);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('An error occurred!'),
              content: Text('Something went wrong.'),
              actions: [
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            );
          },
        );
      }
    } else {
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_product);
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product.id == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Title'),
                        initialValue: _initValues['title'],
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Required';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _product = Product(
                            id: _product.id,
                            title: value,
                            description: _product.description,
                            price: _product.price,
                            imageUrl: _product.imageUrl,
                            isFavorite: _product.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Price'),
                        initialValue: _initValues['price'],
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Required';
                          }

                          if (double.tryParse(value) == null) {
                            return 'Must be a valid number.';
                          }

                          if (double.parse(value) < 0.01) {
                            return 'Must be greater than \$0.01';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _product = Product(
                            id: _product.id,
                            title: _product.title,
                            description: _product.description,
                            price: double.parse(value),
                            imageUrl: _product.imageUrl,
                            isFavorite: _product.isFavorite,
                          );
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Description'),
                        initialValue: _initValues['description'],
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Required';
                          }

                          if (value.length < 10) {
                            return 'Must be at least 10 characters';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _product = Product(
                            id: _product.id,
                            title: _product.title,
                            description: value,
                            price: _product.price,
                            imageUrl: _product.imageUrl,
                            isFavorite: _product.isFavorite,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            )),
                            child: _imageUrlController.text.length == 0
                                ? Text('Enter a URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Required';
                                }

                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Invalid URL';
                                }

                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Invalid URL';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                _product = Product(
                                  id: _product.id,
                                  title: _product.title,
                                  description: _product.description,
                                  price: _product.price,
                                  imageUrl: value,
                                  isFavorite: _product.isFavorite,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
