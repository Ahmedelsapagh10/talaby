import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.active = true,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final String? imageUrl;
  final bool active;
  final int sortOrder;

  factory Category.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    return Category(
      id: doc.id,
      name: map['name']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString(),
      active: map['active'] as bool? ?? true,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'imageUrl': imageUrl,
    'active': active,
    'sortOrder': sortOrder,
  };
}
