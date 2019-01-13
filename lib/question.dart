import 'package:flutter/material.dart';

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
        return FlatButton(child: Text('Подати'), onPressed: null);
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
        : Colors.black;

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
      children.insert(
          0,
          ListTile(
              title: Image.asset(
                  'assets/images/' + question.image.split('/').last)));
    }

    return Scaffold(
        appBar: AppBar(title: Text('Тести ПДР України')),
        body: ListView(children: children, padding: EdgeInsets.only(top: 12.0)),
        bottomNavigationBar:
            BottomAppBar(child: ListTile(title: _button(context))));
  }
}