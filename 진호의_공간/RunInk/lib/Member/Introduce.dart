import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:RunInk/Member/Information.dart';

class IntroduceScreen extends StatefulWidget {
  final String userEmail;


  const IntroduceScreen({
    Key? key,
    required this.userEmail,
  }) : super(key: key);

  @override
  _IntroduceScreenState createState() => _IntroduceScreenState();
}

class _IntroduceScreenState extends State<IntroduceScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  String _gender = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text = '${picked.year}-${picked.month}-${picked.day}';
      });
    }
  }

  Future<void> _submitUserData() async {
    try {
      final response = await http.post(
        Uri.parse('http://43.203.107.133:8000/signin'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'email': widget.userEmail,
          'name': _nameController.text,
          'birth_date': _birthDateController.text,
          'gender': _gender,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사용자 정보 저장 성공')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Information()),
        );
      } else {
        throw Exception('Failed to save user data');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보 저장 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '당신을 소개해주세요',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이름',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '김러너',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '생일',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            TextField(
              controller: _birthDateController,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: '생일을 선택하세요',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            const Text(
              '성별',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('남'),
                    value: '남',
                    groupValue: _gender,
                    onChanged: (String? value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('여'),
                    value: '여',
                    groupValue: _gender,
                    onChanged: (String? value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _submitUserData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Color(0xFF1287AE),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}