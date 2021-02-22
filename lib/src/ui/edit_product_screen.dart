import 'package:ecom/src/common/providers/individual_product_provider.dart';

import 'package:ecom/src/common/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/editProductScreen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final TextEditingController _imageUrlController = TextEditingController();
  final FocusNode _imageUrlFocusNode = FocusNode();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  IndividualProduct _editedProduct = IndividualProduct(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  Map<String, String> _initValues = <String, String>{
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String _productId =
          ModalRoute.of(context).settings.arguments as String;

      if (_productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(_productId);

        _initValues = <String, String>{
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
          // _editedProduct.imageUrl,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.contains('.png') &&
              !_imageUrlController.text.contains('.jpg') &&
              !_imageUrlController.text.contains('.jpeg'))) {
        return;
      }
    }
    setState(() {});
  }

  Future<void> _saveForm() async {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<void>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Okay'),
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  Text _title() {
    if (_editedProduct.id == null) {
      return const Text('Add New Product');
    } else {
      return const Text('Edit Product');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        _editedProduct = IndividualProduct(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: value,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a number greater than 0';
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        _editedProduct = IndividualProduct(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Please enter a description';
                        }

                        if (value.length < 10) {
                          return 'Should be at least 10 characters long';
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        _editedProduct = IndividualProduct(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 8, right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a URL')
                              : FittedBox(
                                  fit: BoxFit.cover,
                                  child: Image.network(
                                    _imageUrlController.text,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // initialValue: _initValues['imageUrl'],
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please enter an image URL';
                              }

                              if (value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please enter a valid image URL';
                              }
                              if (!value.contains('.png') &&
                                  !value.contains('.jpg') &&
                                  !value.contains('.jpeg')) {
                                return 'Please enter a valid image URL';
                              }
                              return null;
                            },
                            onSaved: (String value) {
                              _editedProduct = IndividualProduct(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
