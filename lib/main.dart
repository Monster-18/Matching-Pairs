import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  runApp(Phoenix( //Used for restarting the application
    child: MaterialApp(
      title: "Match Pairs",
      home: Home(),
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //List of Cards
  List cards = [
    {"clicked": false, "number": 1, "paired": false},
    {"clicked": false, "number": 2, "paired": false},
    {"clicked": false, "number": 3, "paired": false},
    {"clicked": false, "number": 4, "paired": false},
    {"clicked": false, "number": 4, "paired": false},
    {"clicked": false, "number": 3, "paired": false},
    {"clicked": false, "number": 2, "paired": false},
    {"clicked": false, "number": 1, "paired": false},
    {"clicked": false, "number": 5, "paired": false},
    {"clicked": false, "number": 6, "paired": false},
    {"clicked": false, "number": 7, "paired": false},
    {"clicked": false, "number": 8, "paired": false},
    {"clicked": false, "number": 5, "paired": false},
    {"clicked": false, "number": 6, "paired": false},
    {"clicked": false, "number": 7, "paired": false},
    {"clicked": false, "number": 8, "paired": false},
  ];

  //Index Loaction
  int location = null;
  int pairs = 0; //No. of Pairs
  int score = 0;
  int time = 50;
  bool start = true;
  bool alert = false;
  bool congrats = false;

  //Countdown Timer
  void startTimer(){
    Timer.periodic(Duration(seconds: 1), (timer) {
      if(this.mounted){
        setState(() {
        if(time == 0){
          timer.cancel();
          alert = true;
        }else{
          time--;
        }
      });
      }
    });
  }

  //Tapping a Card
  Function tappingCard(int index) {
    if (start) {
      startTimer();
      start = false;
    }
    return () {
      if (this.mounted) {
        setState(() {
          cards[index]['clicked'] =
          !cards[index]['clicked']; //For flipping the card
          if (location != index) { // Avoids pairing the same Card
            if (location == null) {
              location = index; //Tracking the card which is active
            } else {
              if (cards[index]['number'] == cards[location]['number']) { //Checking Pairs
                print('Same');
                score += 20;
                pairs++;
                if (pairs == 8) {
                  print('All Paired');
                  alert = true;
                  congrats = true;
                }
                cards[index]['paired'] = true;
                cards[location]['paired'] = true;
                location = null;
              } else {
                Future.delayed(
                    const Duration(milliseconds: 200), () {//Delays for 200ms
                      if(!this.mounted){
                        return;
                      }
                  setState(() { //Reverts the card if cards are not matched
                    cards[index]['clicked'] = false;
                    cards[location]['clicked'] = false;
                    location = null;
                  });
                });
              }
            }
          } else {
            location = null; //if a card is tapped twice
          }
        });
      }
    };
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Match Pairs"),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),

      body: alert? //Display an alert checking
           congrats? //Display congrats checking
            AlertDialog( //Congrats Alert
              backgroundColor: Colors.grey,
              title: Text("Congrats!!!"),
              content: Text("Would you like to play it again?"),
              actions: [
                FlatButton(
                  color: Colors.white,
                  onPressed: (){
                    dispose();
                    Phoenix.rebirth(context);
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
                FlatButton(
                  color: Colors.white,
                  onPressed: () {
                    dispose();
                    SystemNavigator.pop();
                  },
                  child: Text(
                    'Exit',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ),
              ],
            )
           :
               AlertDialog( //Lost Alert
                 backgroundColor: Colors.grey,
                 title: Text('Oops... You Lost'),
                 content: Text("Would you like to play it again?"),
                 actions: [
                   FlatButton(
                     color: Colors.white,
                     onPressed: (){
                       Phoenix.rebirth(context);
                     },
                     child: Text(
                       'Yes',
                       style: TextStyle(color: Colors.blueGrey),
                     ),
                   ),
                   FlatButton(
                     color: Colors.white,
                     onPressed: ()=> SystemNavigator.pop(),
                     child: Text(
                       'Exit',
                       style: TextStyle(color: Colors.blueGrey),
                     ),
                   ),
                 ],
               )
          :
      Column(
        children: [
          Container(
            color: Colors.white,
            height: 100,
            child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'TIME: $time', //Shows time
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    ),
                    Text(
                      'SCORE: ${score}', //Shows score
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                      ),
                    ),
                  ],
                )
            ),
          ),
          Container(
            height: 500,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal:10.0, vertical: 40.0),

              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,  //No. of cards in a row
                ),
                itemCount: cards.length,

                itemBuilder: (BuildContext context, int index){
                  return Padding(
                    padding: EdgeInsets.all(5.0),
                    child: GestureDetector(

                      onTap: cards[index]['paired']? (){}: tappingCard(index),

                      child: Card(
                        color: cards[index]['clicked']? Colors.yellow: Colors.red,
                        child: Center(
                          child: cards[index]['clicked']?
                                    Text(
                                      "${cards[index]['number']}",
                                      style: TextStyle(
                                        fontSize: 25,
                                      ),
                                    ):
                                    Container(),
                        ),
                      ),
                    ),
                  );
                },
              )
            ),
          ),
        ],
      ),
    );
  }
}
