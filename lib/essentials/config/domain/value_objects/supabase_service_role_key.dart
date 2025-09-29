import 'package:dartz/dartz.dart';

import '../../../../domain_driven_development/failures.dart';
import '../../../../domain_driven_development/value_objects.dart';
import '../../../../domain_driven_development/value_validators.dart';

/// Strongly typed wrapper around the Supabase service role key string.
class SupabaseServiceRoleKey extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory SupabaseServiceRoleKey(String input) {
    return SupabaseServiceRoleKey._(validateSupabaseServiceRoleKey(input));
  }

  const SupabaseServiceRoleKey._(this.value);

  /// Masks the secret for log output, retaining the last four characters.
  String masked() {
    final key = getOrCrash();
    if (key.length <= 4) {
      return '****';
    }
    final suffix = key.substring(key.length - 4);
    return '****$suffix';
  }
}
