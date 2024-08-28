import 'package:CampusConnect/Calendar/Appointments.dart';
import 'package:CampusConnect/WelocomeLogIn/LogInPage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final Appointments appointment;

  const AppointmentDetailsPage({Key? key, required this.appointment})
      : super(key: key);

  @override
  _AppointmentDetailsPageState createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  bool _reminder = false;
  bool _isEditing = false;
  late TextEditingController _subjectController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _subjectController =
        TextEditingController(text: widget.appointment.subject);
    _descriptionController =
        TextEditingController(text: widget.appointment.description);
    _locationController =
        TextEditingController(text: widget.appointment.location);
    _notesController = TextEditingController(text: widget.appointment.notes);
    _selectedDate = widget.appointment.date;
    _startTime = TimeOfDay.fromDateTime(widget.appointment.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.appointment.endTime);
  }

  Future<void> editAppointment(Appointments appointment) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Appointments').get();
      querySnapshot.docs.forEach((doc) async {
        var docuementID = doc.get("docID");

        if ((docuementID == appointment.docID)) {
          CollectionReference appointmentsCollection =
              FirebaseFirestore.instance.collection('Appointments');
          await appointmentsCollection.doc(docuementID).update({
            'subject': appointment.subject,
            'description': appointment.description,
            'date': appointment.date,
            'startTime': appointment.startTime,
            'endTime': appointment.endTime,
            'location': appointment.location,
            'notes': appointment.notes,
            'status': appointment.status,
            'docID': appointment.docID,
          });
          setState(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AppointmentDetailsPage(appointment: appointment),
              ),
            );
          });
        }
      });

      print('Appointment updated successfully.');
    } catch (error) {
      print('Error updating appointment: $error');
      _showAlertDialog('Error', 'Error updating appointment: $error');
    }
  }

  Future<void> deleteAppointment(String documentID) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Appointments').get();
      querySnapshot.docs.forEach((doc) async {
        CollectionReference appointmentsCollection =
            FirebaseFirestore.instance.collection('Appointments');
        var docID = doc.get("docID");

        if ((docID == documentID)) {
          await appointmentsCollection.doc(documentID).delete();
        }
      });
      // Assuming `appointmentId` is the document ID.

      print('Appointment deleted successfully. ' + documentID);
    } catch (error) {
      print('Error deleting appointment: $error');
      _showAlertDialog('Error', 'Error deleting appointment: $error');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null)
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Author:', widget.appointment.author),
                  _isEditing
                      ? _buildEditableRow('Subject:', _subjectController)
                      : _buildDetailRow('Subject:', widget.appointment.subject),
                  _isEditing
                      ? _buildEditableRow(
                          'Description:', _descriptionController)
                      : _buildDetailRow(
                          'Description:', widget.appointment.description),
                  _isEditing
                      ? _buildDateRow('Date:', _selectedDate, _selectDate)
                      : _buildDetailRow(
                          'Date:',
                          DateFormat('dd-MM-yyyy')
                              .format(widget.appointment.date)),
                  _isEditing
                      ? _buildTimeRow('Start Time:', _startTime, true)
                      : _buildDetailRow(
                          'Start Time:',
                          DateFormat('hh:mm a')
                              .format(widget.appointment.startTime)),
                  _isEditing
                      ? _buildTimeRow('End Time:', _endTime, false)
                      : _buildDetailRow(
                          'End Time:',
                          DateFormat('hh:mm a')
                              .format(widget.appointment.endTime)),
                  _isEditing
                      ? _buildEditableRow('Location:', _locationController)
                      : _buildDetailRow(
                          'Location:', widget.appointment.location),
                  if (widget.appointment.notes != null)
                    _isEditing
                        ? _buildEditableRow('Notes:', _notesController)
                        : _buildDetailRow('Notes:', widget.appointment.notes!),
                  _buildDetailRow('Status:', widget.appointment.status),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _reminder,
                        onChanged: (value) {
                          setState(() {
                            _reminder = value!;
                          });
                        },
                      ),
                      Text(
                        'Set Reminder',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                  if (widget.appointment.author == Globals.userID)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_isEditing) {
                                final updatedAppointment = Appointments(
                                  author: widget.appointment.author,
                                  subject: _subjectController.text,
                                  description: _descriptionController.text,
                                  date: _selectedDate,
                                  startTime: DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      _startTime.hour,
                                      _startTime.minute),
                                  endTime: DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      _endTime.hour,
                                      _endTime.minute),
                                  location: _locationController.text,
                                  notes: _notesController.text,
                                  status: widget.appointment.status,
                                  docID: widget.appointment.docID,
                                );
                                editAppointment(updatedAppointment);
                                setState(() {
                                  _isEditing = false;
                                });
                              } else {
                                setState(() {
                                  _isEditing = true;
                                });
                              }
                            },
                            icon: Icon(_isEditing ? Icons.save : Icons.edit),
                            label: Text(_isEditing ? 'Save' : 'Edit'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          if (!_isEditing)
                            ElevatedButton.icon(
                              onPressed: () =>
                                  deleteAppointment(widget.appointment.docID),
                              icon: Icon(Icons.delete),
                              label: Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              style: TextStyle(fontSize: 16, color: Colors.black87),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(
      String label, DateTime date, Function(BuildContext) onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => onTap(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(
                      text: DateFormat('dd-MM-yyyy').format(date)),
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, TimeOfDay time, bool isStartTime) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _selectTime(context, isStartTime),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(text: time.format(context)),
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
