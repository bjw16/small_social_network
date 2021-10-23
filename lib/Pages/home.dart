import 'package:flutter/material.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Assets/CustomDrawer.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.uid})
      : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String uid;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FirebaseAuth auth = FirebaseAuth.instance;

  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  TextEditingController newPost = new TextEditingController();
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          backgroundColor: Color(0xAA01E12D),
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 9,
                      offset: Offset(0, 0), // changes position of shadow
                    ),
                  ]),
              width: MediaQuery.of(context).size.width / 2,
              child: Column(children: [
                Flexible(
                  child: TextFormField(
                    controller: newPost,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: "Write a post!"),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      posts.add({
                        'date': DateTime.now(),
                        'post': newPost.text,
                        'username': auth.currentUser!.displayName.toString(),
                      });
                      setState(() {
                        posts = FirebaseFirestore.instance.collection('posts');
                        newPost = new TextEditingController();
                      });
                    },
                    child: Text("Send Posts")),
                //List of Post
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                          stream: posts.limit(20).snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            // count of events
                            int eventCount = 5;
                            if (snapshot.hasData)
                              eventCount = snapshot.data!.size;
                            else if (snapshot.hasError)
                              return new Text('Error: ${snapshot.error}');
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Center(
                                    child: CircularProgressIndicator());
                              default:
                                return new ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: eventCount,
                                    itemBuilder: (context, index) {
                                      final DocumentSnapshot document =
                                          snapshot.data!.docs[index];
                                      Timestamp printTimestamp =
                                          document.get('date');
                                      DateTime printDate =
                                          printTimestamp.toDate().toUtc();
                                      return new Card(
                                        child: Column(
                                          children: [
                                            Text(document.get('username')),
                                            Text(document.get('post')),
                                            Text(new DateFormat('MM-dd-yyyy - ')
                                                .add_jm()
                                                .format(printDate)),
                                          ],
                                        ),
                                      );
                                    });
                            }
                          }),
                    ]),
              ]),
            ),
          ),
        ));
  }
}
