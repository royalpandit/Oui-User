import 'dart:developer';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/profile/model/user_info/user_updated_info.dart';
import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../../core/remote_urls.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/field_error_text.dart';
import '../controllers/country_state_by_id/country_state_by_id_cubit.dart';
import '../controllers/profile_edit/profile_edit_cubit.dart';
import '../controllers/updated_info/updated_info_cubit.dart';
import '../model/city_model.dart';
import '../model/country_model.dart';
import '../model/country_state_model.dart';

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({
    super.key,
    required this.userData,
  });
  final UserProfileInfo userData;

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  CountryModel? _currentCountry;
  CountryStateModel? _countryState;
  CityModel? _cityModel;
  List<CountryModel> countries = [];
  List<CountryStateModel> stateList = [];
  List<CityModel> cityList = [];

  // UserUpdatedInfo? updatedInfo;

  @override
  void initState() {
    super.initState();
    loadRegion();
  }

  loadRegion() {
    // context.read<CountryStateByIdCubit>().countryList = context.read<CountryStateByIdCubit>().countryList;
    countries = context.read<CountryStateByIdCubit>().countryList;
    context.read<CountryStateByIdCubit>().stateList =
        widget.userData.stateModel;
    context.read<CountryStateByIdCubit>().cities = widget.userData.cityModel;
    log(countries.toString(), name: "CountryList");

    // log(stateList.toString(), name: "Statelist");
    // log(cityList.toString(), name: "citylist");
    log(widget.userData.stateModel.toString(), name: "StateList");
    log(widget.userData.cityModel.toString(), name: "cityList");

    //preload the information in states
    context
        .read<ProfileEditCubit>()
        .changeAddress(widget.userData.updateUserInfo!.address);
    context
        .read<ProfileEditCubit>()
        .changeCountry('${widget.userData.updateUserInfo!.countryId}');
    context
        .read<ProfileEditCubit>()
        .changeState('${widget.userData.updateUserInfo!.stateId}');
    context
        .read<ProfileEditCubit>()
        .changeCity('${widget.userData.updateUserInfo!.cityId}');
    //

    // _countryState = null;
    _countryState = context
        .read<UserProfileInfoCubit>()
        .defaultState(widget.userData.updateUserInfo!.stateId.toString());

    if (_countryState != null) {
      log(_countryState.toString(), name: "_stateModel");

      _cityModel = context
          .read<UserProfileInfoCubit>()
          .defaultCity(widget.userData.updateUserInfo!.cityId.toString());
      log(_cityModel.toString(), name: "_cityModel");
    }

    for (var element in widget.userData.countryModel) {
      if (element.id == widget.userData.updateUserInfo!.countryId) {
        _currentCountry = element;
        debugPrint("_country $_currentCountry");

        break;
      }
    }

    // for (var element in widget.userData.stateModel.toSet().toList()) {
    //   if (element.id.toString() == widget.userData.updateUserInfo.countryId) {
    //     _countryState = element;
    //     print("_country $_currentCountry");
    //     break;
    //   }
    // }
    // for (var element in widget.userData.cityModel) {
    //   if (element.id.toString() == widget.userData.updateUserInfo.countryId) {
    //     _cityModel = element;
    //     print("_country $_currentCountry");
    //     break;
    //   }
    // }
  }

  void _loadState(CountryModel countryModel) {
    _currentCountry = countryModel;
    _countryState = null;
    _cityModel = null;

    final stateLoadIdCountryId =
        context.read<CountryStateByIdCubit>().stateLoadIdCountryId;

    stateLoadIdCountryId(countryModel.id.toString());
  }

  void _loadCity(CountryStateModel countryStateModel) {
    _countryState = countryStateModel;
    _cityModel = null;

    final cityLoadIdStateId =
        context.read<CountryStateByIdCubit>().cityLoadIdStateId;

    cityLoadIdStateId(countryStateModel.id.toString());
  }

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final zipCodeController = TextEditingController();
  final addressController = TextEditingController();

  String _stripPhonePrefix(String phone) {
    String p = phone.trim();
    if (p.startsWith('+91')) p = p.substring(3);
    if (p.startsWith('91') && p.length > 10) p = p.substring(2);
    if (p.startsWith('0')) p = p.substring(1);
    return p;
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
    final profileEdBlc = context.read<ProfileEditCubit>();

    return BlocBuilder<CountryStateByIdCubit, CountryStateByIdState>(
      builder: (context, state) {
        if (state is CountryStateByIdStateLoadied) {
          _countryState = context
              .read<CountryStateByIdCubit>()
              .filterState('${widget.userData.updateUserInfo!.stateId}');

          if (_countryState != null) {
            log(_countryState.toString(), name: "_stateModel");

            _cityModel = context
                .read<CountryStateByIdCubit>()
                .filterCity('${widget.userData.updateUserInfo!.cityId}');
            log(_cityModel.toString(), name: "_cityModel");
          }
        }
        // return BlocBuilder<UserProfileInfoCubit, UserProfilenfoState>(
        //   builder: (context, s) {
        //     if (s is UpdatedLoaded) {
        //       _countryState = context
        //           .read<UserProfileInfoCubit>()
        //           .defaultState(widget.userData.updateUserInfo.stateId ?? '');
        //
        //       if (_countryState != null) {
        //         log(_countryState.toString(), name: "_stateModel");
        //
        //         _cityModel = context
        //             .read<UserProfileInfoCubit>()
        //             .defaultCity(widget.userData.updateUserInfo.cityId ?? '');
        //         log(_cityModel.toString(), name: "_cityModel");
        //       }
        //     }

        return Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildImage(),
              Text(
                widget.userData.updateUserInfo!.name,
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const SizedBox(height: 24),
              BlocBuilder<ProfileEditCubit, ProfileEditStateModel>(
                buildWhen: (p, c) => true,
                builder: (context, state) {
                  final edit = state.stateStatus;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(Language.name.capitalizeByWord()),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        initialValue: widget.userData.updateUserInfo!.name,
                        onChanged: profileEdBlc.changeName,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                        decoration: _inputDecoration(Language.name.capitalizeByWord()),
                      ),
                      if (edit is ProfileEditFormValidState) ...[
                        if (edit.errors.name.isNotEmpty)
                          ErrorText(text: edit.errors.name.first),
                      ]
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<ProfileEditCubit, ProfileEditStateModel>(
                builder: (context, state) {
                  final edit = state.stateStatus;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(Language.phoneNumber.capitalizeByWord()),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          profileEdBlc.changePhone(_stripPhonePrefix(value));
                        },
                        initialValue: _stripPhonePrefix(widget.userData.updateUserInfo!.phone),
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                        decoration: _inputDecoration(Language.phoneNumber.capitalizeByWord()).copyWith(
                          prefixIcon: CountryCodePicker(
                            padding: EdgeInsets.zero,
                            onChanged: (country) {
                              profileEdBlc.changePhoneCode(country.dialCode ?? '');
                            },
                            flagWidth: 28,
                            initialSelection: 'IN',
                            favorite: const ['+91', 'IN'],
                            showCountryOnly: false,
                            showOnlyCountryWhenClosed: false,
                            alignLeft: false,
                            textStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ),
                      if (edit is ProfileEditFormValidState) ...[
                        if (edit.errors.phone.isNotEmpty)
                          ErrorText(text: edit.errors.phone.first),
                      ]
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<ProfileEditCubit, ProfileEditStateModel>(
                builder: (context, state) {
                  final edit = state.stateStatus;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(Language.country.capitalizeByWord()),
                      _countryField(),
                      if (edit is ProfileEditFormValidState) ...[
                        if (edit.errors.country.isNotEmpty)
                          ErrorText(text: edit.errors.country.first),
                      ]
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<ProfileEditCubit, ProfileEditStateModel>(
                builder: (context, state) {
                  final edit = state.stateStatus;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(Language.state.capitalizeByWord()),
                      stateField(),
                      if (edit is ProfileEditFormValidState) ...[
                        if (edit.errors.state.isNotEmpty)
                          ErrorText(text: edit.errors.state.first),
                      ]
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel(Language.city.capitalizeByWord()),
                  cityField(),
                ],
              ),
              const SizedBox(height: 16),
              BlocBuilder<ProfileEditCubit, ProfileEditStateModel>(
                builder: (context, state) {
                  final edit = state.stateStatus;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel(Language.yourAddress.capitalizeByWord()),
                      TextFormField(
                        keyboardType: TextInputType.streetAddress,
                        initialValue: widget.userData.updateUserInfo!.address,
                        onChanged: profileEdBlc.changeAddress,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                        decoration: _inputDecoration(Language.yourAddress.capitalizeByWord()),
                      ),
                      if (edit is ProfileEditFormValidState) ...[
                        if (edit.errors.address.isNotEmpty)
                          ErrorText(text: edit.errors.address.first),
                      ]
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              BlocListener<ProfileEditCubit, ProfileEditStateModel>(
                listener: (context, state) {
                  if (state.stateStatus is ProfileEditStateLoading) {
                    Utils.loadingDialog(context);
                  } else {
                    Utils.closeDialog(context);
                    if (state.stateStatus is ProfileEditStateError) {
                      final e = state.stateStatus as ProfileEditStateError;
                      Utils.errorSnackBar(context, e.message);
                    } else if (state.stateStatus is ProfileEditStateLoaded) {
                      context.read<CountryStateByIdCubit>().countryListLoaded();
                      context.read<UserProfileInfoCubit>().getUserProfileInfo();
                      Navigator.pop(context);
                      Utils.showSnackBar(context, 'Successfully Updated');
                    }
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Utils.closeKeyBoard(context);
                      context.read<ProfileEditCubit>().submitForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      Language.updateProfile.capitalizeByWord(),
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
        //   },
        // );
      },
    );
  }

  Widget _buildImage() {
    final profileEditCubit = context.read<ProfileEditCubit>();
    return BlocBuilder<ProfileEditCubit, ProfileEditStateModel>(
      buildWhen: (previous, current) => previous.image != current.image,
      builder: (context, state) {
        String profileImage = widget.userData.updateUserInfo!.image.isNotEmpty
            ? RemoteUrls.imageUrl(widget.userData.updateUserInfo!.image)
            : RemoteUrls.imageUrl(widget.userData.defaultImage!.image);

        profileImage = state.image.isNotEmpty ? state.image : profileImage;

        final image = context.read<UserProfileInfoCubit>().updatedInfo;

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xff333333).withOpacity(.18),
                blurRadius: 70,
              ),
            ],
          ),
          child: Center(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CustomImage(
                    path: profileImage,
                    height: 170,
                    width: 170,
                    fit: BoxFit.cover,
                    isFile: state.image.isNotEmpty,
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: InkWell(
                    onTap: () async {
                      final imageSourcePath = await Utils.pickSingleImage();

                      profileEditCubit.changeImage(imageSourcePath);
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _countryField() {
    final addressBl = context.read<CountryStateByIdCubit>();
    return DropdownButtonFormField<CountryModel>(
      value: _currentCountry,
      hint: Text(Language.country.capitalizeByWord(), style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
      decoration: _inputDecoration(''),
      dropdownColor: Colors.white,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
      onTap: () async {
        Utils.closeKeyBoard(context);
      },
      onChanged: (value) {
        if (value == null) return;
        _loadState(value);
        context.read<ProfileEditCubit>().changeCountry('${value.id}');
      },
      isDense: true,
      isExpanded: true,
      items: addressBl.countryList.isEmpty
          ? null
          : addressBl.countryList
              .map<DropdownMenuItem<CountryModel>>((CountryModel value) {
              return DropdownMenuItem<CountryModel>(
                  value: value, child: Text(value.name));
            }).toList(),
    );
  }

  Widget stateField() {
    final profileBl = context.read<ProfileEditCubit>();
    final addressBl = context.read<CountryStateByIdCubit>();
    return DropdownButtonFormField<CountryStateModel>(
      value: _countryState,
      hint: Text(Language.state.capitalizeByWord(), style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
      decoration: _inputDecoration(''),
      dropdownColor: Colors.white,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
      onTap: () async {
        Utils.closeKeyBoard(context);
      },
      onChanged: (value) {
        if (value == null) return;
        _countryState = value;
        _loadCity(value);
        profileBl.changeState('${value.id}');
      },
      isDense: true,
      isExpanded: true,
      items: addressBl.stateList.isEmpty
          ? null
          : addressBl.stateList.map<DropdownMenuItem<CountryStateModel>>(
              (CountryStateModel value) {
              return DropdownMenuItem<CountryStateModel>(
                  value: value, child: Text(value.name));
            }).toList(),
    );
  }

  Widget cityField() {
    final profileBl = context.read<ProfileEditCubit>();
    final addressBl = context.read<CountryStateByIdCubit>();
    return DropdownButtonFormField<CityModel>(
      value: _cityModel,
      hint: Text(Language.city.capitalizeByWord(), style: GoogleFonts.inter(fontSize: 14, color: Colors.grey)),
      decoration: _inputDecoration(''),
      dropdownColor: Colors.white,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
      onTap: () {
        Utils.closeKeyBoard(context);
      },
      onChanged: (value) {
        _cityModel = value;
        if (value == null) return;
        profileBl.changeCity('${value.id}');
      },
      isDense: true,
      isExpanded: true,
      items: addressBl.cities.isEmpty
          ? null
          : addressBl.cities
              .map<DropdownMenuItem<CityModel>>((CityModel value) {
              return DropdownMenuItem<CityModel>(
                  value: value, child: Text(value.name));
            }).toList(),
    );
  }
}
