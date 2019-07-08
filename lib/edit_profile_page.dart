import 'dart:io';
import 'package:teacher/edit_interests.dart';
import "package:flutter/material.dart";
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' hide context;
import 'package:path_provider/path_provider.dart';
import 'package:teacher/constants.dart';
import "package:image_picker/image_picker.dart";
import 'package:teacher/shared_preferences_helpers.dart';
import 'package:http/http.dart' as http;
// import 'package:teacher/drawer.dart';
import 'dart:convert';


///Builds the EditProfilePage.
class ProfilePage extends StatefulWidget {
  ProfilePageState createState() {
    return ProfilePageState();
  }
}

///Builds the state associated with EditProfilePage.
class ProfilePageState extends State<ProfilePage> {
  ///Number of questions answered by the user.
  String _quesAnswered = "1";

  ///Number of questions asked by the user.
  String _quesAsked = "1";

  ///Stores the image if it is uploaded.
  File _image;

  ///If upload fails it stores previous profile pic.
  File _tempImage;

  ///Status of upload is stored in it.
  bool uploading = false;

  final formkey = GlobalKey<FormState>();

  ///Previous user_name set by the user.
  String fullName = USER_NAME;
  ///Previous age set by the user.
  String age;
  ///Previous phone number set by the user.
  String phone;
  ///Previous interests set by the user
  String interests;

  ///Stores updated user_name.
  String _name;
  ///Stores updated age.
  int _age;
  ///Stores updated phone number.
  String _phone;

  var nameController = TextEditingController();
  var ageController = TextEditingController();
  var phoneController = TextEditingController();

  ///Fetches the earlier info of user
  ///
  ///Sets the value of controllers for
  ///*name
  ///*age
  ///*phone.
  void getInfo() async {
    age = await getFromSP(AGE_KEY_SP);
    print("age id: $age");
    phone = await getFromSP(PHONE_KEY_SP);
    nameController.text = fullName;
    ageController.text = age;
    phoneController.text = phone;
    var token = await getCurrentTokenId();
    print(token);

    var Response = await http.get(
        Uri.encodeFull("http://"+serverIP+":"+serverPort+"/getQuestionsInfo?tokenId=$token"),
        headers:{
          "Accept": "application/json"
        }
    );
    List list = new List();
    final map = jsonDecode(Response.body);
    setState(() {
      list = map;
      print("LIST HERE------------------");
      print(list.toString());
      _quesAsked = list[0];
      _quesAnswered = list[1];

    });
    setState(() {});
  }

