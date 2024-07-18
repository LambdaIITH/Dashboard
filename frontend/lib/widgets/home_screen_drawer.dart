import 'package:flutter/material.dart';
import 'package:frontend/widgets/drawer_option.dart';

class HomeScreenDrawer extends StatelessWidget {
  const HomeScreenDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
            SizedBox(
              width: double.infinity,
              height: 160,
              child: CircleAvatar(
                child: ClipOval(
                  child: Image.network(
                    'https://imgs.search.brave.com/t8qv-83e1m_kaajLJoJ0GNID5ch0WvBGmy7Pkyr4kQY/rs:fit:860:0:0/g:ce/aHR0cHM6Ly91cGxv/YWQud2lraW1lZGlh/Lm9yZy93aWtpcGVk/aWEvY29tbW9ucy84/Lzg5L1BvcnRyYWl0/X1BsYWNlaG9sZGVy/LnBuZw',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const DrawerOption(
              title: 'Profile',
              onTap: null,
            ),
            const SizedBox(height: 20),
            const DrawerOption(
              title: 'Feedback',
              onTap: null,
            ),
            const SizedBox(height: 20),
            const DrawerOption(
              title: 'Support',
              onTap: null,
            ),
            const SizedBox(height: 20),
            const DrawerOption(
              title: 'Logout',
              onTap: null,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Image.asset(
                  'assets/icons/logo.png',
                  height: 38,
                ),
                horizontalTitleGap: 10,
                title: const Text(
                  'College Companion    v0.01',
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFFADADAD),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
