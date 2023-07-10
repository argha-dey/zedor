import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OwnMessageCard extends StatelessWidget {
  const OwnMessageCard(
      {Key? key,
      required this.message,
      required this.time,
      required this.sender_name,
      required this.type})
      : super(key: key);
  final dynamic message;
  final String? time;
  final String? type;
  final String? sender_name;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: Color(0xffdcf8c6),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Positioned(
                top: 2,
                right: 5,
                child: Row(
                  children: [
                    Text(
                      getInitials(sender_name),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 50,
                  top: 20,
                  bottom: 20,
                ),
                child: Text(
                  message!,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 5,
                child: Row(
                  children: [
                    Text(
                      readTimestamp(int.parse(time!)),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getInitials(bank_account_name) {
    List<String> names = bank_account_name.split(" ");
    String initials = "";
/*    int numWords = 2;

    if(numWords < names.length) {
      numWords = names.length;
    }
    for(var i = 0; i < numWords; i++){
      initials += '${names[i][0]}';
    }*/
    initials = names[0];
    return initials;
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY';
      } else {
        time = diff.inDays.toString() + ' DAYS';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS';
      }
    }

    return time;
  }
}
