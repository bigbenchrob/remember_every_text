import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/value_objects/supabase_service_role_key.dart';

part 'supabase_service_role_key_provider.g.dart';

/// Loads the Supabase service role key from the current macOS environment.
@riverpod
SupabaseServiceRoleKey supabaseServiceRoleKey(Ref ref) {
  final rawValue = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];
  if (rawValue == null) {
    throw StateError(
      'SUPABASE_SERVICE_ROLE_KEY environment variable is not set on this macOS session.',
    );
  }

  final serviceRoleKey = SupabaseServiceRoleKey(rawValue.trim());
  return serviceRoleKey.value.fold((failure) {
    throw StateError(
      'SUPABASE_SERVICE_ROLE_KEY failed validation: ${failure.failedValue}',
    );
  }, (_) => serviceRoleKey);
}
