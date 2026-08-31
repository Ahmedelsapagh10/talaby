import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../customers/data/customer_repository.dart';
import 'admin_customers_state.dart';

class AdminCustomersCubit extends Cubit<AdminCustomersState> {
  AdminCustomersCubit(this._repository) : super(const AdminCustomersState());

  final CustomerRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loadingMore = false;

  Future<void> load() async {
    emit(const AdminCustomersState(status: AdminCustomersStatus.loading));
    try {
      final page = await _repository.getCustomers();
      _cursor = page.nextCursor;
      emit(
        AdminCustomersState(
          status: page.customers.isEmpty
              ? AdminCustomersStatus.empty
              : AdminCustomersStatus.success,
          customers: page.customers,
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || _cursor == null) return;
    _loadingMore = true;
    try {
      final page = await _repository.getCustomers(after: _cursor);
      _cursor = page.nextCursor;
      emit(
        AdminCustomersState(
          status: AdminCustomersStatus.success,
          customers: [...state.customers, ...page.customers],
          hasMore: page.hasMore,
        ),
      );
    } catch (error) {
      _emitFailure(error);
    } finally {
      _loadingMore = false;
    }
  }

  void _emitFailure(Object error) {
    emit(
      AdminCustomersState(
        status: AdminCustomersStatus.failure,
        customers: state.customers,
        hasMore: state.hasMore,
        message: error.toString(),
      ),
    );
  }
}
