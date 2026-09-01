import 'package:flutter/material.dart';

import '../../../catalog/data/models/discount.dart';
import '../../../catalog/data/models/product.dart';

class ProductFormFields {
  final name = TextEditingController();
  final shortDescription = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final oldPrice = TextEditingController();
  final discount = TextEditingController(text: '0');
  final sku = TextEditingController();
  final stock = TextEditingController(text: '0');
  final sizes = TextEditingController();

  void fill(Product? product) {
    if (product == null) return;
    name.text = product.name;
    shortDescription.text = product.shortDescription;
    description.text = product.description;
    price.text = (product.basePrice / 100).toStringAsFixed(2);
    oldPrice.text = product.oldPrice == null
        ? ''
        : (product.oldPrice! / 100).toStringAsFixed(2);
    discount.text = product.discount.type == DiscountType.percentage
        ? (product.discount.value / 100).toStringAsFixed(2)
        : (product.discount.value / 100).toStringAsFixed(2);
    sku.text = product.sku;
    stock.text = product.stock.toString();
    sizes.text = product.sizes.join(', ');
  }

  void dispose() {
    for (final controller in [
      name,
      shortDescription,
      description,
      price,
      oldPrice,
      discount,
      sku,
      stock,
      sizes,
    ]) {
      controller.dispose();
    }
  }
}
