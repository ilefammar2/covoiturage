import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _screens = [
    Container(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/v1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _screens[_selectedIndex],
             Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color.fromARGB(255, 12, 17, 51), // Couleur de fond
              padding: const EdgeInsets.all(16), // Padding autour du texte
              child: const Text(
                'WASALNI',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
           bottom: 25, 
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Devenez chauffeur!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8), 
                const Text(
                  'Partagez votre voiture et maximisez vos gains',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18, 
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10), // Espace avant le bouton
                Container(
                  width: double.infinity, // Rendre le bouton aussi large que possible
                  padding: const EdgeInsets.symmetric(horizontal: 50), // Espace autour du bouton
                  child: ElevatedButton(
                    onPressed: () {
                      // Remplacez print par votre méthode de logging
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 90, 164, 165),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Publier Trajet'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    bottomNavigationBar: SizedBox(
        height: 60, 
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
            buildNavBarItem(CupertinoIcons.home, 0),
            buildNavBarItem(CupertinoIcons.news_solid, 1),
            
            const SizedBox(width: 10),
 
            buildNavBarItem(CupertinoIcons.conversation_bubble, 2),
            buildNavBarItem(CupertinoIcons.profile_circled, 3),
          ],
        ),
      ),
    ),
      floatingActionButton: const ClipOval(
        child: Material(
          color:  Color.fromARGB(255, 13, 17, 50),
          elevation: 10,
          child: InkWell(
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                CupertinoIcons.add_circled,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget buildNavBarItem(IconData icon, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index
                ? const Color.fromARGB(255, 90, 164, 165)
                :  const Color.fromARGB(255, 13, 17, 50),
          ),
        ],
      ),
    );
  }
}
