import 'package:equatable/equatable.dart';
import 'package:glovoapotheka/data/models/product.dart';

// States
abstract class PackageDetailState extends Equatable {
  const PackageDetailState();

  @override
  List<Object?> get props => [];
}

class PackageDetailInitial extends PackageDetailState {}

class PackageDetailLoaded extends PackageDetailState {
  final PackageAvailabilityInfo package;
  final String descr;
  final String strength;
  final String form;
  final int cartQuantity;

  const PackageDetailLoaded({
    required this.package,
    required this.descr,
    required this.strength,
    required this.form,
    this.cartQuantity = 1,
  });

  PackageDetailLoaded copyWith({
    PackageAvailabilityInfo? package,
    String? descr,
    String? strength,
    String? form,
    int? cartQuantity,
  }) {
    return PackageDetailLoaded(
      package: package ?? this.package,
      descr: descr ?? this.descr,
      strength: strength ?? this.strength,
      form: form ?? this.form,
      cartQuantity: cartQuantity ?? this.cartQuantity,
    );
  }

  @override
  List<Object?> get props => [
        package,
        descr,
        strength,
        form,
        cartQuantity,
      ];
}

class PackageDetailError extends PackageDetailState {
  final String message;

  const PackageDetailError(this.message);

  @override
  List<Object> get props => [message];
}