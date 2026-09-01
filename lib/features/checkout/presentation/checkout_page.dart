import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/design_system/responsive.dart';
import '../../../../core/design_system/tokens.dart';
import '../../profile/data/models/customer_profile.dart';
import '../../shop/presentation/store_header.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../data/models/checkout_details.dart';
import 'widgets/checkout_sections.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  bool _profileFilled = false;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _city, _address, _notes]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutCubit, CheckoutState>(
      listener: _listen,
      builder: (context, state) {
        _fillProfile(state.profile);
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const StoreHeader(),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: ResponsiveContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.s16),
                    child: Form(
                      key: _formKey,
                      child: CheckoutSections(
                        nameController: _name,
                        phoneController: _phone,
                        cityController: _city,
                        addressController: _address,
                        notesController: _notes,
                        onSubmit: _submit,
                      ),
                    ),
                  ),
                ),
              ),
              if (state.status == CheckoutStatus.loading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black26,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _listen(BuildContext context, CheckoutState state) {
    if (state.status == CheckoutStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((state.message ?? 'checkout_failed').tr())),
      );
    }
    if (state.status == CheckoutStatus.success) {
      final route = state.orderId == null
          ? Routes.initialRoute
          : Routes.orderRoute.replaceAll(':id', state.orderId!);
      context.go(route);
    }
  }

  void _fillProfile(CustomerProfile? profile) {
    if (_profileFilled || profile == null) return;
    _profileFilled = true;
    _name.text = profile.name;
    _phone.text = profile.phone;
    _city.text = profile.defaultCity;
    _address.text = profile.defaultAddress;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<CheckoutCubit>().submit(
      CheckoutDetails(
        name: _name.text,
        mobile: _phone.text,
        city: _city.text,
        address: _address.text,
        notes: _notes.text.trim().isEmpty ? null : _notes.text,
      ),
    );
  }
}
