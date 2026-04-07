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
export './application/settings_cassette_spec/coordinators/settings_coordinator.dart';
export './application/settings_cassette_spec/payloads/manual_linking_cassette_payload.dart';
export './application/settings_cassette_spec/payloads/spam_management_cassette_payload.dart';
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/stray_emails_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_mode_switcher_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_review_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_type_switcher_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_phone_numbers_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/unmatched_handles_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/handles_cassette_body_builder.dart';
export './application/state/stray_handle_mode_provider.dart';
export './application/view_spec/coordinators/view_spec_coordinator.dart';
