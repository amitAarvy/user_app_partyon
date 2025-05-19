import 'package:flutter/material.dart';
import 'package:user/screens/home/view/home_view.dart';
import 'package:user/screens/venue_view.dart';
import 'my_booking/booking_list.dart';


class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomNavigationBarExample();
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    const HomeView(),
    const VenueView(),
    // const EliteView(),
    // const HousePartyView(),
    const BookingList(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location_alt),
            label: 'Venues',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.school),
          //   label: 'Elite',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home_work_outlined),
          //   label: 'House Party',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.offline_pin_rounded),
            label: 'Booking',
          ),
        ],
        backgroundColor:  Colors.black,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[900],
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        unselectedLabelStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
        onTap: _onItemTapped,
      ),
    );
  }
}
