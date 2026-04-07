// =============================================================================
// CONTACTS FEATURE — PUBLIC API
// =============================================================================
//
// This barrel file exports only the public API of the contacts feature.
// External code should import ONLY this file.
//
// Exports:
// - Spec classes (domain)
// - Coordinators (application)
// - Cassette payloads and render-edge builders
// - Settings providers
// - Repositories (for cross-feature data access)
//
// Does NOT export:
// - Resolvers
// - Widget builders
// - Infrastructure details
// =============================================================================

export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/coordinators/contacts_settings_coordinator.dart';
export './application/sidebar_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_chooser_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_hero_summary_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_message_scope_toggle_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_selection_control_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/handle_filter_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/reimport_data_info_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/send_logs_info_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/contacts_cassette_body_builder.dart';
export './application/sidebar_cassette_spec/resolver_tools/contact_chooser_snapshot_provider.dart';
export './application/sidebar_cassette_spec/resolver_tools/filtered_picker_sections_provider.dart';
export './application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';
export './application/tooltips_spec/coordinators/contacts_tooltip_coordinator.dart';
export './domain/spec_classes/contacts_cassette_spec.dart';
export './domain/spec_classes/contacts_tooltip_spec.dart';
export './infrastructure/repositories/recent_contacts_repository.dart';
