import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../customers/data/customer_repository.dart';
import 'admin_customers_state.dart';

class AdminCustomersCubit extends Cubit<AdminCustomersState> {
  AdminCustomersCubit(this._repository) : super(const AdminCustomersState());

  final CustomerRepository _repository;
  DocumentSnapshot<Map<String, dynamic>>? _cursor;
  bool _loadingMore = false;
  bool _searchPrepared = false;

  Future<void> load({String? query}) async {
    final searchQuery = query ?? state.query;
    emit(
      AdminCustomersState(
        status: AdminCustomersStatus.loading,
        customers: state.customers,
        query: searchQuery,
      ),
    );
    try {
      if (!_searchPrepared) {
        await _repository.backfillSearchFields();
        _searchPrepared = true;
      }
      final page = await _repository.getCustomers(searchQuery: searchQuery);
      _cursor = page.nextCursor;
      emit(
        AdminCustomersState(
          status: page.customers.isEmpty
              ? AdminCustomersStatus.empty
              : AdminCustomersStatus.success,
          customers: page.customers,
          hasMore: page.hasMore,
          query: searchQuery,
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
      final page = await _repository.getCustomers(
        searchQuery: state.query,
        after: _cursor,
      );
      _cursor = page.nextCursor;
      emit(
        AdminCustomersState(
          status: AdminCustomersStatus.success,
          customers: [...state.customers, ...page.customers],
          hasMore: page.hasMore,
          query: state.query,
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
        query: state.query,
        message: error.toString(),
      ),
    );
  }
}
