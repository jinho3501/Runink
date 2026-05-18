import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SLButton.dart';
import 'Introduce.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String _passwordMessage = '';

  bool _validatePassword(String password) {
    final passwordPattern =
        r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
    return RegExp(passwordPattern).hasMatch(password);
  }

  void _onPasswordChanged(String password) {
    setState(() {
      if (_validatePassword(password)) {
        _passwordMessage = '';
      } else {
        _passwordMessage = '대소문자, 특수기호, 숫자를 포함한 최소 8글자의 비밀번호를 입력하세요';
      }
    });
  }

  Future<void> _signUp() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final String? firebaseUid = userCredential.user?.uid;

      if (firebaseUid != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공')),
        );

        // IntroduceScreen으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IntroduceScreen(
              userEmail: _emailController.text.trim(),

            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  onChanged: _onPasswordChanged,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: '비밀번호',
                    helperText: '대소문자, 특수기호, 숫자를 포함한 최소 8글자의 비밀번호',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _passwordMessage,
                  style: TextStyle(
                    color: _passwordMessage == '' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Color(0xFF1287AE),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                SocialButton(
                  imagePath: 'assets/images/google.png',
                  label: '구글 계정으로 시작하기',
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                SocialButton(
                  imagePath: 'assets/images/kakaotalk.png',
                  label: '카카오 계정으로 시작하기',
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                SocialButton(
                  imagePath: 'assets/images/naver.png',
                  label: '네이버 계정으로 시작하기',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}