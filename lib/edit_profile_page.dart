import 'dart:io';

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

class ProfilePage extends StatefulWidget {
  ProfilePageState createState() {
    return ProfilePageState();
  }
}

class ProfilePageState extends State<ProfilePage> {
  // String _fullName = "fullname";
  String _status = "hey";
  String _bio = "programmer";
  String _quesAnswered = "1";
  String _quesAsked = "1";
  File _image;
  File _tempImage;
  bool uploading = false;
  final formkey = GlobalKey<FormState>();

  String fullName = USER_NAME;
  String age;
  String phone;

  String _name;
  int _age;
  String _phone;

  var nameController = TextEditingController();
  var ageController = TextEditingController();
  var phoneController = TextEditingController();
  void getInfo() async {
    // _fullName = await getFromSP(USER_NAME_SP);
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

  @override
  void initState() {
    initProfilePicFile();
    getInfo();
    super.initState();
  }

  Future<File> getImageFromGallery() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // _tempImage = _image;
    // _image = image;
    return image;
  }

  Future<File> getImageFromCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    // _tempImage = _image;
    // _image = image;
    return image;
  }

  Future changeProfilePic(File newImage) async {
    if (newImage != null) {
      setState(() {
        _tempImage = _image;
        _image = newImage;
        uploading = true;
      });
      int responseCode = await uploadProfilePic(newImage);
      if (responseCode == 200) {
        // PermissionStatus per = await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
        // print(per);
        String path = (await getApplicationDocumentsDirectory()).path;
        print("copying to $path/profile_pic.png");
        File pFile = File('$path/profile_pic.png');
        // pFile.deleteSync();
        // pFile.writeAsBytesSync((await http.get(Uri.http("$serverIP:$serverPort", "/getProfilePic/5cfe0b06e0efcb356ff5d63f.octet-stream"))).bodyBytes);
        // File copyFile = newImage.copySync('$path/profile_pic.png');//.then((val){print("copy: $val");}).catchError((e){print(e);});
        pFile.writeAsBytesSync(newImage.readAsBytesSync());
        FileImage im = FileImage(pFile);
        im.evict();
        print("copying completed");
        // showDialog(context:ctx, builder: (BuildContext context){
        //   return AlertDialog(content: Image.file(File('$path/profile_pic.png')),);
        // });
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
        // drawer: NavDrawer(email: EMAIL, userName: USER_NAME),
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: profilePageBody());
  }

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
            style: TextStyle(
                fontFamily: "FiraSans",
                fontWeight: FontWeight.bold,
                fontSize: 30.0),
          ),
          // _buildStatus(context),
          _buildStatContainer(),
          // _buildBio(context),
          // _buildSeparator(screenSize),
          // SizedBox(height: 300.0),
          // _buildGetInTouch(context),
          // SizedBox(height: 80.0),
          // _buildButtons(),
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
                      child: saveButton(),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Widget _buildTextField(String label, String hintText) {
  //   return Row(
  //     children: <Widget>[
  //       Text(label + ": "),
  //       TextField(
  //         controller: textControllers[label],
  //         decoration: new InputDecoration(
  //           border: new OutlineInputBorder(
  //             borderRadius: const BorderRadius.all(
  //               const Radius.circular(15.0),
  //             ),
  //           ),
  //           filled: true,
  //           hintStyle: new TextStyle(color: Colors.grey[800]),
  //           hintText: hintText,
  //           labelText: label,
  //           fillColor: Colors.white70,
  //         ),
  //       ),
  //     ],
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //   );
  // }

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

  Widget header() {
    return Stack(
      children: <Widget>[
        bottomMostWidget(),
        circularImage(),
      ],
    );
  }

  Widget circularImage() {
    return Positioned(
      // width: 150.0,
      left: (MediaQuery.of(context).size.width - 150) / 2,
      // right: 25.0,
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
                                  // shape: CircleBorder(side: BorderSide()),
                                  icon: Icon(Icons.add_a_photo),
                                  label: Text("Choose from gallery"),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    File newImage = await getImageFromGallery();
                                    changeProfilePic(newImage);
                                  },
                                ),
                                FlatButton.icon(
                                  // shape: CircleBorder(side: BorderSide()),
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

  // Widget _buildStatus(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).scaffoldBackgroundColor,
  //       borderRadius: BorderRadius.circular(4.0),
  //     ),
  //     child: Text(
  //       _status,
  //       style: TextStyle(
  //         color: Colors.black,
  //         fontSize: 20.0,
  //         fontWeight: FontWeight.w300,
  //       ),
  //     ),
  //   );
  // }

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

  // Widget _buildBio(BuildContext context) {
  //   TextStyle _bioTextStyle = TextStyle(
  //     fontWeight: FontWeight.w500,
  //     fontSize: 16.0,
  //     fontStyle: FontStyle.italic,
  //     color: Color(0xFF799497),
  //   );
  //   return Container(
  //     color: Theme.of(context).scaffoldBackgroundColor,
  //     padding: EdgeInsets.all(8.0),
  //     child: Text(
  //       _bio,
  //       textAlign: TextAlign.center,
  //       style: _bioTextStyle,
  //     ),
  //   );
  // }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  // Widget _buildGetInTouch(BuildContext context) {
  //   return Container(
  //     color: Theme.of(context).scaffoldBackgroundColor,
  //     padding: EdgeInsets.only(top: 8.0),
  //     child: Text(
  //       "Get in touch with ${fullName.split(" ")[0]}",
  //       style: TextStyle(fontSize: 16.0),
  //     ),
  //   );
  // }

  // Widget _buildButtons() {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //     child: Row(
  //       children: <Widget>[
  //         Expanded(
  //           child: InkWell(
  //             onTap: () => print("Asked"),
  //             child: Container(
  //               height: 40.0,
  //               decoration: BoxDecoration(
  //                 border: Border.all(),
  //                 color: Color(0xFF404A5C),
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   "ASK",
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 10.0),
  //         Expanded(
  //           child: InkWell(
  //             onTap: () => print("Message"),
  //             child: Container(
  //               height: 40.0,
  //               decoration: BoxDecoration(
  //                 border: Border.all(),
  //               ),
  //               child: Center(
  //                 child: Padding(
  //                   padding: EdgeInsets.all(10.0),
  //                   child: Text(
  //                     "Message",
  //                     style: TextStyle(fontWeight: FontWeight.w600),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }

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
