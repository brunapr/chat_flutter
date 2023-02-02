import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final Function({String? text, File? imgFile}) sendMessage;

  TextComposer(this.sendMessage);

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();

  bool _isComposing = false;

  void _reset() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.only(left: 5),
            constraints: BoxConstraints(),
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              final XFile? image = await _picker.pickImage(source: ImageSource.camera);
              if(image == null) return;
              widget.sendMessage(imgFile: File(image.path));
            },
          ),
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () async {
              final ImagePicker _picker = ImagePicker();
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
              if(image == null) return;
              widget.sendMessage(imgFile: File(image.path));
            },
          ),
          Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration.collapsed(hintText: 'Enviar uma mensagem'),
                onChanged: (text){
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: (text){
                  widget.sendMessage(text: text);
                  _reset();
                },
            )
          ),
          IconButton(
              onPressed: _isComposing ? (){
                widget.sendMessage(text: _controller.text);
                _reset();
              } : null,
              icon: Icon(Icons.send))
        ],
      )
    );
  }
}
