import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/value_objects/supabase_api_url.dart';

part 'supabase_api_url_provider.g.dart';

/// Loads the Supabase API URL from macOS environment variables.
@riverpod
SupabaseApiUrl supabaseApiUrl(Ref ref) {
  final rawValue = Platform.environment['SUPABASE_API_URL'];
  if (rawValue == null) {
    throw StateError(
      'SUPABASE_API_URL environment variable is not set on this macOS session.',
    );
  }

  final supabaseUrl = SupabaseApiUrl(rawValue.trim());
  return supabaseUrl.value.fold((failure) {
    throw StateError('SUPABASE_API_URL is invalid: ${failure.failedValue}');
  }, (_) => supabaseUrl);
}
