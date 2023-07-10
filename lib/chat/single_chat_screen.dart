import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'dart:math';
import 'package:encrypt/encrypt.dart';

import 'package:flutter/material.dart' hide Key;
import 'package:hive/hive.dart';

import '../../../global/PrefKeys.dart';
import '../../../global/config.dart';
import '../../../global/global.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:ui';
import '../custom_ui/own_msg_card.dart';
import '../custom_ui/reply_card.dart';
import '../model/message_chat_data_model.dart';

class SingleChatScreen extends StatefulWidget {
  final String? idInstance;
  final String? apiTokenInstance;
  final String? wid;
  final String? to_user_name;
  final String? phone_number;
  final String? img;

  const SingleChatScreen({
    this.idInstance,
    this.apiTokenInstance,
    this.wid,
    this.to_user_name,
    this.phone_number,
    this.img,
  });

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  final key = Key.fromUtf8('mOeR%QVWK1rayZOUMWvs6Zi5Q6h*VlSk'); //32 chars
  final iv = IV.fromUtf8('RUDb*jP5xw3PaMx%'); //16char
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLl@%^!~*(&#MmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  String? from_user_id;
  String? from_user_name;
  int initialCount = 0;
  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  late IO.Socket _socket;
  TextEditingController _dataController = TextEditingController();

  ChatMessageModel? chatMessageModel;
  late var timerConnectWebSocket;
  List<ChatMessageModel> chatMessages = [];
  List<ChatOldMessageModel> oldChatMessages = [];

  var screenHeight =
      (window.physicalSize.longestSide / window.devicePixelRatio);

  var nextPageUrl;
  var loadCompleted = false;
  var firstTimeLoad = true;

  ScrollController _scrollControllerIndividual = new ScrollController();
  Random _rnd = Random();
  late Box _box;

  getScreenSize() {
    // Screen size in density independent pixels
    //  var screenWidth = (window.physicalSize.shortestSide / window.devicePixelRatio);

    if (screenHeight > 500 && screenHeight < 600) {
      initialCount = 6;
    } else if (screenHeight > 601 && screenHeight < 700) {
      initialCount = 7;
    } else if (screenHeight > 701 && screenHeight < 800) {
      initialCount = 8;
    } else if (screenHeight > 801 && screenHeight < 900) {
      initialCount = 10;
    } else if (screenHeight > 901 && screenHeight < 1000) {
      initialCount = 10;
    } else if (screenHeight > 1001 && screenHeight < 1100) {
      initialCount = 11;
    } else {
      initialCount = 12;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      oldMessageList(initialCount);
    });
    print("Screen Size: " + screenHeight.toString());
  }

//encrypt
  String encryptMyData(String text) {
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted_data = e.encrypt(text, iv: iv);
    return encrypted_data.base64;
  }

//dycrypt
  String decryptMyData(String text) {
    final e = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted_data = e.decrypt(Encrypted.fromBase64(text), iv: iv);
    return decrypted_data;
  }

  bool isEncrypted(String inputText) {
    try {
      var decoded_bytes = base64.decode(inputText);
      inputText = utf8.decode(decoded_bytes);
      inputText =
          inputText.toString().substring(4, inputText.toString().length - 4);
      inputText = decryptMyData(inputText);
      return true;
    } catch (Exception) {
      return false;
    }
  }

