import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'globals.dart' as globals;
import  'dart:async';

class Reference{
  bool assigned, requester, resolved;
  String category, subcategory, description;
  double latitude, longitude;
  Reference(){
    bool assigned = false;
    bool requester = false;
    bool resolved = false;
    String category = '';
    String subcategory = '';
    String description = '';
    double latitude = 0;
    double longitude = 0;
  }
  void setAssigned(bool assigned){
    this.assigned = assigned;
  }
  void setRequester(bool requester){
    this.requester = requester;
  }
  void setResolved(bool resolved){
    this.resolved = resolved;
  }
  void setCategory(String category){
    this.category = category;
  }
  void setSubcategory(String subcategory){
    this.subcategory = subcategory;
  }
  void setDescription(String description){
    this.description = description;
  }
  void setLatitude(double latitude){
    this.latitude = latitude;
  }
  void setLongitude(double longitude){
    this.longitude = longitude;
  }
}

class RequestWidget extends StatefulWidget {
  RequestWidget({Key key}) : super(key: key);

  @override
  _RequestWidget createState() => new _RequestWidget(Colors.deepOrange);
}

class _RequestWidget extends State<RequestWidget> {
  Color color;
  String categoryName;
  String subCategoryName;
  String description;
  List<String> subCatList  = <String>[];
  final databaseReference = FirebaseDatabase.instance.reference();
  int requestNum;

  _RequestWidget(this.color);

//FUNCTION TO READ FROM DATABASE
int getRequestNumber(){
  databaseReference.once().then((DataSnapshot snapshot){
    requestNum = snapshot.value['requestNumber'];
    print(snapshot.value);
  });
  return requestNum;
}

//FUNCTION TO WRITE TO DATABASE  //BROKEN, CANNOT FIX
void createRequest(){
  int num = getRequestNumber();
  print(num);
  String temp = "request" + num.toString();
  Reference newRef = new Reference();
  newRef.setCategory(categoryName);
  newRef.setDescription(description);
  newRef.setLatitude(globals.Lat);
  newRef.setLongitude(globals.Long);
  newRef.setSubcategory(subCategoryName);
  DatabaseReference newReference = databaseReference.child("requests").push();
  newReference.set(newRef);
  databaseReference.update({
    'requestNumber': ++num
  });
}

//SWITCH STATEMENT FOR SUBCATEGORY
  _switchStatement(){
              if(categoryName == "Health") {
                subCatList=["Ride to the emergency room", "Medication delivered", "Injured", "Other"];
              } else if (categoryName== "Automotive"){
                subCatList = ["Need a jump start", "Need a tow", "Need a pump", "Ran out of gas", "Other"];
              } else if (categoryName == "At-Home"){
                subCatList = ["Need driveway shoveled", "Need help bringing groceries in", "My pet is lost", "Other"];
              } else if (categoryName == "Weather"){
                subCatList = ["Need heating supplies for extreme weather", "Other"];
              } 
  }

  Widget _buildDescription(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Description'),
      validator: (value){
        if (value.isEmpty) {
            return 'Please enter a description.';
        }
      },
      onSaved: (String val){
        setState(() {description = val;});
      }
    );
  }

  Widget _buildSubCategory(){
    _switchStatement();
    if(subCatList!=null){
      return DropdownButton<String>(
        value: subCategoryName,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(
          color: Colors.red
        ),
        underline: Container(
          height: 2,
          color: Colors.red,
        ),
        onChanged: (String newValue) {
          setState(() {
            subCategoryName = newValue;
          });

        },
        items: subCatList
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
      );
    }
  }
  Widget _buildCategory(){
    return DropdownButton<String>(
        value: categoryName,
        icon: Icon(Icons.arrow_downward),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(
          color: Colors.red
        ),
        underline: Container(
          height: 2,
          color: Colors.red,
        ),
        onChanged: (String newValue) {
          setState(() {
            categoryName = newValue;
            subCategoryName=null;
          });

        },
        items: <String>['Health','Automotive','At-Home','Weather']
          .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          })
          .toList(),
  );        
  }

  @override
  Widget build (BuildContext context){
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children:<Widget>[
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenSize.height / 6.4),

                  //MAIN CATEGORY SELECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Enter your category",
                        textAlign: TextAlign.center,
                      ),
                     _buildCategory(),
                     ],
                  ),

                  //SUBCATEGORY SELECTION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Enter your subcategory",
                        textAlign: TextAlign.center,
                      ),
                     _buildSubCategory(),
                     ],

                   ),

                   //SUBMIT BUTTON
                   _buildDescription(),
                    RaisedButton(
                      child: Text('Submit'),
                      onPressed:() async{
                        await createRequest();
                        final snackBar = SnackBar(
                          content: Text('Request submitted')
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      },
                    ),
                ],

              ),
            ),
          ),
        ],
      ),
    );
  }
}