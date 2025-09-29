import 'package:dartz/dartz.dart';

import '../../../../domain_driven_development/failures.dart';
import '../../../../domain_driven_development/value_objects.dart';
import '../../../../domain_driven_development/value_validators.dart';

/// Typed value object representing the Supabase API URL configuration.
class SupabaseApiUrl extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory SupabaseApiUrl(String input) {
    return SupabaseApiUrl._(validateSupabaseApiUrl(input));
  }

  const SupabaseApiUrl._(this.value);

  Uri toUri() {
    return Uri.parse(getOrCrash());
  }
}
