import 'package:flutter/material.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'product_edit_screen.dart';

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;
  final ProductProvider productProvider;

  ProductSearchDelegate(this.products, this.productProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final filteredProducts = query.isEmpty
        ? products
        : products
        .where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (product.imageUrl.isNotEmpty)
                ? NetworkImage(product.imageUrl)
                : const AssetImage('assets/placeholder.png') as ImageProvider,
          ),
          title: Text(product.name),
          subtitle:
          Text('Our Price: ${product.ourPrice} | Stock: ${product.stock}'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductEditScreen(product: product),
                ),
              );
            },
          ),
          onTap: () {
            close(context, product);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductEditScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}