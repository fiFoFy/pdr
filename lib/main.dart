import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pdr/question.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _random = Random();

  List<Question> questions;
  Question question;
  String selected;
  bool submitted;

  @override
  void initState() {
    super.initState();

    selected = '';
    submitted = false;
    load();
  }

  void load() async {
    final text = await DefaultAssetBundle.of(context).loadString('assets/data.json');
    final data = json.decode(text) as Map<String, dynamic>;

    setState(() {
      questions = data.values.map((dynamic json) => Question.fromJson(json)).toList();
      question = questions[_random.nextInt(questions.length)];
    });
  }

  void select(String id) {
    setState(() {
      selected = id;
    });
  }

  void submit() {
    setState(() {
      submitted = true;
    });
  }

  void next() {
    setState(() {
      selected = '';
      submitted = false;
      question = questions[_random.nextInt(questions.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Тести ПДР України',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: QuestionWidget(
            question, selected, submitted, select, submit, next));
  }
}


