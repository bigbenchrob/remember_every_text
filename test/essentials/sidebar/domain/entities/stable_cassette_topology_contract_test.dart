import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stable topology contract', () {
    test('a rule may consult one durable fact for its immediate child', () {
      const currentSpec = _ScopeToggleSpec();

      const regularContext = _TestTopologyContext(
        messageScope: _TestMessageScope.regular,
        unrelatedDurableValue: 10,
      );
      const recoveredContext = _TestTopologyContext(
        messageScope: _TestMessageScope.recoveredDeleted,
        unrelatedDurableValue: 99,
      );

      final regularChild = _resolveImmediateChild(
        currentSpec,
        context: regularContext,
      );
      final recoveredChild = _resolveImmediateChild(
        currentSpec,
        context: recoveredContext,
      );

      expect(regularChild, const _RegularImmediateChild());
      expect(recoveredChild, const _RecoveredImmediateChild());
    });

    test(
      'a rule that does not need durable state is unchanged across contexts',
      () {
        const currentSpec = _HeroSummarySpec();

        const regularContext = _TestTopologyContext(
          messageScope: _TestMessageScope.regular,
          unrelatedDurableValue: 1,
        );
        const recoveredContext = _TestTopologyContext(
          messageScope: _TestMessageScope.recoveredDeleted,
          unrelatedDurableValue: 2,
        );

        final regularChild = _resolveImmediateChild(
          currentSpec,
          context: regularContext,
        );
        final recoveredChild = _resolveImmediateChild(
          currentSpec,
          context: recoveredContext,
        );

        const expectedChild = _HeroImmediateChild();

        expect(regularChild, equals(expectedChild));
        expect(recoveredChild, equals(expectedChild));
      },
    );

    test(
      'topology remains single-step and requires a second decision for depth',
      () {
        const context = _TestTopologyContext(
          messageScope: _TestMessageScope.regular,
          unrelatedDurableValue: 7,
        );

        final immediateChild = _resolveImmediateChild(
          const _ScopeToggleSpec(),
          context: context,
        );
        final grandchild = _resolveImmediateChild(
          immediateChild!,
          context: context,
        );

        expect(immediateChild, const _RegularImmediateChild());
        expect(grandchild, const _RegularGrandchild());
      },
    );
  });
}

enum _TestMessageScope { regular, recoveredDeleted }

final class _TestTopologyContext {
  const _TestTopologyContext({
    required this.messageScope,
    required this.unrelatedDurableValue,
  });

  final _TestMessageScope messageScope;
  final int unrelatedDurableValue;
}

sealed class _TestSpec {
  const _TestSpec();
}

final class _ScopeToggleSpec extends _TestSpec {
  const _ScopeToggleSpec();
}

final class _HeroSummarySpec extends _TestSpec {
  const _HeroSummarySpec();
}

final class _RegularImmediateChild extends _TestSpec {
  const _RegularImmediateChild();
}

final class _RecoveredImmediateChild extends _TestSpec {
  const _RecoveredImmediateChild();
}

final class _HeroImmediateChild extends _TestSpec {
  const _HeroImmediateChild();
}

final class _RegularGrandchild extends _TestSpec {
  const _RegularGrandchild();
}

_TestSpec? _resolveImmediateChild(
  _TestSpec currentSpec, {
  required _TestTopologyContext context,
}) {
  switch (currentSpec) {
    case _ScopeToggleSpec():
      switch (context.messageScope) {
        case _TestMessageScope.regular:
          return const _RegularImmediateChild();
        case _TestMessageScope.recoveredDeleted:
          return const _RecoveredImmediateChild();
      }
    case _HeroSummarySpec():
      return const _HeroImmediateChild();
    case _RegularImmediateChild():
      return const _RegularGrandchild();
    case _RecoveredImmediateChild() ||
        _HeroImmediateChild() ||
        _RegularGrandchild():
      return null;
  }
}
