import 'package:flutter/material.dart';
import 'package:pharmabuddy/main.dart';
import 'package:pharmabuddy/models/drug.dart';

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
              Drug drug = Drug(
                name: drugController.text,
                dosage: dosageController.text,
                times: drugTimes
                    .where((time) => time != null)
                    .cast<TimeOfDay>()
                    .toList(), // to handle null values passed into the druglist
                days: selectedDays,
              );
              scheduleNotification(drug);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Drug Successfully Scheduled')));
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

class WeekdaySelector extends StatefulWidget {
  final List<bool> selectedDays;

  WeekdaySelector({required this.selectedDays});

  @override
  _WeekdaySelectorState createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  Widget build(BuildContext context) {
    return ToggleButtons(
      children: <Widget>[
        Text('M'),
        Text('T'),
        Text('W'),
        Text('T'),
        Text('F'),
        Text('S'),
        Text('Su'),
      ],
      onPressed: (int index) {
        setState(() {
          widget.selectedDays[index] = !widget.selectedDays[index];
        });
      },
      isSelected: widget.selectedDays,
    );
  }
}
