import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../models/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _edittedProduct =
      Product(id: '', title: '', description: '', price: 0, imageUrl: '');
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
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        final product = Provider.of<Products>(context, listen: false)
            .findById(productId as String);
        _edittedProduct = product;
        _initValues = {
          'title': _edittedProduct.title,
          'description': _edittedProduct.description,
          'price': _edittedProduct.price.toString(),
          'imageUrl': ''
        };
        _imageUrlController.text = _edittedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    setState(() {
      _isLoading = true;
    });
    final isValid = _form.currentState?.validate();
    if (!isValid!) return;
    _form.currentState?.save();
    if (_edittedProduct.id.isEmpty) {
      Provider.of<Products>(context, listen: false)
          .addProduct(_edittedProduct)
          .catchError((error) {
        return showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error accoured !'),
            content: const Text('Somthing went wrong !'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Okay'))
            ],
          ),
        );
      }).then((res) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    } else {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_edittedProduct.id, _edittedProduct)
          .then((res) {
        setState(() {
          _isLoading = false;
        });
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        onSaved: (value) {
                          _edittedProduct = Product(
                              id: _edittedProduct.id,
                              title: value!,
                              description: _edittedProduct.description,
                              price: _edittedProduct.price,
                              imageUrl: _edittedProduct.imageUrl,
                              isFavorite: _edittedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: const InputDecoration(labelText: 'Price'),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Price is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please entre a valide number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please entre a number greater then zero';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          _edittedProduct = Product(
                              id: _edittedProduct.id,
                              title: _edittedProduct.title,
                              description: _edittedProduct.description,
                              price: double.parse(value!),
                              imageUrl: _edittedProduct.imageUrl,
                              isFavorite: _edittedProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.multiline,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Description is required';
                          }
                          if (value.length < 10) {
                            return 'Should be at least 10 chars';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _edittedProduct = Product(
                              id: _edittedProduct.id,
                              title: _edittedProduct.title,
                              description: value!,
                              price: _edittedProduct.price,
                              imageUrl: _edittedProduct.imageUrl,
                              isFavorite: _edittedProduct.isFavorite);
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? const Text('Entre Image URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                  label: Text('Image URL')),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'imageUrl is required';
                                }
                                if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please entre a valid image URL';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (value) {
                                _edittedProduct = Product(
                                    id: _edittedProduct.id,
                                    title: _edittedProduct.title,
                                    description: _edittedProduct.description,
                                    price: _edittedProduct.price,
                                    imageUrl: value!,
                                    isFavorite: _edittedProduct.isFavorite);
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
