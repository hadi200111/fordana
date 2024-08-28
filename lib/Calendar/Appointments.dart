class Appointments {
  String author;
  String docID;
  String subject;
  String description;
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String location;
  String? notes;
  String status;

  Appointments({
    required this.author,
    required this.subject,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.notes,
    required this.status,
    required this.docID,
  });

  void submitAppointment() {
    print("appointment submited");
  }

  @override
  String toString() {
    return 'Appointments{id: $author, subject: $subject, description: $description, date: $date, startTime: $startTime, appointmentLength: $endTime, location: $location, notes: $notes, status: $status}';
  }
}