  Future initProfilePicFile() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    _image = File(join(appDir.path, "profile_pic.png"));
    print(_image.path);
    if (!_image.existsSync()) {
      _image = null;
    }
    setState(() {});
  }

  ///Initializes info and profile pic.
  @override
  void initState() {
    initProfilePicFile();
    getInfo();
    super.initState();
  }

  ///Fetches image from gallery
  ///
  /// Images selected by user from gallery
  /// is returned.
  Future<File> getImageFromGallery() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    return image;
  }

  ///Captures image using camera
  ///
  /// Image captured by camera at present state is returned.
  Future<File> getImageFromCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    return image;
  }

  ///Previous profile pic is replaced with selected newImage
  ///
  ///Message is displayed showing the status of upload
  ///Due to network issues if error is encountered then previous profile
  ///image gets restored.
  Future changeProfilePic(File newImage) async {
    if (newImage != null) {
      setState(() {
        _tempImage = _image;
        _image = newImage;
        uploading = true;
      });
      int responseCode = await uploadProfilePic(newImage);
      if (responseCode == 200) {
        String path = (await getApplicationDocumentsDirectory()).path;
        print("copying to $path/profile_pic.png");
        File pFile = File('$path/profile_pic.png');
        pFile.writeAsBytesSync(newImage.readAsBytesSync());
        FileImage im = FileImage(pFile);
        im.evict();
        print("copying completed");
        setState(() {
          _image = File("$path/profile_pic.png");
          uploading = false;
        });
        Fluttertoast.showToast(
          msg: 'Profile pic changed',
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Unable to upload image',
          toastLength: Toast.LENGTH_SHORT,
        );
        setState(() {
          _image = _tempImage;
          uploading = false;
        });
      }
    }
  }

  ///Updates uploaded profile page in database
  ///
  /// Respective status code is returned based on
  /// the upload being successfull or not.
  Future<int> uploadProfilePic(File newImage) async {
    var url = "$serverIP:$serverPort/uploadFile";
    var uri = new Uri.http('$serverIP:$serverPort', '/uploadProfilePic');
    var token = await getCurrentTokenId();
    var request = new http.MultipartRequest("POST", uri);
    print("successfuly parse the url $url");

    request.files.add(await http.MultipartFile.fromPath("pic", newImage.path));
    request.fields['tokenId'] = token;
    var response;
    try {
      response = await request.send();
    } catch (e) {
      return 400;
    }
    return response.statusCode;
  }

  BuildContext ctx;
  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: profilePageBody());
  }

  ///Inputs are taken if user wishes to edit the page
  ///
  /// Previous details o user are displayed by default and new information
  /// gets stored in variables for
  /// *name
  /// *age
  /// *phone.
  Widget profilePageBody() {
    Size screenSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          header(),
          SizedBox(
            height: 15.0,
          ),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "FiraSans",
                fontWeight: FontWeight.bold,
                fontSize: 30.0),
          ),
          _buildStatContainer(),
          SizedBox(height: 20.0),
          Padding(
              padding: EdgeInsets.all(8.0),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                            labelText: 'Name:', hintText: "xyz abc"),
                        validator: (input) {
                          if (input.length < 3) {
                            return 'Name must contain atleast three letters';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (input) {
                          _name = input;
                        }),
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                          labelText: 'Phone:', hintText: "123xxxxx12"),
                      keyboardType: TextInputType.phone,
                      validator: (input) {
                        if (input.length < 10) {
                          return 'Phone number is invalid';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (input) => _phone = input,
                    ),
                    TextFormField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration:
                      InputDecoration(labelText: "Age: ", hintText: "__"),
                      onSaved: (input) => _age = int.parse(input),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: interestButton(),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Center(
                      child: saveButton(),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  ///Button to call saveChanges function on tap.
  Widget saveButton() {
    return Container(
      height: 30.0,
      width: 95.0,
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: GestureDetector(
          child: Container(
            child: Center(
              child: Text("Save changes"),
            ),
          ),
          onTap: saveChanges,
        ),
      ),
    );
  }

  ///Button to edit interests of user on tap.
  Widget interestButton() {
    return Container(
      height: 30.0,
      width: 95.0,
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: GestureDetector(
          child: Container(
            child: Center(
              child: Text("Edit your interests"),
            ),
          ),
          onTap:() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => editInterests()),
            );
          },
        ),
      ),
    );
  }

  ///Creates a stack that displays profile image above the background image.
  Widget header() {
    return Stack(
      children: <Widget>[
        bottomMostWidget(),
        circularImage(),
      ],
    );
  }

  ///Sets previous profile in circular manner
  ///
  /// Icon is placed above profile pic to allow editing.
  /// If editing is done then selected image is set as profile pic.
  Widget circularImage() {
    return Positioned(
      left: (MediaQuery.of(context).size.width - 150) / 2,
      top: MediaQuery.of(context).size.height / 6,
      child: Stack(
        children: <Widget>[
          Hero(
            tag: "profile-pic",
            child: Container(
              //key: UniqueKey(),
              width: 150.0,
              height: 150.0,
              decoration: new BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 7.0)],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.0),
                // borderRadius: BorderRadius.all(Radius.circular(50.0)),
                image: new DecorationImage(
                  colorFilter: !uploading
                      ? null
                      : ColorFilter.mode(
                      Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  fit: BoxFit.fill,
                  image: _image != null
                      ? FileImage(_image)
                      : new AssetImage("assets/images/profile_pic.png"),
                ),
              ),
              child: !uploading
                  ? null
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned(
            top: 100,
            left: 100,
            child: InkWell(
              child: Container(
                padding: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          child: AlertDialog(
                            title: Text("Pick new image"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                FlatButton.icon(
                                  color: Colors.white.withOpacity(0.1),
                                  icon: Icon(Icons.add_a_photo),
                                  label: Text("Choose from gallery"),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    File newImage = await getImageFromGallery();
                                    changeProfilePic(newImage);
                                  },
                                ),
                                FlatButton.icon(
                                  icon: Icon(Icons.wallpaper),
                                  label: Text("Choose from camera"),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    File newImage = await getImageFromCamera();
                                    changeProfilePic(newImage);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
          )
        ],
      ),
    );
  }

  ///Image is set behind the profile picture.
  Widget bottomMostWidget() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        ClipPath(
          child: Container(
            height: 3 * MediaQuery.of(context).size.height / 7,
            width: MediaQuery.of(context).size.width,
            color: Colors.black.withOpacity(0.8),
          ),
          clipper: GetClipper(),
        ),
      ],
    );
  }


  ///Statistics are set here
  ///
  /// It includes
  /// **Number of questions answered by the user
  /// **Number of questions asked by the user.
  Widget _buildStatItem(String label, String count) {
    TextStyle _statLabelTextStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w200,
      fontSize: 16.0,
    );
    TextStyle _statCountStyle = TextStyle(
      color: Colors.black54,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                count,
                style: _statCountStyle,
              ),
              Text(
                label,
                style: _statLabelTextStyle,
              )
            ],
          )
        ],
      ),
    );
  }


  ///Both statistics are placed adjacent to each other in this widget
  ///
  /// That is questions asked and answered.
  Widget _buildStatContainer() {
    return Container(
      height: 60.0,
      margin: EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFFEFF4F7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildStatItem("Questions Asked", _quesAsked),
          _buildStatItem("Questions Answered", _quesAnswered),
        ],
      ),
    );
  }

  ///Black single line separator is generated.
  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  ///Changed information is updated in:
  ///
  ///*Shared Preferences
  ///*Database.
  void saveChanges() async {
    if(formkey.currentState.validate()){

      formkey.currentState.save();
      var token = await getCurrentTokenId();
      print(token.toString());
      var response;
      var uri = new Uri.http("${serverIP}:${serverPort}", "/users/updateinfo");
      var request = new http.MultipartRequest("PUT", uri);
      print(_name);
      print(_phone);
      print(_age);
      request.fields["name"] = _name;
      request.fields["phone"] = _phone;
      request.fields['age'] = _age.toString();
      request.fields["tokenId"] = token;
      print(request.headers);
      try {
        response = await request.send();
        print(response.toString() + "-------------------------");
        if (response.statusCode == 200) {
          saveInSP(USER_NAME_SP, _name);
          saveInSP(AGE_KEY_SP, _age.toString());
          saveInSP(PHONE_KEY_SP, _phone);
          USER_NAME = _name;
          fullName = _name;
          setState((){});
          Fluttertoast.showToast(
              msg: 'Changes saved successfully!!!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white);
        } else {
          var error = await response.stream.bytesToString();
          print(error);
          Fluttertoast.showToast(
              msg: 'Profile not updated!!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 2,
              backgroundColor: Colors.black,
              textColor: Colors.white);
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: 'Profile not updated!!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 2,
            backgroundColor: Colors.black,
            textColor: Colors.white);
      }
    }
  }
}


class GetClipper extends CustomClipper<Path> {
  ///Clipper is created that partitions the background behind profile page.
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width + 150, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}