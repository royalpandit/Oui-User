import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../authentication/controller/login/login_bloc.dart';
import '../../model/cart_calculation_model.dart';
import '../../model/cart_response_model.dart';
import '../../model/coupon_response_model.dart';
import '../cart_repository.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  final LoginBloc _loginBloc;

  CartCubit({
    required LoginBloc loginBloc,
    required CartRepository cartRepository,
  })  : _cartRepository = cartRepository,
        _loginBloc = loginBloc,
        super(const CartStateInitial()) {
    getCoupon();
  }

  CartResponseModel? cartResponseModel;
  CouponResponseModel? couponResponseModel;
  String? isIncrementDecrement;
  int cartCount = 0;

  Future<void> getCartProducts() async {
    if (_loginBloc.userInfo == null) {
      emit(const CartStateError("Please login first", 401));
      return;
    }

    emit(const CartStateLoading());

    final result =
        await _cartRepository.getCartProducts(_loginBloc.userInfo!.accessToken);

    result.fold(
      (failure) {
        if (failure.statusCode == 500) {
          cartResponseModel = const CartResponseModel(
            cartProducts: [],
          );
          cartCount = 0;
          emit(CartStateLoaded(cartResponseModel!));
        } else {
          emit(CartStateError(failure.message, failure.statusCode));
        }
      },
      (successData) {
        cartResponseModel = successData;
        cartCount = cartResponseModel!.cartProducts.length;

        emit(CartStateLoaded(successData));
        // cartCalculation(successData);
      },
    );
  }

  Future<Either<Failure, String>> removerCartItem(String productId) async {
    if (_loginBloc.userInfo == null) {
      emit(const CartStateError("Please login first", 401));
      return left(const ServerFailure("Please login first", 1000));
    }

    emit(const CartStateDecIncrementLoading());

    final result = await _cartRepository.removerCartItem(
        productId, _loginBloc.userInfo!.accessToken);

    result.fold(
      (failure) {
        emit(CartStateDecIncError(failure.message, failure.statusCode));
        return false;
      },
      (successData) {
        cartResponseModel!.cartProducts
            .removeWhere((element) => element.productId == productId);
        cartCount = cartCount - 1;
        emit(CartStateRemove(successData));
        return true;
      },
    );
    return result;
  }

  Future<Either<Failure, String>> incrementQuantity(String productId) async {
    if (_loginBloc.userInfo == null) {
      emit(const CartStateDecIncError("Please login first", 401));
      return const Left(ServerFailure('Please Login First', 1000));
    }
    emit(const CartStateDecIncrementLoading());

    final result = await _cartRepository.incrementQuantity(
        productId, _loginBloc.userInfo!.accessToken);

    result.fold(
      (failure) {
        emit(CartStateDecIncError(failure.message, failure.statusCode));
      },
      (successData) {
        isIncrementDecrement = successData;
        emit(CartDecIncState(successData));
      },
    );
    return result;
  }

  Future<Either<Failure, String>> decrementQuantity(String productId) async {
    if (_loginBloc.userInfo == null) {
      emit(const CartStateDecIncError("Please login first", 401));
      return const Left(ServerFailure("Please Login first", 1000));
    }
    emit(const CartStateDecIncrementLoading());

    final result = await _cartRepository.decrementQuantity(
        productId, _loginBloc.userInfo!.accessToken);

    result.fold(
      (failure) {
        emit(CartStateDecIncError(failure.message, failure.statusCode));
      },
      (successData) {
        isIncrementDecrement = successData;

        emit(CartDecIncState(successData));
      },
    );
    return result;
  }

  Future<void> applyCoupon(String coupon) async {
    if (_loginBloc.userInfo == null) {
      emit(const CartCouponStateError("Please login first", 401));
      return;
    }
    
    // Get seller_id from first cart product
    final cartProducts = cartResponseModel?.cartProducts ?? [];
    if (cartProducts.isEmpty) {
      emit(const CartCouponStateError("Cart is empty", 400));
      return;
    }
    // Get seller_id from vendor_detail or first cart product
    final int sellerId = cartResponseModel?.vendorUserId ??
        (cartProducts.isNotEmpty ? cartProducts.first.product.vendorId : 0);
    
    emit(const CartCouponStateLoading());

    final result = await _cartRepository.applyCoupon(
        coupon, sellerId, _loginBloc.userInfo!.accessToken);

    result.fold(
      (failure) {
        emit(CartCouponStateError(failure.message, failure.statusCode));
      },
      (successData) {
        couponResponseModel = successData;

        emit(CartCouponStateLoaded(successData));
      },
    );
  }

  Future<void> getCoupon() async {
    final result = _cartRepository.getAppliedCoupon();
    result.fold(
      (failure) {
        // No cached coupon is a normal state — silently ignore
      },
      (successData) {
        couponResponseModel = successData;
        emit(CartCouponStateLoaded(successData));
      },
    );
  }

  void saveCartCalculation(CartCalculation cartCalculation) {
    _cartRepository.saveCartCalculation(cartCalculation);
  }

  CartCalculation getCartCalculation() {
    return _cartRepository.getCartCalculation();
  }

  Future<void> pickupAtStoreOrder(String date, String time, int billingAddressId) async {
    if (_loginBloc.userInfo == null) {
      emit(const CartStateError('Please login first', 401));
      return;
    }
    emit(const CartStateLoading());
    final String? coupon = couponResponseModel?.code;
    final result = await _cartRepository.pickupAtStoreOrder(
        date, time, billingAddressId, coupon, _loginBloc.userInfo!.accessToken);
    result.fold(
      (failure) => emit(CartStateError(failure.message, failure.statusCode)),
      (success) => emit(CartStateOrderSuccess(
        success['message'] ?? '',
        orderId: success['orderId'] ?? '',
      )),
    );
  }
}
