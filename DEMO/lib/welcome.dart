
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome!', style: Theme.of(context).textTheme.headline1),
//            FloatingActionButton(
//              heroTag: "btnGet",
//              onPressed: _get,
//              tooltip: 'Get',
//              child: Icon(Icons.add),
//            ),
//            FloatingActionButton(
//              heroTag: "btnPost",
//              onPressed: _post_map,
//              tooltip: 'Post Map',
//              child: Icon(Icons.add),
//            ),
//            FloatingActionButton(
//              heroTag: "btnPost",
//              onPressed: _post_data,
//              tooltip: 'Post Data',
//              child: Icon(Icons.add),
//            ),
          ],
        ),
      ),
    );
  }
}
