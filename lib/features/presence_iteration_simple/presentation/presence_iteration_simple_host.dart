import 'package:flutter/widgets.dart';

import '../../../essentials/presence/domain/entities/journey.dart';
import '../infrastructure/development/journey_42_fixture.dart';
import 'view/journey_view.dart';

class PresenceIterationSimpleHost extends StatefulWidget {
  const PresenceIterationSimpleHost({super.key});

  @override
  State<PresenceIterationSimpleHost> createState() =>
      _PresenceIterationSimpleHostState();
}

class _PresenceIterationSimpleHostState
    extends State<PresenceIterationSimpleHost> {
  late final Future<Journey> _journey;
  String? _receivedAnswer;

  @override
  void initState() {
    super.initState();
    _journey = loadDevelopmentJourney42();
  }

  void _handleAnswer(String answer) {
    setState(() {
      _receivedAnswer = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Journey>(
      future: _journey,
      builder: (BuildContext context, AsyncSnapshot<Journey> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: Text('Loading Journey 42'));
        }
        final journey = snapshot.data;
        if (journey == null) {
          return const Center(child: Text('Unable to load Journey 42'));
        }
        return Column(
          children: <Widget>[
            Expanded(
              child: JourneyView(journey: journey, onAnswer: _handleAnswer),
            ),
            if (_receivedAnswer case final answer?)
              Text('Answer received: $answer'),
          ],
        );
      },
    );
  }
}
