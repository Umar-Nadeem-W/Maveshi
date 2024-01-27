import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maveshifinproj/Myfavorites.dart';
import 'package:maveshifinproj/myanimals.dart';
import 'login.dart';
import 'signup.dart';
import 'fire_auth.dart';
import 'buy.dart';
import 'auction.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;
  int myindex = 0;

  late User _currentUser;

  @override
  void initState() {
    _currentUser = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: myindex,
        type: BottomNavigationBarType.fixed, // Set the type to fixed
        onTap: (index) {
          setState(() {
            myindex = index;
          });
        },
        backgroundColor: Colors.black, // Set the background color to black
        selectedItemColor: Colors.purple, // Set the color of the selected item to purple
        unselectedItemColor: Colors.white, // Set the color of unselected items to white
        items: const [
          BottomNavigationBarItem(
            label: "Profile",
            icon: Icon(Icons.person),
          ),
          BottomNavigationBarItem(
            label: "Upload Animal",
            icon: Icon(Icons.sell),
          ),
          BottomNavigationBarItem(
            label: "Auction",
            icon: Icon(Icons.attach_money_sharp),
          ),
          BottomNavigationBarItem(
            label: "Favorites",
            icon: Icon(Icons.favorite),
          ),
          BottomNavigationBarItem(
            label: "My Animals",
            icon: Icon(Icons.adb_sharp),
          ),
        ],
      ),
      body: myindex == 0
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Color(0xffE6E6E6),
              radius: 50,
              child: Icon(
                Icons.person,
                color: Color(0xffCCCCCC),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Name: ${_currentUser.displayName}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 16.0),
            Text(
              'Email: ${_currentUser.email}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 16.0),
            _isSigningOut
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                setState(() {
                  _isSigningOut = true;
                });
                await FirebaseAuth.instance.signOut();
                setState(() {
                  _isSigningOut = false;
                });
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              },
              child: Text('Sign out'),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      )
          : myindex == 1
          ? AnimalUploadPage()
          : myindex == 2
          ? AnimalListPage(currentUserUid: _currentUser.uid)
          : myindex == 3
          ? MyFavoritesPage(currentUserUid: _currentUser.uid)
          : myindex == 4
          ? MyAnimalsPage()
          : null,
    );
  }
}

