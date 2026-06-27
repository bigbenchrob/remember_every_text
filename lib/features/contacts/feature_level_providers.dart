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
// - Public contact display identity read models/providers
// - Public contact-selection dialog used by cross-feature linking flows
//
// Does NOT export:
// - Resolvers
// - Internal widget builders
// - Infrastructure details
// =============================================================================

export './application/contact_access/contact_access_provider.dart';
export './application/contact_access/contact_access_store.dart';
export './application/display_identity/display_identity.dart';
export './application/display_identity/display_identity_resolver_provider.dart';
export './application/display_name_overrides/contact_display_name_override_store_provider.dart';
export './application/favorites/favorite_contacts_repository_provider.dart';
export './application/read_models/contact_profile_provider.dart';
export './application/read_models/contact_profile_reader.dart';
export './application/read_models/contact_profile_summary.dart';
export './application/read_models/contact_summary.dart';
export './application/read_models/contacts_list_reader.dart';
export './application/read_models/contacts_list_repository_provider.dart';
export './application/read_models/handles_for_contact_provider.dart';
export './application/read_models/handles_for_contact_reader.dart';
export './application/read_models/linked_handle.dart';
export './application/read_models/recent_contact_summary.dart';
export './application/read_models/recent_contacts_provider.dart';
export './application/read_models/recent_contacts_reader.dart';
export './application/read_models/virtual_participants_provider.dart';
export './application/read_models/virtual_participants_reader.dart';
export './application/services/manual_handle_link_service.dart';
export './application/services/manual_handle_link_store_provider.dart';
export './application/sidebar_cassette_spec/coordinators/cassette_coordinator.dart';
export './application/sidebar_cassette_spec/coordinators/contact_chooser_cassette_state_provider.dart';
export './application/sidebar_cassette_spec/coordinators/info_cassette_coordinator.dart';
export './application/sidebar_cassette_spec/payloads/contact_chooser_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_hero_summary_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_message_scope_toggle_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/contact_selection_control_cassette_payload.dart';
export './application/sidebar_cassette_spec/payloads/handle_filter_cassette_payload.dart';
export './application/sidebar_cassette_spec/rendering/contacts_cassette_body_builder.dart';
export './application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_store_provider.dart';
export './application/tooltips_spec/coordinators/contacts_tooltip_coordinator.dart';
export './domain/overlay_virtual_contact.dart';
export './domain/spec_classes/contacts_cassette_spec.dart';
export './domain/spec_classes/contacts_tooltip_spec.dart';
export './presentation/widgets/contact_picker_dialog.dart';
