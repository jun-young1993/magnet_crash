enum RandomEvent { none, polarReversal, typeShift, bonusSummon }

extension RandomEventDisplay on RandomEvent {
  String get label => switch (this) {
        RandomEvent.none => '',
        RandomEvent.polarReversal => '극성 반전',
        RandomEvent.typeShift => '타입 셔플',
        RandomEvent.bonusSummon => '자석 소환',
      };
}
