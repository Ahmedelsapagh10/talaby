class ProductColor {
  const ProductColor({
    required this.id,
    required this.name,
    required this.hex,
    this.imageUrls = const [],
  });

  final String id;
  final String name;
  final String hex;
  final List<String> imageUrls;

  factory ProductColor.fromMap(Map<String, dynamic> map) => ProductColor(
    id: map['id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    hex: map['hex']?.toString() ?? '',
    imageUrls: List<String>.from(map['imageUrls'] as List? ?? const []),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'hex': hex,
    'imageUrls': imageUrls,
  };
}
