import 'display_identity.dart';

abstract interface class DisplayIdentityRepository {
  Future<DisplayIdentityResolver> readResolver();
}
