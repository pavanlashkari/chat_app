import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<void> setupPushNotifications() async {
    final fcm =FirebaseMessaging.instance;
    fcm.requestPermission();
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPushNotifications();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: TextButton.icon(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.exit_to_app_outlined),
            label: const Text('SIGN OUT'),
          ),
        ),
        appBar: AppBar(
          title: const Text('Flutter Chat'),
        ),
        body: const Column(
          children: [
            Expanded(
              child: ChatMessage(),
            ),
            NewMessages(),
          ],
        ));
  }
}
