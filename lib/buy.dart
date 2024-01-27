import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:math';

class AnimalUploadPage extends StatefulWidget {
  @override
  _AnimalUploadPageState createState() => _AnimalUploadPageState();
}

class _AnimalUploadPageState extends State<AnimalUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _priceController = TextEditingController();
  final _genderController = TextEditingController();
  final _locationController = TextEditingController();
  final _pictureController = TextEditingController();
  final _speciesController = TextEditingController();
  final _weightController = TextEditingController();



  void _uploadAnimal() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Put Animal on Auction?'),
          content: Text('Do you want to put this animal on auction?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _uploadAnimalToAuction(true);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _uploadAnimalToAuction(false);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _uploadAnimalToAuction(bool onAuction) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final animalId = generateAnimalId();
    final animalData = {
      'animalId': animalId,
      'name': _nameController.text,
      'age': int.parse(_ageController.text),
      'breed': _breedController.text,
      'price': int.parse(_priceController.text),
      'gender': _genderController.text,
      'location': _locationController.text,
      'picture link': _pictureController.text,
      'species': _speciesController.text,
      'weight': int.parse(_weightController.text),
      'ownerId': userId,
      'Onauction': onAuction,
    };

    FirebaseFirestore.instance.collection('Animals').doc(animalId).set(animalData).then((_) {
      // Update the owner's document in the "Users" collection
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'Animals Owned': FieldValue.increment(1),
        'Myanimals': FieldValue.arrayUnion([animalId]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Animal uploaded successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload animal: $error')),
      );
    });
  }

  String generateAnimalId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(10, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.black,

        title: Center(child: Text('Upload Animal', style: TextStyle(color: Colors.purple),)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _speciesController,
                decoration: InputDecoration(labelText: 'Species'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the age';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(labelText: 'Breed'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                // Add validation if needed
              ),
              TextFormField(
                controller: _genderController,
                decoration: InputDecoration(labelText: 'Gender'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText
                    : 'Location'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _pictureController,
                decoration: InputDecoration(labelText: 'Picture link'),
                // Add validation if needed
              ),

              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(labelText: 'Weight'),
                keyboardType: TextInputType.number,
                // Add validation if needed
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _uploadAnimal,
                child: Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


