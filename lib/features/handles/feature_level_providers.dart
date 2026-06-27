// =============================================================================
// HANDLES FEATURE — PUBLIC API
// =============================================================================
//
// This barrel file exports only the public API of the handles feature.
// External code should import ONLY this file.
//
// Exports:
// - Coordinators (application surface handlers)
// - State providers needed externally
//
// Does NOT export:
// - Resolvers
// - Widget builders
// - Infrastructure details
// =============================================================================

export './application/info_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/read_models/handle_display_name_provider.dart';
export './application/read_models/handle_display_name_reader.dart';
export './application/read_models/handle_identity.dart';
export './application/read_models/stray_handle_summary.dart';
export './application/read_models/stray_handles_provider.dart';
export './application/read_models/stray_handles_read_repository.dart';
export './application/review/handle_review_controller.dart';
export './application/review/handle_review_provider.dart';
export './application/review/handle_review_store.dart';
export './application/settings_cassette_spec/resolver_tools/handle_visibility_store_provider.dart';
export './application/settings_cassette_spec/resolver_tools/manual_linking_read_repository_provider.dart';
export './application/settings_cassette_spec/resolver_tools/spam_handles_repository_provider.dart';
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_mode_switcher_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_review_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_type_switcher_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/handles_cassette_body_builder.dart';
export './application/state/stray_handle_mode_provider.dart';
