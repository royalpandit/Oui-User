import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../utils/utils.dart';
import '../../widgets/field_error_text.dart';
import '../profile/controllers/address/address_cubit.dart';
import '../profile/controllers/country_state_by_id/country_state_by_id_cubit.dart';
import '../profile/model/address_model.dart';
import '../profile/model/city_model.dart';
import '../profile/model/country_model.dart';
import '../profile/model/country_state_model.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({
    super.key,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  CountryModel? _countryModel;
  CountryStateModel? _countryStateModel;
  CityModel? _cityModel;
  AddressModel? addressModel;
  List<CountryModel> countries = [];
  List<CountryStateModel> stateList = [];
  List<CityModel> cityList = [];

  final nameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final phoneCtr = TextEditingController();
  final addressCtr = TextEditingController();
  final zipCtr = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<CountryStateByIdCubit>().countryListLoaded();
  }

  void _loadState(CountryModel countryModel) {
    _countryModel = countryModel;
    _countryStateModel = null;
    _cityModel = null;

    final stateLoadIdCountryId =
        context.read<CountryStateByIdCubit>().stateLoadIdCountryId;

    stateLoadIdCountryId(countryModel.id.toString());
  }

  void _loadCity(CountryStateModel countryStateModel) {
    _countryStateModel = countryStateModel;
    _cityModel = null;

    final cityLoadIdStateId =
        context.read<CountryStateByIdCubit>().cityLoadIdStateId;

    cityLoadIdStateId(countryStateModel.id.toString());
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () {
            context.read<AddressCubit>().getAddress();
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          Language.addNewAddress.capitalizeByWord(),
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: BlocConsumer<AddressCubit, AddressState>(
        listener: (context, state) {
          if (state is AddressStateUpdating) {
            Utils.loadingDialog(context);
          } else {
            Utils.closeDialog(context);
            if (state is AddressStateUpdateError) {
              Utils.closeDialog(context);
              Utils.errorSnackBar(context, state.message);
              context.read<AddressCubit>().getAddress();
            } else if (state is AddressStateUpdated) {
              Utils.closeDialog(context);
              Utils.showSnackBar(context, 'Address added successfully');
              Navigator.pop(context);
            }
          }
        },
        builder: (context, addressState) {
          return BlocBuilder<CountryStateByIdCubit, CountryStateByIdState>(
            builder: (context, state) {
              if (state is CountryStateByIdStateLoadied) {
                if (addressModel != null) {
                  _countryStateModel = context
                      .read<CountryStateByIdCubit>()
                      .filterState(addressModel!.stateId.toString());
                  if (_countryStateModel != null) {
                    _cityModel = context
                        .read<CountryStateByIdCubit>()
                        .filterCity('${addressModel!.cityId}');
                  }
                }
              }
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(Language.name.capitalizeByWord()),
                      TextFormField(
                        controller: nameCtr,
                        keyboardType: TextInputType.name,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                        decoration: _inputDecoration(Language.name.capitalizeByWord()),
                      ),
                      if (addressState is AddressStateInvalidDataError) ...[
                        if (addressState.errorMsg.name.isNotEmpty)
                          ErrorText(text: addressState.errorMsg.name.first),
                      ],
                      const SizedBox(height: 16),
                      _fieldLabel(Language.emailAddress.capitalizeByWord()),
                      TextFormField(
                        controller: emailCtr,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                        decoration: _inputDecoration(Language.emailAddress.capitalizeByWord()),
                      ),
                      if (addressState is AddressStateInvalidDataError) ...[
                        if (addressState.errorMsg.email.isNotEmpty)
                          ErrorText(text: addressState.errorMsg.email.first),
                      ],
                      const SizedBox(height: 16),
                      _fieldLabel(Language.phoneNumber.capitalizeByWord()),
                      TextFormField(
                        controller: phoneCtr,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                        decoration: _inputDecoration(Language.phoneNumber.capitalizeByWord()),
                      ),
                      if (addressState is AddressStateInvalidDataError) ...[
                        if (addressState.errorMsg.phone.isNotEmpty)
                          ErrorText(text: addressState.errorMsg.phone.first),
                      ],
                      const SizedBox(height: 16),
                      _fieldLabel(Language.country.capitalizeByWord()),
                      _countryField(countries),
                      if (addressState is AddressStateInvalidDataError) ...[
                        if (addressState.errorMsg.country.isNotEmpty)
                          ErrorText(text: addressState.errorMsg.country.first),
                      ],
                      const SizedBox(height: 16),
                      _fieldLabel(Language.state.capitalizeByWord()),
                      stateField(),
                      if (addressState is AddressStateInvalidDataError) ...[
                        if (addressState.errorMsg.state.isNotEmpty)
                          ErrorText(text: addressState.errorMsg.state.first),
                      ],
                      const SizedBox(height: 16),
                      _fieldLabel(Language.city.capitalizeByWord()),
                      cityField(),
                      if (addressState is AddressStateInvalidDataError) ...[
                        if (addressState.errorMsg.city.isNotEmpty)
                          ErrorText(text: addressState.errorMsg.city.first),
                      ],
                      const SizedBox(height: 16),
                      _fieldLabel(Language.address.capitalizeByWord()),
                      TextFormField(
                        controller: addressCtr,
                        keyboardType: TextInputType.streetAddress,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                        decoration: _inputDecoration(Language.address.capitalizeByWord()),
                      ),
                      if (addressState is AddressStateInvalidDataError) ...[
                        if (addressState.errorMsg.address.isNotEmpty)
                          ErrorText(text: addressState.errorMsg.address.first),
                      ],
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final dataMap = {
                              'name': nameCtr.text.trim(),
                              'email': emailCtr.text.trim(),
                              'phone': phoneCtr.text.trim(),
                              'country': _countryModel != null
                                  ? _countryModel!.id.toString()
                                  : "",
                              'state': _countryStateModel != null
                                  ? _countryStateModel!.id.toString()
                                  : "",
                              'type': 'home',
                              'city': _cityModel != null
                                  ? _cityModel!.id.toString()
                                  : "",
                              'address': addressCtr.text.trim(),
                            };
                            context.read<AddressCubit>().addAddress(dataMap);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            Language.addNewAddress.capitalizeByWord(),
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _countryField(List<CountryModel> countries) {
    final addressBl = context.read<CountryStateByIdCubit>();
    return DropdownButtonFormField<CountryModel>(
      value: _countryModel,
      hint: Text(Language.country.capitalizeByWord(), style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400)),
      decoration: _inputDecoration(''),
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
      dropdownColor: Colors.white,
      onTap: () async {
        Utils.closeKeyBoard(context);
      },
      onChanged: (value) {
        if (value == null) return;
        _loadState(value);
      },
      isDense: true,
      isExpanded: true,
      items: addressBl.countryList.isNotEmpty
          ? addressBl.countryList
              .map<DropdownMenuItem<CountryModel>>((CountryModel value) {
              return DropdownMenuItem<CountryModel>(
                  value: value, child: Text(value.name));
            }).toList()
          : null,
    );
  }

  Widget stateField() {
    final addressBl = context.read<CountryStateByIdCubit>();
    return DropdownButtonFormField<CountryStateModel>(
      value: _countryStateModel,
      hint: Text(Language.state.capitalizeByWord(), style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400)),
      decoration: _inputDecoration(''),
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
      dropdownColor: Colors.white,
      onTap: () async {
        Utils.closeKeyBoard(context);
      },
      onChanged: (value) {
        if (value == null) return;
        _countryStateModel = value;
        _loadCity(value);
        addressBl.cityStateChangeCityFilter(value);
      },
      isDense: true,
      isExpanded: true,
      items: addressBl.stateList.isNotEmpty
          ? addressBl.stateList.map<DropdownMenuItem<CountryStateModel>>(
              (CountryStateModel value) {
              return DropdownMenuItem<CountryStateModel>(
                  value: value, child: Text(value.name));
            }).toList()
          : null,
    );
  }

  Widget cityField() {
    final addressBl = context.read<CountryStateByIdCubit>();
    return DropdownButtonFormField<CityModel>(
      value: _cityModel,
      hint: Text(Language.city.capitalizeByWord(), style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400)),
      decoration: _inputDecoration(''),
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
      dropdownColor: Colors.white,
      onTap: () {
        Utils.closeKeyBoard(context);
      },
      onChanged: (value) {
        _cityModel = value;
      },
      isDense: true,
      isExpanded: true,
      items: addressBl.cities.isNotEmpty
          ? addressBl.cities
              .map<DropdownMenuItem<CityModel>>((CityModel value) {
              return DropdownMenuItem<CityModel>(
                  value: value, child: Text(value.name));
            }).toList()
          : [],
    );
  }
}
