import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Intro4dev extends StatelessWidget {
  const Intro4dev({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 16),
              _buildBioCard(),
              const SizedBox(height: 16),
              _buildSkillsCard(),
              const SizedBox(height: 16),
              _buildContactCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: AssetImage('assets/dev_profile.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '강윤원',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'FullStack Developer',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '자기소개',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              '안녕하세요. 해실이 아빠입니다~^^',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    final skills = [
      Skill('Flutter', Icons.flutter_dash, Colors.blue),
      Skill('Dart', FontAwesomeIcons.bullseye, Colors.blue[700]!),
      Skill('Firebase', FontAwesomeIcons.fire, Colors.amber),
      Skill('Git', FontAwesomeIcons.git, Colors.red),
      Skill('UI/UX', Icons.design_services, Colors.purple),
      Skill('SQL', Icons.storage, Colors.green),
      Skill('NodeJS', FontAwesomeIcons.nodeJs, Colors.green[700]!),
      Skill('Java', FontAwesomeIcons.java, Colors.red[700]!),
      Skill('Python', FontAwesomeIcons.python, Colors.blue[900]!),
    ];

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기술 스택',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => _buildSkillChip(skill)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillChip(Skill skill) {
    return Chip(
      avatar: Icon(skill.icon, color: Colors.white, size: 18),
      label: Text(skill.name),
      backgroundColor: skill.color,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class Skill {
  final String name;
  final IconData icon;
  final Color color;

  Skill(this.name, this.icon, this.color);
}

Widget _buildContactCard() {
  final contacts = {
    'Email': 'dbsdnjs002@gmail.com',
    'GitHub': 'github.com/CoderGangW',
    'Velog': 'velog.io/@dbsdnjs002',
  };

  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '연락처',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ...contacts.entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(_getIconForContact(entry.key),
                            color: Color.fromARGB(255, 106, 0, 255)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${entry.key}: ${entry.value}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    ),
  );
}

IconData _getIconForContact(String contactType) {
  switch (contactType) {
    case 'Email':
      return FontAwesomeIcons.envelope;
    case 'GitHub':
      return FontAwesomeIcons.github;
    case 'Velog':
      return FontAwesomeIcons.v; // Velog의 V와 가장 유사한 아이콘
    case 'LinkedIn':
      return FontAwesomeIcons.linkedin;
    case 'Twitter':
      return FontAwesomeIcons.twitter;
    case 'Instagram':
      return FontAwesomeIcons.instagram;
    case 'Facebook':
      return FontAwesomeIcons.facebook;
    case 'Website':
      return FontAwesomeIcons.globe;
    default:
      return FontAwesomeIcons.link;
  }
}
