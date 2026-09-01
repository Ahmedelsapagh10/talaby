enum ProductSort { defaultOrder, newest }

class CatalogQuery {
  const CatalogQuery({
    this.categoryId,
    this.featured,
    this.searchQuery,
    this.sort = ProductSort.defaultOrder,
  });

  final String? categoryId;
  final bool? featured;
  final String? searchQuery;
  final ProductSort sort;
}