  Future<void> oldMessageList(int count) async {
    print("message count call: " + count.toString());
    try {
      FocusScope.of(context).requestFocus(FocusNode());
      global().showLoader(context);
      final uri = Uri.parse(
          "https://api.green-api.com/waInstance${widget.idInstance}/GetChatHistory/${widget.apiTokenInstance}");

      debugPrint("admin group list url: $uri");

      var requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      var requestBody = {
        "chatId": widget.phone_number.toString() + '@c.us',
        "count": count
      };

      debugPrint("group Detail url: $requestHeaders");

      final response = await http.post(uri,
          body: jsonEncode(requestBody), headers: requestHeaders);

      debugPrint("response : " + json.decode(response.body).toString());

      global().hideLoader(context);
      List<ChatOldMessageModel> oldChatMessagesTemp = [];
      dynamic responseJson;

      if (response.statusCode == 200) {
        debugPrint("success ");
        setState(() {
          responseJson = json.decode(response.body);
          oldChatMessages = [];
          chatMessages = [];
          oldChatMessages = (responseJson as List)
              .map((data) => new ChatOldMessageModel.fromJson(data))
              .toList();

          oldChatMessagesTemp = oldChatMessages.reversed.toList();

          for (ChatOldMessageModel chatData in oldChatMessagesTemp) {
            //typeWebhook
            if ((chatData.type.toString() == "outgoing" &&
                    chatData.typeMessage.toString() == "textMessage") ||
                (chatData.type.toString() == "outgoing" &&
                    chatData.typeMessage.toString() == "extendedTextMessage")) {
              var textMsg = "";

              if (isEncrypted(chatData.textMessage.toString())) {
                var decoded_bytes =
                    base64.decode(chatData.textMessage.toString());
                textMsg = utf8.decode(decoded_bytes);
                textMsg = textMsg
                    .toString()
                    .substring(4, textMsg.toString().length - 4);
                textMsg = decryptMyData(textMsg);
                // textMsg = decryptMyData(chatData.textMessage);
              } else {
                textMsg = chatData.textMessage;
              }

              //  textMsg = chatData.textMessage;

              //todo: time will be cal from at the time of scan qr code
              bool diff = (_box.get(PrefKeys.SET_USER_SCANNING_TIME) <
                  chatData.timestamp);

              if (diff) {
                chatMessages.add(new ChatMessageModel(
                    id: "",
                    created_at: chatData.timestamp,
                    sender_id: "",
                    receiver_id: "",
                    seen: "",
                    content: textMsg.toString(),
                    name_en: "",
                    name_fr: "",
                    type: ""));
              }
            } else if ((chatData.type.toString() == "incoming" &&
                    chatData.typeMessage.toString() == "textMessage") ||
                (chatData.type.toString() == "incoming" &&
                    chatData.typeMessage.toString() == "extendedTextMessage")) {
              var textMsg = "";
              if (isEncrypted(chatData.textMessage.toString())) {
                var decoded_bytes =
                    base64.decode(chatData.textMessage.toString());
                textMsg = utf8.decode(decoded_bytes);
                textMsg = textMsg
                    .toString()
                    .substring(4, textMsg.toString().length - 4);
                textMsg = decryptMyData(textMsg);
                //   textMsg = decryptMyData(chatData.textMessage);
              } else {
                textMsg = chatData.textMessage;
              }
              //   textMsg = chatData.textMessage;

              //todo: time will be cal from at the time of scan qr code
              bool diff = (_box.get(PrefKeys.SET_USER_SCANNING_TIME) <
                  chatData.timestamp);

              if (diff) {
                chatMessages.add(new ChatMessageModel(
                    id: "",
                    created_at: chatData.timestamp,
                    sender_id: "",
                    receiver_id: "",
                    seen: "",
                    content: textMsg.toString(),
                    name_en: "",
                    name_fr: "",
                    type: "incomingMessageReceived"));
              }
            }
          }
        });
      } else {
        global().showSnackBarShowError(
            context, "Data parsing error!.Try after some time.");
      }
    } catch (e) {
      global().hideLoader(context);
      global().showSnackBarShowError(
          context, "Data parsing error!.Try after some time.");
    }
  }

  @override
  void initState() {
    super.initState();

    getScreenSize();

    _box = Hive.box('zedorDataSave');

    timerConnectWebSocket =
        Future.delayed(const Duration(milliseconds: 700), () {
      _connectWebSocket();
    });

    //  _getOldReadMessageList();
    //   _receivedOldReadMessageList();

    individualChatListScrollDataView();
  }

  @override
  void dispose() {
    _scrollControllerIndividual.dispose();
    _socketDisconnect();
    super.dispose();
  }

  _socketDisconnect() {
    _socket.on('disconnect', (data) => print('disconnect : $data'));
  }

