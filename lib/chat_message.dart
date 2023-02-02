import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !mine ?
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['senderPhotoUrl']),
            ),
          ) : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  data['senderName'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                data['imgUrl'] != null ?
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(data['imgUrl'], width: 250),
                    )
                :
                    Text(
                      data['text'],
                      textAlign: mine ? TextAlign.end : TextAlign.start,
                      style: TextStyle(
                        fontSize: 16
                      ),
                    ),
              ],
            ),
          ),
          mine ?
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data['senderPhotoUrl']),
            ),
          ) : Container(),
        ],
      ),
    );
  }
}
