import 'package:CampusConnect/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:CampusConnect/Calendar/Appointments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:CampusConnect/Calendar/Addappointment.dart';
import 'package:CampusConnect/Calendar/AppointmentDetailsPage.dart';
import 'package:CampusConnect/main.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../WelocomeLogIn/LogInPage.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final CalendarController _controller = CalendarController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "calendar".tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Book',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAppointment()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: getAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Appointment> appointments = snapshot.data!;
            return SfCalendar(
              view: CalendarView.month,
              allowedViews: [
                CalendarView.month,
                CalendarView.week,
                CalendarView.day,
              ],
              controller: _controller,
              initialDisplayDate: DateTime.now(),
              dataSource: MeetingDataSource(appointments),
              onTap: calendarTapped,
              monthViewSettings: MonthViewSettings(
                navigationDirection: MonthNavigationDirection.vertical,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> calendarTapped(CalendarTapDetails calendarTapDetails) async {
    if (_controller.view == CalendarView.month &&
        calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      setState(() {
        _controller.view = CalendarView.day;
      });
    } else if (_controller.view == CalendarView.week) {
      setState(() {
        _controller.view = CalendarView.day;
      });
    } else if (calendarTapDetails.targetElement ==
        CalendarElement.appointment) {
      final Appointment appointment = calendarTapDetails.appointments!.first;
      final docID = appointment.id;

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Appointments').get();
      querySnapshot.docs.forEach((doc) {
        var field1 = doc.get("startTime");
        var field2 = doc.get("endTime");
        var field3 = doc.get("date");
        var field4 = doc.get("subject");
        var field5 = doc.get("author");
        var field6 = doc.get("status");
        var field7 = doc.get("description");
        var field8 = doc.get("location");
        var field9 = doc.get("docID");

        final DateTime startTime1 = (field1 as Timestamp).toDate();
        final DateTime endTime2 = (field2 as Timestamp).toDate();
        final DateTime date = (field3 as Timestamp).toDate();
        DateTime onlyDate = DateTime(date.year, date.month, date.day);

        if (field9 == docID) {
          Globals.app = Appointments(
              author: field5,
              subject: field4,
              description: field7,
              date: onlyDate,
              startTime: startTime1,
              endTime: endTime2,
              location: field8,
              status: field6,
              docID: field9);
        }
      });
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AppointmentDetailsPage(appointment: Globals.app),
          ),
        );
      });
    }
  }

  Future<List<Appointment>> getAppointments() async {
    List<Appointment> meetings = <Appointment>[];
    bool check = false;

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Appointments').get();
    querySnapshot.docs.forEach((doc) {
      var field1 = doc.get("startTime");
      var field2 = doc.get("endTime");
      var field3 = doc.get("date");
      var field4 = doc.get("subject");
      var field5 = doc.get("author");
      var field6 = doc.get("status");
      var field7 = doc.get("docID");

      final DateTime startTime1 = (field1 as Timestamp).toDate();
      final DateTime date = (field3 as Timestamp).toDate();
      final DateTime endTime1 = (field2 as Timestamp).toDate();
      final DateTime mergedDateTime = mergeDateTime(date, startTime1);
      final DateTime mergedDateTime1 = mergeDateTime(date, endTime1);

      Color appointmentColor = Colors.blue;

      if (field5 == Globals.userID) {
        if (field6 == "Private") {
          appointmentColor = Colors.red;
        } else if (field6 == "Public") {
          appointmentColor = Colors.blue;
        } else
          appointmentColor = Colors.yellowAccent;
      } else if (field5 == "university") {
        appointmentColor = Colors.green.shade600;
      }

      for (int i = 0; i < Globals.Schedule.length; i++) {
        if (Globals.Schedule[i] == "Public" ||
            Globals.Schedule[i] == "Private") {
        } else if (field6 == Globals.Schedule[i]) {
          check = true;
        }
      }
      if ((field5 == Globals.userID && field6 == "Private") ||
          field6 == "Public" ||
          check) {
        check = false;
        meetings.add(Appointment(
          startTime: mergedDateTime,
          endTime: mergedDateTime1,
          subject: field4,
          id: field7,
          color: appointmentColor,
        ));
      }
    });
    return meetings;
  }
}

DateTime mergeDateTime(DateTime date, DateTime time) {
  return DateTime(
      date.year, date.month, date.day, time.hour, time.minute, time.second);
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}
