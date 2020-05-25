import 'package:flutter/material.dart';
import '../providers/product_provider.dart';

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

  var _product = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  @override
  void initState() {
    super.initState();

    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
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

  void _saveForm() {
    _form.currentState.save();
    print(_product.title);
    print(_product.price);
    print(_product.description);
    print(_product.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  onSaved: (value) {
                    _product = Product(
                      id: _product.id,
                      title: value,
                      description: _product.description,
                      price: _product.price,
                      imageUrl: _product.imageUrl,
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (value) {
                    _product = Product(
                      id: _product.id,
                      title: _product.title,
                      description: _product.description,
                      price: double.parse(value),
                      imageUrl: _product.imageUrl,
                    );
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  focusNode: _descriptionFocusNode,
                  onSaved: (value) {
                    _product = Product(
                      id: _product.id,
                      title: _product.title,
                      description: value,
                      price: _product.price,
                      imageUrl: _product.imageUrl,
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
                      child: _imageUrlController.text.isEmpty
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
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        onSaved: (value) {
                          _product = Product(
                            id: _product.id,
                            title: _product.title,
                            description: _product.description,
                            price: _product.price,
                            imageUrl: value,
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
