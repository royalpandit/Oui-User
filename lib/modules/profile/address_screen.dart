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
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xE5131313)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, RouteNames.addAddressScreen, arguments: {"type": "new"}),
                    child: const Icon(Icons.add, size: 22, color: Colors.white),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: 0.10,
              child: Container(width: double.infinity, height: 1, color: const Color(0xFF1C1B1B)),
            ),

            // ── Body ──
            Expanded(
              child: BlocConsumer<AddressCubit, AddressState>(
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
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF444444)),
                    );
                  } else if (state is AddressStateError) {
                    if (state.statusCode == 503) {
                      return _LoadedWidget(address: addressCubit.address!);
                    }
                    return Center(
                      child: Text(state.message, style: GoogleFonts.manrope(color: Colors.red.shade300)),
                    );
                  } else if (state is AddressStateLoaded) {
                    return _LoadedWidget(address: state.address);
                  }
                  return _LoadedWidget(address: context.read<AddressCubit>().address!);
                },
              ),
            ),
          ],
        ),
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
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      children: [
        // ── Header Section ──
        const SizedBox(height: 48),
        Text(
          'ACCOUNT SERVICES',
          style: GoogleFonts.manrope(
            fontSize: 10, fontWeight: FontWeight.w400,
            color: Colors.white, height: 1.5, letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Address\nArchives',
          style: GoogleFonts.notoSerif(
            fontSize: 36, fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFE5E2E1), height: 1.25,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Manage your curated shipping destinations.\nEnsure your acquisitions reach their intended\ncoordinates with absolute precision.',
            style: GoogleFonts.manrope(
              fontSize: 16, fontWeight: FontWeight.w300,
              color: const Color(0xFFC4C8C0), height: 1.63,
            ),
          ),
        ),

        const SizedBox(height: 64),

        // ── Add new address card ──
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, RouteNames.addAddressScreen, arguments: {"type": "new"}),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 91),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E0E),
              border: Border.all(width: 1, color: const Color(0x33434842)),
            ),
            child: Column(
              children: [
                const Icon(Icons.add, size: 28, color: Color(0xFFE5E2E1)),
                const SizedBox(height: 16),
                Text(
                  'APPEND NEW RECORD',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: const Color(0xFFE5E2E1), height: 1.33,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Address Cards ──
        if (widget.address.addresses.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(
              child: Text(
                'No addresses yet.\nTap above to add your first.',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSerif(
                  fontSize: 16, fontStyle: FontStyle.italic,
                  color: const Color(0xFF777777), height: 1.5,
                ),
              ),
            ),
          )
        else
          ...List.generate(widget.address.addresses.length, (index) {
            final addr = widget.address.addresses[index];
            final isDefault = addr.defaultShipping == 1 || addr.defaultBilling == 1;
            final bgColor = index == 0 ? const Color(0xFF1C1B1B) : const Color(0xFF201F1F);

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: bgColor),
              child: Stack(
                children: [
                  // Address content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addr.name,
                        style: GoogleFonts.notoSerif(
                          fontSize: 24, fontWeight: FontWeight.w400,
                          color: const Color(0xFFE5E2E1), height: 1.33,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        addr.address,
                        style: GoogleFonts.manrope(
                          fontSize: 16, fontWeight: FontWeight.w300,
                          color: const Color(0xFFC4C8C0), height: 1.5,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          addr.city?.name ?? '',
                          addr.countryState?.name ?? '',
                        ].where((s) => s.isNotEmpty).join(', '),
                        style: GoogleFonts.manrope(
                          fontSize: 16, fontWeight: FontWeight.w300,
                          color: const Color(0xFFC4C8C0), height: 1.5,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (addr.country != null)
                        Text(
                          addr.country!.name,
                          style: GoogleFonts.manrope(
                            fontSize: 16, fontWeight: FontWeight.w300,
                            color: const Color(0xFFC4C8C0), height: 1.5,
                            letterSpacing: 0.4,
                          ),
                        ),
                      Opacity(
                        opacity: 0.50,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            addr.phone,
                            style: GoogleFonts.manrope(
                              fontSize: 12, fontWeight: FontWeight.w300,
                              color: const Color(0xFFC4C8C0), height: 1.33,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ),

                      // ── Action row ──
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 24),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 1, color: Color(0x19434842)),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Edit
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                  context, RouteNames.addAddressScreen,
                                  arguments: {'type': 'edit', 'address_id': addr.id},
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'EDIT',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10, fontWeight: FontWeight.w400,
                                        color: Colors.white, height: 1.5,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              // Remove
                              GestureDetector(
                                onTap: () => _confirmDelete(addr.id, index),
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline, size: 14, color: Color(0xFFC4C8C0)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'REMOVE',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10, fontWeight: FontWeight.w400,
                                        color: const Color(0xFFC4C8C0), height: 1.5,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Set as primary (only for non-default)
                              if (!isDefault) ...[
                                const SizedBox(width: 32),
                                Text(
                                  'SET AS\nPRIMARY',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    fontSize: 10, fontWeight: FontWeight.w400,
                                    color: const Color(0xFFC4C8C0), height: 1.5,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // PRIMARY badge
                  if (isDefault)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3.5),
                        decoration: const BoxDecoration(color: Color(0x19E9C349)),
                        child: Text(
                          'PRIMARY',
                          style: GoogleFonts.manrope(
                            fontSize: 10, fontWeight: FontWeight.w400,
                            color: Colors.white, height: 1.5,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),

        // ── Footer banner ──
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Stack(
              children: [
                Opacity(
                  opacity: 0.40,
                  child: Container(
                    width: double.infinity,
                    height: 147,
                    color: Colors.white,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.5, 1.0),
                        end: Alignment(0.5, 0.0),
                        colors: [Color(0xFF131313), Color(0x00131313), Color(0x00131313)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 32,
                  bottom: 32,
                  child: Opacity(
                    opacity: 0.80,
                    child: Text(
                      'Global Logistics, Refined.',
                      style: GoogleFonts.notoSerif(
                        fontSize: 20, fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFE5E2E1), height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(int addressId, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        surfaceTintColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(),
        title: Text(
          Language.areYouSure.capitalizeByWord(),
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.w400, fontSize: 18, color: Colors.white),
        ),
        content: Text(
          Language.wishToDelete.capitalizeByWord(),
          style: GoogleFonts.manrope(color: const Color(0xFF777777), fontSize: 14),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Text(
              Language.cancel.toUpperCase(),
              style: GoogleFonts.manrope(color: const Color(0xFF777777), fontWeight: FontWeight.w600, letterSpacing: 1),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () async {
              final result = await context.read<AddressCubit>().deleteSingleAddress(addressId.toString());
              result.fold(
                (failure) => Utils.errorSnackBar(context, failure.message),
                (success) {
                  widget.address.addresses.removeAt(index);
                  setState(() {});
                  Utils.showSnackBar(context, success);
                },
              );
              Navigator.of(ctx).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Text(
                Language.delete.capitalizeByWord(),
                style: GoogleFonts.manrope(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


