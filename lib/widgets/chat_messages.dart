import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {

    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found'),
          );
        }
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong....'),
          );
        }

        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final ChatMessage= loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data():null;

              final currentMessageUserId = ChatMessage['userId'];
              final nextChatMessageUserId = nextChatMessage != null ? nextChatMessage['userId']: null;

            final nextUserIsSame = nextChatMessageUserId == currentMessageUserId;


            if (nextUserIsSame){
              return MessageBubble.next(
                message: ChatMessage['text'], 
                isMe: authenticatedUser.uid == currentMessageUserId,
                );
            
            } else{
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username:  chatMessage['username'],
                message:   chatMessage['text'],
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
            });
      },
    );
  }
}