  _connectWebSocket() {
    _socket = IO.io(
        'https://py-zedor.developerconsole.xyz:443',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .enableAutoConnect()
            .build());

    _socket.onConnect((data) => print('Connection established Successfully'));
    _socket.onConnectError((data) => print('Connect Error: $data'));
    _receiveMessage();
  }

  void individualChatListScrollDataView() {
    _scrollControllerIndividual.addListener(
      () {
        int incrVal = 0;

        if (screenHeight > 500 && screenHeight < 600) {
          incrVal = 5;
        } else if (screenHeight > 601 && screenHeight < 700) {
          incrVal = 6;
        } else if (screenHeight > 701 && screenHeight < 800) {
          incrVal = 7;
        } else if (screenHeight > 801 && screenHeight < 900) {
          incrVal = 8;
        } else if (screenHeight > 901 && screenHeight < 1000) {
          incrVal = 9;
        } else if (screenHeight > 1001 && screenHeight < 1100) {
          incrVal = 10;
        } else {
          incrVal = 11;
        }

        if (_scrollControllerIndividual.position.pixels ==
            _scrollControllerIndividual.position.minScrollExtent) {
          setState(() {
            if (initialCount < 50) {
              initialCount = initialCount + incrVal;
              oldMessageList(initialCount);
            }
          });
        }

/*        if (_scrollControllerIndividual.position.atEdge) {
          bool isTop = _scrollControllerIndividual.position.pixels == 0;
          if (isTop) {
            setState(() {
              if (initialCount < 41) {
                initialCount = initialCount + 10;
                oldMessageList(initialCount);
              }
            });
          } else {}
        }*/
      },
    );
  }

  void _scrollDown() {
    if (_scrollControllerIndividual.hasClients) {
      _scrollControllerIndividual.animateTo(
        _scrollControllerIndividual.position.maxScrollExtent + 300,
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.linear,
      );
    }
  }

  void _scrollDownMax() {
    if (_scrollControllerIndividual.hasClients) {
      _scrollControllerIndividual.animateTo(
        _scrollControllerIndividual.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 200,
        ),
        curve: Curves.linear,
      );
    }
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  _sendMessageText() {
    final plainText = _dataController.text;
    //Encrypt
    String encrypted =
        getRandomString(4) + encryptMyData(plainText) + getRandomString(4);
    var bytes = utf8.encode(encrypted);
    encrypted = base64.encode(bytes);

    print(encryptMyData(plainText));
    print(encrypted);

    _socket.emit('message-send', {
      "idInstance": widget.idInstance,
      "apiTokenInstance": widget.apiTokenInstance,
      "phone_number": widget.phone_number.toString() + '@c.us',
      "content": encrypted.toString(),
      "type": '3'
    });

    _dataController.clear();
  }

  _getOldReadMessageList() {
    _socket.emit('message:read', {
      "idInstance": widget.idInstance,
      "apiTokenInstance": widget.apiTokenInstance,
      "phone_number": widget.phone_number,
      "count": '1'
    });
  }

/*  _receivedOldReadMessageList() {
    widget.socket!.on('message:read', (eventData) {
      List jsonResponse = json.decode(eventData);

      chatMessages = jsonResponse
          .map((job) => new ChatMessageModel.fromJson(job))
          .toList();
    });
  }*/

