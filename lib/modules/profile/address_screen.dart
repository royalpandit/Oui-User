import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../core/router_name.dart';
import '../../dummy_data/all_dummy_data.dart';
import '../../utils/utils.dart';
import '../cart/component/address_card_component.dart';
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
  final _pageController = PageController(initialPage: 0, keepPage: true, viewportFraction: 1);
  String addressTypeSelect = Language.billingAddress.capitalizeByWord();
  int billingAddressId = 0;
  int shippingAddressId = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: addressType.asMap().entries.map((e) {
              final isSelected = addressTypeSelect == e.value;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      addressTypeSelect = e.value;
                      _pageController.animateToPage(e.key,
                          duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
                    ),
                    child: Text(
                      e.value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (widget.address.addresses.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Text(
              Language.swipeToDelete.capitalizeByWord(),
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade400),
            ),
          ),
        Expanded(
          child: PageView.builder(
            itemCount: addressType.length,
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, pageIndex) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                itemCount: widget.address.addresses.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        if (addressTypeSelect == Language.billingAddress.capitalizeByWord()) {
                          billingAddressId = widget.address.addresses[index].id;
                        } else {
                          shippingAddressId = widget.address.addresses[index].id;
                        }
                        setState(() {});
                      },
                      child: Dismissible(
                        key: Key(widget.address.addresses[index].toString()),
                        onDismissed: (_) {
                          Utils.showSnackBar(context, 'Address Delete Successfully');
                        },
                        confirmDismiss: (v) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext ctx) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                title: Text(Language.areYouSure.capitalizeByWord(),
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                content: Text(Language.wishToDelete.capitalizeByWord(),
                                    style: GoogleFonts.inter(color: Colors.grey.shade600)),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: Text(Language.cancel.toUpperCase(),
                                        style: GoogleFonts.inter(color: Colors.grey)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final item = widget.address.addresses[index];
                                      final result = await context
                                          .read<AddressCubit>()
                                          .deleteSingleAddress(item.id.toString());
                                      result.fold(
                                        (failure) => Utils.errorSnackBar(context, failure.message),
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
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Text(Language.delete.capitalizeByWord(),
                                        style: const TextStyle(color: Colors.white)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: AddressCardComponent(
                          selectAddress: addressTypeSelect == Language.billingAddress.capitalizeByWord()
                              ? billingAddressId
                              : shippingAddressId,
                          addressModel: widget.address.addresses[index],
                          type: widget.address.addresses[index].type,
                          isEditButtonShow: false,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
