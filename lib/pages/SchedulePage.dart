import 'package:flutter/material.dart';
import 'package:pharmabuddy/main.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

// Create the UI for the Schedule
class _SchedulePageState extends State<SchedulePage> {
  TextEditingController drugController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  List<TimeOfDay?> drugTimes = [null];
  List<bool> selectedDays = List.generate(7, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule Drug')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: drugController,
            decoration: InputDecoration(labelText: 'Drug Name'),
          ),
          SizedBox(height: 10),
          TextField(
            controller: dosageController,
            decoration: InputDecoration(labelText: 'Dosage'),
          ),
          SizedBox(height: 10),
          ...drugTimes.map((time) {
            return TimePicker(time: time);
          }).toList(),
          ElevatedButton(
            child: Text('Add Another Time +'),
            onPressed: () {
              setState(() {
                drugTimes.add(null);
              });
            },
          ),
          SizedBox(height: 10),
          WeekdaySelector(selectedDays: selectedDays),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: () {
              scheduleNotification();
            },
          ),
        ],
      ),
    );
  }
}

class TimePicker extends StatefulWidget {
  final TimeOfDay? time;

  TimePicker({this.time});

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(selectedTime?.format(context) ?? 'Choose Time'),
      trailing: Icon(Icons.access_time),
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (pickedTime != null && pickedTime != selectedTime) {
          setState(() {
            selectedTime = pickedTime;
          });
        }
      },
    );
  }
}

class WeekdaySelector extends StatelessWidget {
  final List<bool> selectedDays;

  WeekdaySelector({required this.selectedDays});

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: <Widget>[
        Text('M'),
        Text('T'),
        Text('W'),
        Text('T'),
        Text('F'),
        Text('S'),
        Text('S'),
      ],
      onPressed: (int index) {},
      isSelected: selectedDays,
    );
  }
}
