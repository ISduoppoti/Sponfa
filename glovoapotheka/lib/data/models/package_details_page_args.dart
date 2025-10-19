import 'package:glovoapotheka/data/models/product.dart';

class PackageDetailsPageArgs {
  final PackageAvailabilityInfo package;
  final String descr;
  final String strength;
  final String form;

  PackageDetailsPageArgs({
    required this.package,
    required this.descr,
    required this.strength,
    required this.form,
  });
}
