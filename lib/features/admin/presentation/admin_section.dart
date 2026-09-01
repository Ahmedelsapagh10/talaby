enum AdminSection {
  overview('/admin'),
  orders('/admin/orders'),
  products('/admin/products'),
  categories('/admin/categories'),
  customers('/admin/customers'),
  reviews('/admin/reviews'),
  settings('/admin/settings');

  const AdminSection(this.route);

  final String route;

  bool get isMore => switch (this) {
    AdminSection.customers ||
    AdminSection.reviews ||
    AdminSection.settings ||
    AdminSection.categories => true,
    _ => false,
  };
}
