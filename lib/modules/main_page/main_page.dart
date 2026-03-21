import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/widgets/capitalized_word.dart';
import '../../utils/language_string.dart';
import '../../utils/utils.dart';
import '../cart/controllers/cart/cart_cubit.dart';
import '../flash/controller/cubit/flash_cubit.dart';
import '../home/home_screen.dart';
import '../order/order_screen.dart';
import '../profile/controllers/country_state_by_id/country_state_by_id_cubit.dart';
import '../profile/controllers/updated_info/updated_info_cubit.dart';
import '../profile/profile_offer/controllers/wish_list/wish_list_cubit.dart';
import '../profile/profile_screen.dart';
import 'component/bottom_navigation_bar.dart';
import 'main_controller.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _homeController = MainController();

  late List<Widget> pageList;

  @override
  void initState() {
    super.initState();

    pageList = [
      const HomeScreen(),
      // const ChatListScreen(),
      const OrderScreen(),
      const ProfileScreen(),
    ];
    context.read<CountryStateByIdCubit>().countryListLoaded();
    context.read<UserProfileInfoCubit>().getUserProfileInfo();
    context.read<FlashCubit>().getFalshSale();
    context.read<CartCubit>().getCartProducts();
    context.read<WishListCubit>().getWishList();
  }

  exitPopUP() {
    Utils.showCustomDialog(context,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: const BoxDecoration(
                      color: Color(0xFFE5E2E1)),
                  child: Text(
                    "${Language.exitApp.capitalizeByWord()}?",
                    style: const TextStyle(
                        color: Color(0xFF131313),
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE5E2E1),
                        side: const BorderSide(color: Color(0xFF5E5E5E)),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(Language.cancel.capitalizeByWord()),
                      )),
                  const SizedBox(width: 10),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF131313),
                        backgroundColor: const Color(0xFFE5E2E1),
                        side: const BorderSide(color: Color(0xFFE5E2E1)),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(Language.yesExit.capitalizeByWord()),
                      )),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exitPopUP();
        return false;
      },
      child: Scaffold(
        extendBody: true,
        // key: _homeController.scaffoldKey,
        // drawer: const DrawerWidget(),
        body: StreamBuilder<int>(
          initialData: 0,
          stream: _homeController.naveListener.stream,
          builder: (context, AsyncSnapshot<int> snapshot) {
            int index = snapshot.data ?? 0;
            return pageList[index];
          },
        ),
        bottomNavigationBar: const MyBottomNavigationBar(),
      ),
    );
  }
}
