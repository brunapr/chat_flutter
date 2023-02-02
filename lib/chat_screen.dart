import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try{
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication?.idToken,
        accessToken: googleSignInAuthentication?.accessToken,
      );

      final UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = authResult.user;

      return user;

    } catch(error) {
      return null;
    }
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  dynamic _sendMessage({String? text, File? imgFile}) async {
    final User? user = await _getUser();

    if(user == null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível fazer o login. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    Map<String, dynamic> data = {
      "uid": user?.uid,
      "senderName": user?.displayName,
      "senderPhotoUrl": user?.photoURL,
      "time": Timestamp.now(),
    };

    if(imgFile != null) {

      UploadTask task = FirebaseStorage.instance.ref().child(
        user!.uid + DateTime.now().microsecondsSinceEpoch.toString()
      ).putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

/*      UploadTask taskSnapshot = (await task) as UploadTask;

      String url = await taskSnapshot.ref.getDownloadURL();*/

      String url = await (await task.whenComplete(() => null))
          .ref
          .getDownloadURL();

      data['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if(text != null) data['text'] = text;

    firestore.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          _currentUser != null ? '${_currentUser?.displayName}' : 'Chat App'
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null ? IconButton(
              onPressed: (){
                FirebaseAuth.instance.signOut();
                googleSignIn.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Você saiu com sucesso.'),
                  ),
                );
              },
              icon: Icon(Icons.exit_to_app),
          ) : Container(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  switch(snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<QueryDocumentSnapshot<Object?>>? documents =
                          snapshot.data?.docs.reversed.toList();

                      return ListView.builder(
                        itemCount: snapshot.data?.docs.length,
                        reverse: true,
                        itemBuilder: (context, index){
                          Map<String, dynamic> msgData = documents![index].data() as Map<String, dynamic>;
                          print(documents[index].data());
                          return ChatMessage(
                              msgData,
                              msgData['uid'] == _currentUser?.uid
                          );
                        }
                      );

                  }
                },
              ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
