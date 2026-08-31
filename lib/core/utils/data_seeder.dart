import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../../features/catalog/data/models/category.dart';
import '../../features/catalog/data/models/product.dart';
import '../config/app_config.dart';
import '../firebase/firestore_paths.dart';

class DataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedData() async {
    try {
      debugPrint('Starting data seeding...');
      final ownerId = AppConfig.ownerId;

      // 1. Seed Categories
      final categoriesRef = _firestore.collection(FirestorePaths.categories);
      final productsRef = _firestore.collection(FirestorePaths.products);

      // Delete existing categories and products (optional, for clean slate)
      // We will just add new ones for now to avoid accidental deletion

      final Map<String, Category> createdCategories = {};

      final categoriesToCreate = [
        {
          'name': 'Burgers',
          'imageUrl':
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
          'sortOrder': 1,
        },
        {
          'name': 'Pizza',
          'imageUrl':
              'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&q=80',
          'sortOrder': 2,
        },
        {
          'name': 'Drinks',
          'imageUrl':
              'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&q=80',
          'sortOrder': 3,
        },
      ];

      for (final catData in categoriesToCreate) {
        final doc = categoriesRef.doc();
        final category = Category(
          id: doc.id,
          name: catData['name'] as String,
          imageUrl: catData['imageUrl'] as String,
          sortOrder: catData['sortOrder'] as int,
        );
        await doc.set(category.toMap());
        createdCategories[category.name] = category;
      }

      // 2. Seed Products
      final productsToCreate = [
        {
          'name': 'Classic Beef Burger',
          'category': 'Burgers',
          'price': 150,
          'image':
              'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80',
          'desc':
              'Juicy beef patty with fresh lettuce, tomatoes, and our signature sauce.',
        },
        {
          'name': 'Double Cheese Burger',
          'category': 'Burgers',
          'price': 190,
          'image':
              'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=800&q=80',
          'desc': 'Two beef patties layered with melted cheddar cheese.',
        },
        {
          'name': 'Crispy Chicken Burger',
          'category': 'Burgers',
          'price': 160,
          'image':
              'https://images.unsplash.com/photo-1615719413546-198b25453f85?w=800&q=80',
          'desc': 'Crispy fried chicken breast with mayo and pickles.',
        },
        {
          'name': 'Margherita Pizza',
          'category': 'Pizza',
          'price': 200,
          'image':
              'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800&q=80',
          'desc': 'Classic pizza with fresh mozzarella, tomatoes, and basil.',
        },
        {
          'name': 'Pepperoni Pizza',
          'category': 'Pizza',
          'price': 250,
          'image':
              'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=800&q=80',
          'desc': 'Loaded with pepperoni and extra cheese.',
        },
        {
          'name': 'Fresh Cola',
          'category': 'Drinks',
          'price': 50,
          'image':
              'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80',
          'desc': 'Ice cold refreshing cola.',
        },
        {
          'name': 'Orange Juice',
          'category': 'Drinks',
          'price': 80,
          'image':
              'https://images.unsplash.com/photo-1613478223719-2ab802602423?w=800&q=80',
          'desc': 'Freshly squeezed orange juice.',
        },
      ];

      for (final prodData in productsToCreate) {
        final doc = productsRef.doc();
        final categoryName = prodData['category'] as String;
        final categoryId = createdCategories[categoryName]?.id;

        final product = Product(
          id: doc.id,
          ownerId: ownerId,
          name: prodData['name'] as String,
          basePrice: prodData['price'] as int,
          categoryId: categoryId,
          description: prodData['desc'] as String,
          shortDescription: prodData['desc'] as String,
          images: [prodData['image'] as String],
          active: true,
          stockControlEnabled: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await doc.set(product.toMap());
      }

      debugPrint('Data seeding completed successfully!');
    } catch (e) {
      debugPrint('Error during data seeding: $e');
    }
  }
}
