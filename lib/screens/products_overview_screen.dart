import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/products_grid.dart';
import '../widgets/product_item.dart';
import '../widgets/badge.dart';
import '../widgets/app_drawer.dart';
import '../models/product.dart';
import '../providers/cart.dart';
import '../screens/cart_screen.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductsOverViewScreen extends StatefulWidget {
  @override
  State<ProductsOverViewScreen> createState() => _ProductsOverViewScreenState();
}

class _ProductsOverViewScreenState extends State<ProductsOverViewScreen> {
  var _showFavoritesOnly = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showFavoritesOnly = true;
                } else {
                  _showFavoritesOnly = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              const PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, child) => CustomBadge(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: const Icon(Icons.shopping_cart),
              ),
              value: cart.itemCount.toString(),
              color: Colors.red,
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showFavoritesOnly),
    );
  }
}
