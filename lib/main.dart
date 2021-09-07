import 'package:flutter/material.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Pages/home.dart';

import 'Pages/friends.dart';

FirebaseAuth auth = FirebaseAuth.instance;
CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference posts = FirebaseFirestore.instance.collection('posts');

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Social Network',
    // Start the app with the "/" named route. In this case, the app starts
    // on the FirstScreen widget.
    initialRoute: '/',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/': (context) => LoginPage(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/myHomePage': (context) => MyHomePage(
          title: "Lil Social Network", uid: auth.currentUser!.uid.toString()),
      '/friends': (context) => friendsPage(
          title: "Lil Social Network", uid: auth.currentUser!.uid.toString()),
    },
  ));
}

// final FirebaseAuth _auth = FirebaseAuth.instance;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  TextEditingController username = new TextEditingController();
  TextEditingController age = new TextEditingController();
  bool keepLoggedOn = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
          backgroundColor: Color(0xAA01E12D),
          title: new Text("Social Network Login"),
        ),
        body: ListView(
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: "Email:"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(hintText: "Password: "),
            ),
            Checkbox(
                value: keepLoggedOn,
                onChanged: (bool? value) => setState(() {
                      keepLoggedOn = value!;
                    })),
            TextButton(
                child: Text(
                  "Register",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Container(
                            height: 500,
                            width: 500,
                            child: Form(
                              key: _formKey,
                              child: ListView(
                                children: [
                                  TextField(
                                    controller: email,
                                    decoration:
                                        InputDecoration(hintText: "Email:"),
                                  ),
                                  TextField(
                                    controller: password,
                                    decoration:
                                        InputDecoration(hintText: "Password: "),
                                  ),
                                  TextField(
                                    controller: username,
                                    decoration:
                                        InputDecoration(hintText: "username: "),
                                  ),
                                  TextField(
                                    controller: age,
                                    decoration:
                                        InputDecoration(hintText: "age: "),
                                  ),
                                  TextButton(
                                    child: Text(
                                      "Register",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        try {
                                          auth
                                              .createUserWithEmailAndPassword(
                                                  email: email.text,
                                                  password: password.text)
                                              .then((res) => {
                                                    auth.currentUser!
                                                        .updateDisplayName(
                                                            username.text),
                                                    addUser(),
                                                    Navigator.pushNamed(
                                                        context, "/myHomePage")
                                                  });
                                        } on FirebaseAuthException catch (e) {
                                          if (e.code == 'weak-password') {
                                            print(
                                                'The password provided is too weak.');
                                          } else if (e.code ==
                                              'email-already-in-use') {
                                            print(
                                                'The account already exists for that email.');
                                          }
                                        } catch (e) {
                                          print(e);
                                          return;
                                        }
                                        Navigator.pushNamed(
                                            context, "/myHomePage");
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }),
            TextButton(
              onPressed: () {
                bool nextPage = true;

                try {
                  auth
                      .signInWithEmailAndPassword(
                          email: email.text, password: password.text)
                      .then((value) =>
                          Navigator.pushNamed(context, "/myHomePage"));
                } on FirebaseAuthException catch (e) {
                  nextPage = false;
                  if (e.code == 'user-not-found') {
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    print('Wrong password provided for that user.');
                  }
                }
              },
              child: Text(
                "Login",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ));
  }

  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user

    return users
        .doc(auth.currentUser!.uid.toString())
        .set({'age': double.parse(age.text)})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}
