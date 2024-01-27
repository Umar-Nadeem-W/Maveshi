import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auction.dart';

class MyFavoritesPage extends StatelessWidget {
  final String currentUserUid;

  const MyFavoritesPage({required this.currentUserUid});
  Future<void> buyAnimal(String animalId, int price, String ownerId, BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId != null) {
      final transactionData = {
        'Animal sold': animalId,
        'Buyerid': currentUserId,
        'Commission': (price * 0.05).toInt(),
        'Date': DateTime.now(),
        'Taxed Amount': (price * 0.01).toInt(),
        'Gross Amount': price + (price * 0.01).toInt(),
        'Sellerid': ownerId,
      };

      final transactionRef = FirebaseFirestore.instance.collection('Transactions').doc();
      await transactionRef.set(transactionData);

      final sellerDocRef = FirebaseFirestore.instance.collection('users').doc(ownerId);
      final sellerDoc = await sellerDocRef.get();

      if (sellerDoc.exists) {
        final int animalsOwned = sellerDoc.data()?['Animals Owned'] ?? 0;
        await sellerDocRef.update({'Animals Owned': animalsOwned - 1});
      }

      final animalDocRef = FirebaseFirestore.instance.collection('Animals').doc(animalId);
      await animalDocRef.delete();

      // Remove animalId from all "Shortlist" fields in "users" collection
      final usersCollectionRef = FirebaseFirestore.instance.collection('users');
      final usersSnapshot = await usersCollectionRef.get();

      for (final userDoc in usersSnapshot.docs) {
        final userDocRef = userDoc.reference;
        final userShortlist = userDoc.data()?['Shortlist'] ?? [];
        if (userShortlist.contains(animalId)) {
          userShortlist.remove(animalId);
          await userDocRef.update({'Shortlist': userShortlist});
        }
      }

      // Remove animalId from "Myanimals" array of the animal owner
      final ownerDocRef = FirebaseFirestore.instance.collection('users').doc(ownerId);
      final ownerDoc = await ownerDocRef.get();

      if (ownerDoc.exists) {
        final ownerMyAnimals = ownerDoc.data()?['Myanimals'] ?? [];
        if (ownerMyAnimals.contains(animalId)) {
          ownerMyAnimals.remove(animalId);
          await ownerDocRef.update({'Myanimals': ownerMyAnimals});
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Animal purchased successfully')),
      );
    }
  }

  Future<List<DocumentSnapshot>> _getFavoriteAnimals() async {
    final userDocSnapshot =
    await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();

    final List<dynamic> shortlist = userDocSnapshot.data()?['Shortlist'] ?? [];
    final List<DocumentSnapshot> favoriteAnimals = [];

    for (final animalId in shortlist) {
      final animalDocSnapshot =
      await FirebaseFirestore.instance.collection('Animals').doc(animalId).get();
      if (animalDocSnapshot.exists) {
        favoriteAnimals.add(animalDocSnapshot);
      }
    }

    return favoriteAnimals;
  }

  Future<void> _removeFromFavorites(String animalId, BuildContext context) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUserUid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final List<dynamic> shortlist = userDoc.data()?['Shortlist'] ?? [];

        if (shortlist.contains(animalId)) {
          shortlist.remove(animalId);
          await userDocRef.update({'Shortlist': shortlist});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Removed from Favorites')),
          );
        }
      }
    } catch (e) {
      print('Failed to remove animal from favorites: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(child: Text('My Favorites',style: TextStyle(color: Colors.purple),)),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getFavoriteAnimals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final favoriteAnimals = snapshot.data!;

            if (favoriteAnimals.isEmpty) {
              return Center(
                child: Text('No favorite animals found.'),
              );
            }

            return ListView.builder(
              itemCount: favoriteAnimals.length,
              itemBuilder: (context, index) {
                final animal = favoriteAnimals[index];
                final animalId = animal.id;
                final name = animal['name'] ?? '';
                final age = animal['age'] ?? '';
                final breed = animal['breed'] ?? '';
                final price = animal['price'] ?? '';
                final gender = animal['gender'] ?? '';
                final location = animal['location'] ?? '';
                final pictureLink = animal['picture link'] ?? '';

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: Row(
                      children: [
                        Container(
                          height: 150,
                          width: 150,
                          child: Image.network(pictureLink, fit: BoxFit.contain),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              SizedBox(height: 5,),
                              Text('Age: $age'),
                              Text('Breed: $breed'),
                              Text('Price: $price'),
                              Text('Gender: $gender'),
                              Text('Location: $location'),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _removeFromFavorites(animalId, context);
                                      },
                                      child: Text('Remove from Favorites'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left:5.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('Buy Animal'),
                                                content: Text('Are you sure you want to buy this animal for $price rupees?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      buyAnimal(animalId, price, animal['ownerId'], context);
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text('Yes'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Text('Buy'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return SizedBox.shrink();
        },
      ),
    );
  }
}
