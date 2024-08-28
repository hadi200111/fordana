import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

import '../WelocomeLogIn/LogInPage.dart';

class PushNotificationsServices {
  static String userName =
      Globals.userID; // Ensure Globals.userID is correctly initialized

  static Future<String?> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "campus-connect-3917b",
      "private_key_id": "18d0bf6d21e24044f7015dec3952cdd93152ac78",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCt+D85LtYbAsne\n2mlVYCtRz+dXQHwztEJ4PPYpGOu77OfbW5IACi06Kx0rXl3JAQZpdQm250vlfQ40\npp6rVgswIZ0I915ba2c26bdXjWJdfZYX9Yo/jM4NKxDT2Uiv0X4/8gtfKZsOLyPQ\ndSmf+nM1ddVi+CejrD+VvSr9b6bdFVwyMFSN/rSN7g4plN4XIYZ91aWdI+ypSycr\nUGu2hQ1XEbx5qLjlA9k46F0h41XGzxWJzuukia0SGZ7JAg9EfhYCOJjJBPgftUH3\nhGCxgqIJb710qLmzT3q+kOsI3Hj44tdIc8Me9l3FV208+Kt0j1noOfvQlhf5FE30\nHo0sWN+NAgMBAAECggEAH8JpZlrQzvsOF+9HGgU1u1iJWwIkenruxI0agkuwo2zf\nMgpQR84TziH3UAbI98xGW6O4a4njruhK2t1NK6nIXpfQV4XzVZywqdN2e1cODVPD\nPin+/FWL+1bwmkA5VxGXavyYy11o12jPMLvm5rP96tVRaKE1eVmVfRRdAAntTEBP\nZo6I6zvpoPrUBtxUjSx3jD2TP4ldRTpCEKqGw5QQ//0R7N9T5LPcs4HyQMQuJe3H\ntdjg+EZBMAOx36YOp3HGAKeCEFsCqT8jebRumsmS1WrF6bYNbLx8Fk+VOLgMVx9U\nNBZXzO1VLKJRjh9lE7MUBk+LsU82k4/1zA/ZvTPLuQKBgQD0HdQO5wUWTuehcqke\n4aRT+bz+QV1bsLRCtlFY0kowOue0POKP1YW8FM8jZqu9ZERJ0yIEfp+WwBcDvbvg\nI+DFhVs3P1/aE2f5VGYFadwQmDnpSCKJL7a0xdl/UbaJJ1zXBEBpgejtY0E7ydk5\niuA/4JXDn6W1jeqWQXUJKdSmVQKBgQC2cEBnJMRJ8wjHOFrZB5+/tfx+1H1+egZs\nfDdHsoBcGFv/BvXZSqOvDkqworwoRyfLOVyLdVXnDGcT+RUwYmrceW4o4DMu1Byy\naWFrSRoSg9QruynHKMt7muL8CaDO6VRU2dGUGLxHF8T5/ABCgsxUpOiT5vMt4KXv\nm6V97pLcWQKBgHZwhnOYiLJTJDUDwaQ3DBimQZkGs7oJ2NvJQ1yZ4t7VpZegNrhc\ne59OZVWiuc6Q+ETtSELwAJQOrNvm0WGlZqfO1PvQJrxS0A57cWhM/TWb9fUGR6NR\n4A6DM8x/I9YVoAi+ilXmbtHGZ18PxvIRPE4hs+gO7EJTEa9HIPaKMh9lAoGAecT8\nx5t7xJwJ7OcJhDiZgN1YVdNAnA2Yggp630kecdn0dYlQySMPk8VnRvSnv/6Wage0\nZIUBvEDEAEnNwci+6L/ILlJO91+uc8rwsipN07PYBwRaw0rQXoUoIe/PPKvylNv6\nDe5gpNcRq4VvKvWgqpKThjytbZ63QvHRiPeXYKkCgYEAu24kScsYD9V0jg2O0SS+\n++KaftdGAuxD5KfVOtnW9aQE20SFm0SqfdDzQHfjaCnS3mrXC7tA5ztMMAEHS1+l\n5kNt8wg+v/owEEUp6wLhwTYdfTiiKBAhFy/cOloC0PvUXgLdL2dhgSE4u1dEDx/i\nkWR7W5aIcafDQDY8nwM5gUs=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "campusconnect@campus-connect-3917b.iam.gserviceaccount.com",
      "client_id": "100529401887771164864",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/campusconnect%40campus-connect-3917b.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = http.Client();
    auth.AccessCredentials credentials;

    try {
      credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );
    } catch (e) {
      print('Error obtaining access credentials: $e');
      return null;
    } finally {
      client.close();
    }

    return credentials.accessToken.data;
  }

  static Future<void> sendNotification(
      String deviceToken, String title, String body) async {
    final String? accessToken = await getAccessToken();
    if (accessToken == null) {
      print('Failed to obtain access token');
      return;
    }

    final String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/campus-connect-3917b/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': deviceToken,
        'notification': {'title': title, 'body': body}
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  static void sendChatNotification(
      String deviceToken, String senderName, String messageContent) {
    String title = 'New message from $senderName';
    String body = messageContent;
    sendNotification(deviceToken, title, body);
  }
}
