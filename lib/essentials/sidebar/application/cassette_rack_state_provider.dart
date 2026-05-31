import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../db/feature_level_providers/conversation_graph_readiness_provider.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../feature_level_providers.dart';
import './sidebar_flow_state_provider.dart';

part 'cassette_rack_state_provider.freezed.dart';
part 'cassette_rack_state_provider.g.dart';

List<CassetteSpec> _cascadeFromSpec(
  CassetteSpec root, {
  StableCassetteTopologyContext? topologyContext,
}) {
  final chain = <CassetteSpec>[root];
  var next = topologyContext == null
      ? root.childSpec()
      : resolveStableCascadeChild(root, context: topologyContext);
  while (next != null) {
    chain.add(next);
    next = topologyContext == null
        ? next.childSpec()
        : resolveStableCascadeChild(next, context: topologyContext);
  }
  return List<CassetteSpec>.unmodifiable(chain);
}

/// A value object representing the current stack of cassettes in the sidebar.
///
/// It uses the `freezed` package to generate the immutable data class
/// implementation along with copyWith, equality, and debugging utilities.  A
/// convenience factory [CassetteRack.initial] is provided to generate the
/// tracer‑bullet default containing a single top chat menu cassette.
@freezed
abstract class CassetteRack with _$CassetteRack {
  /// Creates a new [CassetteRack] with the given list of [cassettes].  The
  /// default value is an empty list.  The list is immutable, as the
  /// generated copyWith will always create new lists when updating.
  const factory CassetteRack({
    @Default(<CassetteSpec>[]) List<CassetteSpec> cassettes,
  }) = _CassetteRack;

  /// Private constructor used by the `freezed` mixin.  Required to be able
  /// to add custom methods to the class.
  const CassetteRack._();

  /// Returns a fresh [CassetteRack] containing a single top chat menu
  /// cassette.  This is the initial tracer‑bullet state used by
  /// [CassetteRackState.build].
  factory CassetteRack.initial() {
    const topMenu = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.topChatMenu(),
    );
    return CassetteRack(cassettes: _cascadeFromSpec(topMenu));
  }

  /// Returns a fresh [CassetteRack] containing the settings menu cassette.
}

/// A Riverpod notifier managing the current [CassetteRack].
///
/// This class follows the class‑based provider syntax described in the
/// Riverpod documentation.  It exposes methods to mutate the rack in
/// response to user interactions (pushing new cassettes, updating existing
/// ones, truncating the stack, etc.).  Because the notifier’s state is
/// immutable, each mutation produces a new [CassetteRack] instance.
@riverpod
class CassetteRackState extends _$CassetteRackState {
  @override
  CassetteRack build(SidebarMode mode) {
    final isPopulated = ref.watch(conversationGraphPopulatedProvider);
    switch (mode) {
      case SidebarMode.messages:
        if (!isPopulated) {
          return const CassetteRack(
            cassettes: [
              CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.topChatMenu(),
              ),
            ],
          );
        }
        return CassetteRack.initial();
      case SidebarMode.settings:
        return _settingsInitialRack();
    }
  }

  /// Reset to the simple single top‑menu tracer bullet state.
  void resetToInitial() {
    switch (mode) {
      case SidebarMode.messages:
        state = CassetteRack.initial();
      case SidebarMode.settings:
        state = _settingsInitialRack();
    }
  }

  CassetteRack _settingsInitialRack() {
    const settingsMenu = CassetteSpec.sidebarUtility(
      SidebarUtilityCassetteSpec.settingsMenu(),
    );

    return CassetteRack(cassettes: _cascadeForCurrentMode(settingsMenu));
  }

  StableCassetteTopologyContext _stableTopologyContext() {
    final flowState = ref.read(sidebarFlowProvider);
    final messageScope = flowState.messageScope;
    return StableCassetteTopologyContext(
      messageScope: switch (messageScope) {
        SidebarFlowMessageScope.regular => StableCascadeMessageScope.regular,
        SidebarFlowMessageScope.recoveredDeleted =>
          StableCascadeMessageScope.recoveredDeleted,
      },
      persistentSettingsContext: flowState.persistentSettingsContext,
    );
  }

  List<CassetteSpec> _cascadeForCurrentMode(CassetteSpec root) {
    return _cascadeFromSpec(root, topologyContext: _stableTopologyContext());
  }

  /// Convenience for just updating the top chat menu cassette.  The
  /// [chosenMenuIndex] parameter determines which option is selected; if null
  /// it defaults to whatever the factory uses by default.  This is used by
  /// UI interactions in the tracer‑bullet phase.
  // void setTopChatMenu({TopChatMenuChoice chosenTopMenuChoice}) {
  //   final topMenu = const CassetteSpec.sidebarUtility(
  //     SidebarUtilityCassetteSpec.topChatMenu(
  //       selectedChoice:
  //           selectedChoice ??
  //           SidebarUtilityCassetteSpec.topChatMenu().chosenMenuIndex,
  //     ),
  //   );
  //   state = state.copyWith(cassettes: _cascadeFromSpec(topMenu));
  // }

  /// Replace the cassette at [index] with [newSpec] and re-cascade children.
  ///
  /// This is the preferred method for widgets to update their cassette spec
  /// in response to user interaction. The widget receives its [index] from
  /// the resolver (which received it from the coordinator), constructs the
  /// new spec locally, and calls this method.
  ///
  /// This approach avoids requiring widgets to hold the old spec in state,
  /// which would violate the cross-surface spec system rules.
  ///
  /// If the index is out of bounds, this is a no-op.
  void replaceAtIndexAndCascade(int index, CassetteSpec newSpec) {
    if (index < 0 || index >= state.cassettes.length) {
      return;
    }

    final preserved = state.cassettes.take(index).toList(growable: false);
    final isPopulated = ref.read(conversationGraphPopulatedProvider);
    final cascaded = isPopulated
        ? _cascadeForCurrentMode(newSpec)
        : <CassetteSpec>[newSpec];
    state = state.copyWith(
      cassettes: List<CassetteSpec>.unmodifiable([...preserved, ...cascaded]),
    );
  }

  /// Find the most recently selected contact ID in the cassette stack.
  ///
  /// This method scans the cassettes from the last (deepest) to the first,
  /// looking for a [CassetteSpec.contacts] variant.  Once found, it
  /// examines the underlying [ContactsCassetteSpec] and returns the
  /// `chosenContactId`, regardless of whether the spec is a
  /// [ContactsCassetteSpec.contactsFlatMenu],
  /// [ContactsCassetteSpec.contactsEnhancedPicker], or
  /// [ContactsCassetteSpec.contactHeroSummary]. If no contact has been
  /// selected yet, it returns null.
  int? findLatestContactId() {
    for (final spec in state.cassettes.reversed) {
      final result = spec.when(
        sidebarUtility: (_) => null,
        contacts: (contactsSpec) {
          return contactsSpec.when(
            contactChooser: (chosenContactId) => chosenContactId,
            contactSelectionControl: (chosenContactId) => chosenContactId,
            contactHeroSummary: (chosenContactId) => chosenContactId,
            messageScopeToggle: (contactId) => contactId,
            handleFilter: (contactId, _) => contactId,
          );
        },
        contactsInfo: (_) => null,
        handles: (_) => null,
        handlesInfo: (_) => null,
        messages: (_) => null,
        messagesInfo: (_) => null,
        settings: (_) => null,
      );
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
