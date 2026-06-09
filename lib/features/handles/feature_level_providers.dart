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
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_mode_switcher_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_review_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/stray_handles_type_switcher_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/handles_cassette_body_builder.dart';
export './application/state/stray_handle_mode_provider.dart';
export './infrastructure/repositories/handle_display_name_provider.dart';
export './infrastructure/repositories/stray_handles_provider.dart';
