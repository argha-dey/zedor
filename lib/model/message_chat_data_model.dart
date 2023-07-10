class MessageChatDataModel {
  dynamic typeWebhook;
  InstanceData? instanceData;
  dynamic timestamp;
  dynamic idMessage;
  SenderData? senderData;
  MessageData? messageData;

  MessageChatDataModel(
      {this.typeWebhook,
      this.instanceData,
      this.timestamp,
      this.idMessage,
      this.senderData,
      this.messageData});

  MessageChatDataModel.fromJson(Map<String, dynamic> json) {
    typeWebhook = json['typeWebhook'];
    instanceData = json['instanceData'] != null
        ? new InstanceData.fromJson(json['instanceData'])
        : null;
    timestamp = json['timestamp'];
    idMessage = json['idMessage'];
    senderData = json['senderData'] != null
        ? new SenderData.fromJson(json['senderData'])
        : null;
    messageData = json['messageData'] != null
        ? new MessageData.fromJson(json['messageData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeWebhook'] = this.typeWebhook;
    if (this.instanceData != null) {
      data['instanceData'] = this.instanceData!.toJson();
    }
    data['timestamp'] = this.timestamp;
    data['idMessage'] = this.idMessage;
    if (this.senderData != null) {
      data['senderData'] = this.senderData!.toJson();
    }
    if (this.messageData != null) {
      data['messageData'] = this.messageData!.toJson();
    }
    return data;
  }
}

class InstanceData {
  dynamic idInstance;
  dynamic wid;
  dynamic typeInstance;

  InstanceData({this.idInstance, this.wid, this.typeInstance});

  InstanceData.fromJson(Map<String, dynamic> json) {
    idInstance = json['idInstance'];
    wid = json['wid'];
    typeInstance = json['typeInstance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idInstance'] = this.idInstance;
    data['wid'] = this.wid;
    data['typeInstance'] = this.typeInstance;
    return data;
  }
}

class SenderData {
  dynamic chatId;
  dynamic sender;
  dynamic senderName;

  SenderData({this.chatId, this.sender, this.senderName});

  SenderData.fromJson(Map<String, dynamic> json) {
    chatId = json['chatId'];
    sender = json['sender'];
    senderName = json['senderName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatId'] = this.chatId;
    data['sender'] = this.sender;
    data['senderName'] = this.senderName;
    return data;
  }
}

class MessageData {
  String? typeMessage;
  TextMessageData? textMessageData;

  MessageData({this.typeMessage, this.textMessageData});

  MessageData.fromJson(Map<String, dynamic> json) {
    typeMessage = json['typeMessage'];
    textMessageData = json['textMessageData'] != null
        ? new TextMessageData.fromJson(json['textMessageData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeMessage'] = this.typeMessage;
    if (this.textMessageData != null) {
      data['textMessageData'] = this.textMessageData!.toJson();
    }
    return data;
  }
}

class TextMessageData {
  String? textMessage;

  TextMessageData({this.textMessage});

  TextMessageData.fromJson(Map<String, dynamic> json) {
    textMessage = json['textMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['textMessage'] = this.textMessage;
    return data;
  }
}
