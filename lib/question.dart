import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:cached_network_image/cached_network_image.dart';

class Answer {
  final String id;
  final String answer;
  final bool correct;

  Answer({@required this.id, @required this.answer, @required this.correct});

  Answer.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        answer = json['answer'],
        correct = json['correct'];
}

class Question {
  final String id;
  final String section;
  final String question;
  final String image;
  final Map<String, Answer> answers;
  final String correct;

  Question(
      {@required this.id,
      @required this.section,
      @required this.question,
      @required this.image,
      @required this.answers,
      @required this.correct});

  Question.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        section = json['section'],
        question = json['question'],
        image = json['image'],
        correct = json['correct'],
        answers = (json['answers'] as Map<String, dynamic>).map(
            (String id, dynamic json) => MapEntry(id, Answer.fromJson(json)));
}

class QuestionWidget extends StatelessWidget {
  final Question question;
  final String selected;
  final bool submitted;
  final Function select;
  final Function submit;
  final Function next;

  QuestionWidget(this.question, this.selected, this.submitted, this.select,
      this.submit, this.next);

  Widget _button(BuildContext context) {
    if (submitted) {
      return RaisedButton(
          child: Text('Далі'),
          color: Theme.of(context).primaryColor,
          onPressed: () {
            next();
          });
    } else {
      if (selected == '') {
        return FlatButton(child: Text('Перевірити'), onPressed: null);
      } else {
        return RaisedButton(
            child: Text('Перевірити'),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              submit();
            });
      }
    }
  }

  Widget _buildAnswerWidget(String id) {
    String text = question.answers[id].answer;

    IconData icon = submitted
        ? question.correct == id ? Icons.check : Icons.close
        : selected == id ? Icons.arrow_forward : null;

    Color color = submitted
        ? question.correct == id ? Colors.green : Colors.red
        : Colors.transparent; // Colors.black;

    return Container(
        decoration: BoxDecoration(
            color: selected == id ? Color(0xffe6e6e6) : Colors.transparent),
        child: ListTileTheme(
            selectedColor: Colors.black,
            child: ListTile(
                contentPadding: text.length > 34
                    ? EdgeInsets.all(16.0)
                    : EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
                trailing: Icon(icon, color: color),
                title: Text(text),
                selected: id == selected,
                onTap: submitted ? null : () => select(id))));
  }

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return Scaffold(body: Center(child: Text('Завантаження')));
    }

    List<Widget> children = [
      ListTile(
          title: Text(question.question,
              style: TextStyle(fontWeight: FontWeight.bold))),
      Column(
        children: ListTile.divideTiles(
                context: context,
                tiles: question.answers.keys
                    .map((String id) => _buildAnswerWidget(id))
                    .toList())
            .toList(),
      )
    ];

    if (question.image != null && question.image.indexOf('no_image') == -1) {
      // children.insert(0, ListTile(title: Image.asset('assets/images/' + question.image.split('/').last)));
       children.insert(0, ListTile(title: Image.asset('assets/questions/' + question.image.split('/').last)));

       //import 'package:cached_network_image/cached_network_image.dart';

//      String src = 'https://rawcdn.githack.com/mac2000/pdr/master/assets/images/' + question.image.split('/').last;
//      children.insert(0, ListTile(title: CachedNetworkImage(
//        imageUrl: src,
//        placeholder: Row(
//          mainAxisSize: MainAxisSize.max,
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[new CircularProgressIndicator()],
//        ),
//        errorWidget: new Icon(Icons.error),
//      )));
    }

//    children.insert(0, ListTile(
//      title: Text('Большой апдейт'),
//      subtitle: Text('Привет мир'),
//    ));

    children.insert(0, new Container (
       padding: EdgeInsets.only(left: 0.0, right: 0.0, top: 8.0, bottom: 8.0),
        margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
        decoration: new BoxDecoration (
            color: Colors.orangeAccent
        ),
        child: new ListTile (
          onTap: _launchURL,
          trailing: const Icon(Icons.warning),
          title: Text('Вопросы с картиками временно не доступны'),
          subtitle: new Container(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Подробности и планы', style: TextStyle(color: Colors.blue),)
          ),
        )
    ));

    return Scaffold(
        appBar: AppBar(title: Text('Тести ПДР України')),
        body: ListView(children: children, padding: EdgeInsets.only(top: 12.0)),
        bottomNavigationBar:
            BottomAppBar(child: ListTile(title: _button(context))));
  }

  _launchURL() async {
    final url = 'https://github.com/mac2000/pdr/blob/master/README.md';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
