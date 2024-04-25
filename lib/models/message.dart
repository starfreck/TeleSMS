import 'package:readsms/model/sms.dart';

class Message {
  final String sender;
  final String time;
  final String sms;

  const Message({
    required this.sender,
    required this.time,
    required this.sms,
  });

  @override
  String toString() {
    return "👤️ ${Uri.encodeComponent(sender)}\n🕝 $time 🇮🇳\n💬 $sms";
  }

  factory Message.fromSMS(SMS sms) {
    return Message(
      sender: sms.sender,
      time: sms.timeReceived.toString(),
      sms: sms.body,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['number'],
      time: json['received'],
      sms: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': sender,
      'received': time,
      'body': sms,
    };
  }
}
