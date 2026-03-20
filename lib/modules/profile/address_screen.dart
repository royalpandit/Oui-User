import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../core/router_name.dart';
import '../../utils/utils.dart';
import 'controllers/address/address_cubit.dart';
import 'controllers/country_state_by_id/country_state_by_id_cubit.dart';
import 'model/billing_shipping_model.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    Future.microtask(() {
      context.read<CountryStateByIdCubit>().countryListLoaded();
      context.read<AddressCubit>().getAddress();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final addressCubit = context.read<AddressCubit>();
    if (addressCubit.address == null) {
      addressCubit.getAddress();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          Language.address.capitalizeByWord(),
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressStateUpdated) {
            context.read<AddressCubit>().getAddress();
          }
          if (state is AddressStateError) {
            if (state.statusCode == 503) {
              Utils.serviceUnAvailable(context, state.message);
            } else {
              Utils.errorSnackBar(context, state.message);
            }
          }
        },
        builder: (context, state) {
          if (state is AddressStateLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (state is AddressStateError) {
            if (state.statusCode == 503) {
              return _LoadedWidget(address: addressCubit.address!);
            }
            return Center(
              child: Text(state.message, style: GoogleFonts.inter(color: Colors.red.shade400)),
            );
          } else if (state is AddressStateLoaded) {
            return _LoadedWidget(address: state.address);
          }
          return _LoadedWidget(address: context.read<AddressCubit>().address!);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.addAddressScreen, arguments: {"type": "new"});
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _LoadedWidget extends StatefulWidget {
  const _LoadedWidget({required this.address});
  final AddressBook address;

  @override
  State<_LoadedWidget> createState() => _LoadedWidgetState();
}

class _LoadedWidgetState extends State<_LoadedWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.address.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_outlined,
                  size: 40, color: Colors.black38),
            ),
            const SizedBox(height: 16),
            Text(
              'No addresses yet',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap the + button to add your first address.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: widget.address.addresses.length,
      itemBuilder: (context, index) {
        final addr = widget.address.addresses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(addr.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red, size: 24),
            ),
            confirmDismiss: (_) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: Text(Language.areYouSure.capitalizeByWord(),
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  content: Text(Language.wishToDelete.capitalizeByWord(),
                      style: GoogleFonts.inter(
                          color: Colors.grey.shade600, fontSize: 14)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(Language.cancel.toUpperCase(),
                          style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final result = await context
                            .read<AddressCubit>()
                            .deleteSingleAddress(addr.id.toString());
                        result.fold(
                          (failure) =>
                              Utils.errorSnackBar(context, failure.message),
                          (success) {
                            widget.address.addresses.removeAt(index);
                            setState(() {});
                            Utils.showSnackBar(context, success);
                          },
                        );
                        Navigator.of(ctx).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(Language.delete.capitalizeByWord(),
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) =>
                Utils.showSnackBar(context, 'Address deleted'),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_outlined,
                          size: 20, color: Colors.black),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  addr.name,
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  addr.type == '1' ? 'Office' : 'Home',
                                  style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            addr.address,
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4),
                          ),
                          if (addr.city != null ||
                              addr.countryState != null ||
                              addr.country != null) ...
                            [
                              const SizedBox(height: 2),
                              Text(
                                [
                                  addr.city?.name ?? '',
                                  addr.countryState?.name ?? '',
                                  addr.country?.name ?? '',
                                ]
                                    .where((s) => s.isNotEmpty)
                                    .join(', '),
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade500),
                              ),
                            ],
                          const SizedBox(height: 4),
                          Text(
                            addr.phone,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    RouteNames.addAddressScreen,
                                    arguments: {
                                      'type': 'edit',
                                      'address_id': addr.id,
                                    },
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    side: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 15,
                                      color: Colors.black),
                                  label: Text(
                                    'Edit',
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