  _receiveMessage() {
    _socket.on('webhook', (eventData) {
      var typeWebhook = eventData['typeWebhook'];
      print('webhook: $eventData');

      if (typeWebhook.toString() == 'incomingMessageReceived') {
        var timestamp = eventData['timestamp'];
        var idInstance = eventData['instanceData']['idInstance'];
        var wid = eventData['instanceData']['wid'];
        var sender = eventData['senderData']['sender'];
        if (idInstance.toString() == widget.idInstance.toString() &&
            sender.toString() == widget.phone_number.toString() + '@c.us') {
          var typeMessage = eventData['messageData']['typeMessage'];
          var textMessage = "";
          if (typeMessage.toString() == "textMessage") {
            textMessage =
                eventData['messageData']['textMessageData']['textMessage'];
          } else if (typeMessage.toString() == "extendedTextMessage") {
            textMessage =
                eventData['messageData']['extendedTextMessageData']['text'];
          } else {
            textMessage = "";
          }

          //    print('receive_message: ${textMessage}');

          if (textMessage.length > 0) {
            if (isEncrypted(textMessage.toString())) {
              var decoded_bytes = base64.decode(textMessage.toString());
              textMessage = utf8.decode(decoded_bytes);
              textMessage = textMessage
                  .toString()
                  .substring(4, textMessage.toString().length - 4);
              textMessage = decryptMyData(textMessage);

              // textMessage = decryptMyData(textMessage.toString());
            } else {
              textMessage = textMessage.toString();
            }
            _scrollDown();
            chatMessages.add(new ChatMessageModel(
                id: "",
                created_at: timestamp,
                sender_id: sender,
                receiver_id: wid,
                seen: "",
                content: textMessage,
                name_en: "",
                name_fr: "",
                type: typeWebhook));

            setState(() {});
          }
        }
      } else if (typeWebhook.toString() == 'outgoingAPIMessageReceived') {
        var timestamp = eventData['timestamp'];
        var wid = eventData['instanceData']['wid'];
        var sender = eventData['senderData']['sender'];
        var idInstance = eventData['instanceData']['idInstance'];
        if (idInstance.toString() == widget.idInstance.toString()) {
          final plainText =
              eventData['messageData']['extendedTextMessageData']['text'];

          if (plainText.length > 0) {
            var textMessage = "";
            if (isEncrypted(plainText.toString())) {
              var decoded_bytes = base64.decode(plainText.toString());
              textMessage = utf8.decode(decoded_bytes);
              textMessage = textMessage
                  .toString()
                  .substring(4, textMessage.toString().length - 4);
              textMessage = decryptMyData(textMessage);

              //   textMessage = decryptMyData(plainText.toString());
            } else {
              textMessage = plainText.toString();
            }
            // var textMessage = decryptMyData(plainText);
            _scrollDown();
            chatMessages.add(new ChatMessageModel(
                id: "",
                created_at: timestamp,
                sender_id: sender,
                receiver_id: wid,
                seen: "",
                content: textMessage.toString(),
                name_en: "",
                name_fr: "",
                type: typeWebhook));

            setState(() {});
          }
        }
      } else if (typeWebhook.toString() == 'outgoingMessageReceived') {
        var timestamp = eventData['timestamp'];
        var wid = eventData['instanceData']['wid'];
        var sender = eventData['senderData']['sender'];
        var idInstance = eventData['instanceData']['idInstance'];
        if (idInstance.toString() == widget.idInstance.toString()) {
          final plainText =
              eventData['messageData']['textMessageData']['textMessage'];
          var textMessage = plainText;
          _scrollDown();

          chatMessages.add(new ChatMessageModel(
              id: "",
              created_at: timestamp,
              sender_id: sender,
              receiver_id: wid,
              seen: "",
              content: textMessage,
              name_en: "",
              name_fr: "",
              type: typeWebhook));

          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.red,
          leadingWidth: 70,
          titleSpacing: 0,
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: Icon(
                  Icons.arrow_back,
                  size: 24,
                ),
                onTap: () {
                  _socketDisconnect();
                  Navigator.pop(context);
                },
              ),
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage("images/zedor_logo.png"),
              )
            ],
          ),
          title: InkWell(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.to_user_name.toString(),
                    style: TextStyle(
                      fontSize: 19.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    "",
                    style:
                        TextStyle(fontSize: 1, fontWeight: FontWeight.normal),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                controller: _scrollControllerIndividual,
                itemCount: chatMessages.length + 1,
                itemBuilder: (context, index) {
                  if (index == chatMessages.length) {
                    return Container(
                      height: 50,
                    );
                  }
                  if (chatMessages[index].type.toString() ==
                      "incomingMessageReceived") {
                    // _scrollDownMax();
                    return ReplyCard(
                      message: chatMessages[index].content.toString(),
                      time: chatMessages[index].created_at.toString(),
                      sender_name: "",
                      type: 'text',
                    );
                  } else {
                    //    _scrollDownMax();
                    return OwnMessageCard(
                      message: chatMessages[index].content.toString(),
                      time: chatMessages[index].created_at.toString(),
                      sender_name: "",
                      type: 'text',
                    );
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 60,
                    child: Card(
                      margin: EdgeInsets.only(left: 2, right: 2, bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextFormField(
                        controller: _dataController,
                        focusNode: focusNode,
                        minLines: 1,
                        maxLines: 10,
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.multiline,
                        onChanged: (value) {
                          if (value.length > 0) {
                            setState(() {
                              sendButton = true;
                            });
                          } else {
                            setState(() {
                              sendButton = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Type a message",
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: IconButton(
                            icon: Icon(
                              show ? Icons.keyboard : Icons.keyboard,
                            ),
                            onPressed: () {},
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [],
                          ),
                          contentPadding: EdgeInsets.all(5),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      right: 2,
                      left: 2,
                    ),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: Icon(
                          sendButton ? Icons.send : Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          _sendMessageText();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessageModel {
  dynamic id;
  dynamic created_at;
  dynamic sender_id;
  dynamic receiver_id;
  dynamic seen;
  dynamic content;
  dynamic type;
  dynamic name_en;
  dynamic name_fr;

  ChatMessageModel(
      {this.id,
      this.created_at,
      this.sender_id,
      this.receiver_id,
      this.seen,
      this.content,
      this.type,
      this.name_en,
      this.name_fr});

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    created_at = json['created_at'];
    sender_id = json['sender_id'];
    receiver_id = json['receiver_id'];
    seen = json['seen'];
    content = json['content'];
    name_en = json['name_en'];
    name_fr = json['name_fr'];
    type = json['type'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'created_at': this.created_at,
      'sender_id': this.sender_id,
      'receiver_id': this.receiver_id,
      'seen': this.seen,
      'content': this.content,
      'name_fr': this.name_fr,
      'name_en': this.name_en,
      'type': this.type,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['created_at'] = this.created_at;
    data['sender_id'] = this.sender_id;
    data['receiver_id'] = this.receiver_id;
    data['seen'] = this.seen;
    data['content'] = this.content;
    data['name_fr'] = this.name_fr;
    data['name_en'] = this.name_en;
    data['type'] = this.type;
    return data;
  }
}

class ChatOldMessageModel {
  dynamic type;
  dynamic timestamp;
  dynamic typeMessage;
  dynamic textMessage;
  dynamic chatId;

  //outgoing
  dynamic statusMessage;
  //outgoing
  dynamic sendByApi;

  //incoming
  dynamic senderId;
  //incoming
  dynamic senderName;

  ChatOldMessageModel(
      {this.type,
      this.timestamp,
      this.typeMessage,
      this.textMessage,
      this.chatId,
      this.statusMessage,
      this.sendByApi,
      this.senderId,
      this.senderName});

  ChatOldMessageModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    timestamp = json['timestamp'];
    typeMessage = json['typeMessage'];
    textMessage = json['textMessage'];
    chatId = json['chatId'];
    statusMessage = json['statusMessage'];
    sendByApi = json['sendByApi'];
    senderId = json['senderId'];
    senderName = json['senderName'];
  }

  Map<String, dynamic> toMap() {
    return {
      'type': this.type,
      'timestamp': this.timestamp,
      'typeMessage': this.typeMessage,
      'textMessage': this.textMessage,
      'chatId': this.chatId,
      'statusMessage': this.statusMessage,
      'sendByApi': this.sendByApi,
      'senderId': this.senderId,
      'senderName': this.senderName,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['timestamp'] = this.timestamp;
    data['typeMessage'] = this.typeMessage;
    data['textMessage'] = this.textMessage;
    data['chatId'] = this.chatId;
    data['statusMessage'] = this.statusMessage;
    data['sendByApi'] = this.sendByApi;
    data['senderId'] = this.senderId;
    data['senderName'] = this.senderName;
    return data;
  }
}
