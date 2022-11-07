import 'package:cale/events/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class MyTable extends StatefulWidget {
  const MyTable({super.key});

  @override
  State<MyTable> createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  TextEditingController? _eventController;
  Map<DateTime, List<Event>>? selectedEvents;

  @override
  void initState() {
    super.initState();
    selectedEvents = {};
    _eventController = TextEditingController();
  }

  List<Event> _getEventsfromDay(DateTime date) {
    return selectedEvents?[date] ?? [];
  }

  @override
  void dispose() {
    _eventController?.dispose();
    super.dispose();
  }

  //! Preparing UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        centerTitle: true,
        title: const Text('Demo Calendar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(8.0),
              clipBehavior: Clip.antiAlias,

              //! Calendar addition
              child: TableCalendar(

                //! Calendar decoration
                headerStyle: HeaderStyle(
                  decoration: const BoxDecoration(color: Colors.blue),
                  titleTextStyle: const TextStyle(color: Colors.white),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  formatButtonTextStyle: const TextStyle(color: Colors.white),
                  leftChevronIcon: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                  ),
                  rightChevronIcon: const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                  ),
                ),
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                ),
                headerVisible: true,

                //! Calendar settings
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    if (day.weekday == DateTime.sunday ||
                        day.weekday == DateTime.saturday) {
                      final text = DateFormat.E().format(day);

                      return Center(
                        child: Text(
                          text,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return null;
                  },
                ),
                locale: 'en_US',
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 12, 1),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: ((focusedDay) {
                  focusedDay = focusedDay;
                }),
                eventLoader: _getEventsfromDay,
                calendarFormat: _calendarFormat,
              ),
            ),
            //! Card and ListTile creation for events
            ..._getEventsfromDay(_selectedDay).map(
              (Event event) => Card(
                elevation: 1,
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(event.title),
                  trailing: Wrap(
                    children: <Widget>[

                      //! Edit button
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit Event'),
                              content: TextFormField(
                                controller: _eventController,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),

                                //! Confirm edit button
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('Ok'),
                                ),
                              ],
                            ),
                          );
                          final docEvent = FirebaseFirestore.instance
                              .collection('events')
                              .doc();
                          docEvent.update({'events': _eventController?.text});
                        },
                        icon: const Icon(Icons.edit),
                        color: Colors.black,
                      ),

                      //! Delete Button
                      IconButton(
                        onPressed: () {
                          deleteEvent();
                        },
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      //! Button for Add Event
      floatingActionButton: FloatingActionButton.extended(
        // child: Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Add Event'),
            content: TextFormField(
              controller: _eventController,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),

              //! Create event on calendar and Firebase
              TextButton(
                onPressed: () {
                  if (_eventController!.text.isEmpty) {
                  } else {
                    if (selectedEvents?[_selectedDay] != null) {
                      selectedEvents?[_selectedDay]?.add(
                        Event(title: _eventController!.text),
                      );
                    } else {
                      selectedEvents?[_selectedDay] = [
                        Event(title: _eventController!.text)
                      ];
                    }
                  }
                  final event = _eventController?.text;

                  createEvent(events: event);

                  Navigator.pop(context);
                  _eventController?.clear();
                  setState(() {});
                  return;
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        ),
        label: const Text('Add Event'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

//! Firebase CRUD
Future createEvent({String? events}) async {
  final docEvent = FirebaseFirestore.instance.collection('events').doc();

  final json = {'events': events};
  await docEvent.set(json);
}

Future updateEvent({String? events}) async {}

Future deleteEvent({String? events}) async {
  final docEvent = FirebaseFirestore.instance.collection('events').doc();

  await docEvent.delete();
}