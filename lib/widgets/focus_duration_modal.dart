import 'package:flutter/material.dart';

Future<void> showFocusDurationModal({
  required BuildContext context,
  required Duration currentDuration,
  required Function(Duration) onDurationSelected,
}) async {
  Duration tempDuration = currentDuration;

  await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Focus Duration',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [1, 30, 45].map((minutes) {
                    return ChoiceChip(
                      label: Text('$minutes min'),
                      selected: tempDuration.inMinutes == minutes,
                      onSelected: (_) {
                        setModalState(() {
                          tempDuration = Duration(minutes: minutes);
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    onDurationSelected(tempDuration);
                    Navigator.pop(context);
                  },
                  child: const Text('Start'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
