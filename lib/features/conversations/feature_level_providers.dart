/// Public seam for user-facing Conversation behavior.
///
/// `features/conversations` is the canonical feature boundary for
/// user-facing Conversation behavior. The retired `features/chats` boundary
/// must not be reintroduced.
export 'application/actions/conversation_excerpt_navigation_actions_provider.dart'
    show conversationExcerptNavigationActionsProvider;
export 'application/actions/conversation_selection_actions_provider.dart'
    show conversationSelectionActionsProvider;
export 'application/conversation_signatures/conversation_signature_display_provider.dart'
    show
        ConversationSignatureDisplayByIdsRequest,
        ConversationSignatureDisplayModel,
        ConversationSignatureSelectedTagsRequest,
        ConversationSignatureFilter,
        ConversationSignatureSort,
        conversationSignatureDisplayByIdsProvider,
        conversationSignatureDisplayProvider,
        conversationSignatureFilterLabel,
        conversationSignatureSortLabel,
        favouriteConversationSignatureDisplayProvider;
export 'application/sidebar_cassette_spec/coordinators/conversations_cassette_coordinator.dart'
    show conversationsCassetteCoordinatorProvider;
export 'application/sidebar_cassette_spec/payloads/conversation_signatures_cassette_payload.dart'
    show ConversationSignaturesCassettePayload;
export 'application/sidebar_cassette_spec/rendering/conversations_cassette_body_builder.dart'
    show buildPlacementGovernedCassetteBody;
export 'application/view_spec/coordinators/view_spec_coordinator.dart'
    show viewSpecCoordinatorProvider;
export 'domain/spec_classes/conversations_cassette_spec.dart'
    show ConversationsCassetteSpec;
export 'domain/spec_classes/conversations_view_spec.dart'
    show ConversationsSpec;
export 'presentation/widgets/contact_conversations/contact_graph_conversation_section.dart'
    show ContactGraphConversationSection;
