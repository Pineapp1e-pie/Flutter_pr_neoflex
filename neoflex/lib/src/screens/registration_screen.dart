import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  void _register() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final email = formData['email'];
      final password = formData['password'];

      // TODO: логика регистрации (вставка в базу данных)

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Регистрация прошла успешно')),
      );

      Navigator.pop(context); // Возврат к экрану входа
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/images/robot.png',
                height: 280,
              ),
              const SizedBox(height: 40),

              // Email
              FormBuilderTextField(
                name: 'email',
                decoration: _inputDecoration('Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Введите email'),
                  FormBuilderValidators.email(errorText: 'Некорректный email'),
                ]),
              ),
              const SizedBox(height: 16),

              // Пароль
              FormBuilderTextField(
                name: 'password',
                obscureText: true,
                decoration: _inputDecoration('Пароль'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(errorText: 'Введите пароль'),
                  FormBuilderValidators.minLength(6,
                      errorText: 'Минимум 6 символов'),
                ]),
              ),
              const SizedBox(height: 32),

              // Кнопка регистрации
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD91E5B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Зарегистрироваться',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD91E5B),
                ),
                child: const Text('Уже есть аккаут? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFE0E0E0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

}
