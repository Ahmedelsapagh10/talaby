enum UserRole { admin, staff, customer }

extension UserRoleCodec on UserRole {
  String get value => name;

  bool get canManageStore => this == UserRole.admin || this == UserRole.staff;

  static UserRole? fromValue(Object? value) {
    for (final role in UserRole.values) {
      if (role.name == value) return role;
    }
    return null;
  }
}
