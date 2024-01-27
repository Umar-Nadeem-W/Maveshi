import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAnimalsPage extends StatefulWidget {
  @override
  _MyAnimalsPageState createState() => _MyAnimalsPageState();
}

class _MyAnimalsPageState extends State<MyAnimalsPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _animalsStream;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser!.uid;
    _animalsStream = FirebaseFirestore.instance
        .collection('Animals')
        .where('ownerId', isEqualTo: _userId)
        .snapshots();
  }

  Future<void> _toggleAuctionStatus(bool onAuction, String animalId) async {
    final batch = FirebaseFirestore.instance.batch();

    // Update the animal's "Onauction" field
    final animalRef = FirebaseFirestore.instance.collection('Animals').doc(animalId);
    batch.update(animalRef, {'Onauction': !onAuction});

    // Update the "Shortlist" fields in all user documents
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    for (final userDoc in usersSnapshot.docs) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);
      batch.update(userRef, {
        'Shortlist': onAuction
            ? FieldValue.arrayRemove([animalId])
            : FieldValue.arrayUnion([animalId])
      });
    }

    await batch.commit();
  }

  Future<void> _deleteAnimal(String animalId) async {
    final batch = FirebaseFirestore.instance.batch();

    // Delete the animal document
    final animalRef = FirebaseFirestore.instance.collection('Animals').doc(animalId);
    batch.delete(animalRef);

    // Remove the animalId from all user documents' "Shortlist" field
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    for (final userDoc in usersSnapshot.docs) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);
      batch.update(userRef, {'Shortlist': FieldValue.arrayRemove([animalId])});
    }

    await batch.commit();
  }

  Widget _buildAnimalCard(DocumentSnapshot<Map<String, dynamic>> animalSnapshot) {
    final animalData = animalSnapshot.data()!;
    final onAuction = animalData['Onauction'] ?? false;
    final animalId = animalData['animalId'] as String;

    return Card(
      child: ListTile(
        title: Text(animalData['name']),
        subtitle: Text('Breed: ${animalData['breed']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _toggleAuctionStatus(onAuction, animalId),
              child: Text(onAuction ? 'Remove from Auction' : 'Put on Auction'),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: () => _deleteAnimal(animalId),
              child: Text('Delete Animal'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(child: Text('My Animals',style: TextStyle(color: Colors.purple),)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _animalsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final animals = snapshot.data!.docs;

          if (animals.isEmpty) {
            return Center(
              child: Text('You have no animals.'),
            );
          }

          return ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) => _buildAnimalCard(animals[index]),
          );
        },
      ),
    );
  }
}
