import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/register_form_provider.dart';
import '../services/auth_service.dart';
import '../services/notifications_service.dart';
import '../ui/input_decorations.dart';
import '../widgets/widgets.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 250),
              CardContainer(
                child: ChangeNotifierProvider(
                  create: (_) => RegisterFormProvider(),
                  child: const _RegisterForm(),
                ),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, 'login'),
                style: ButtonStyle(
                  overlayColor: WidgetStatePropertyAll(Colors.indigo.withOpacity(0.2)),
                  shape: const WidgetStatePropertyAll(StadiumBorder()),
                ),
                child: const Text(
                  '¿Ya tienes cuenta? Vuelve a Login',
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final registerForm = Provider.of<RegisterFormProvider>(context);

    return Form(
      key: registerForm.formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text('Registro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          TextFormField(
            autocorrect: false,
            decoration: InputDecorations.authInputDecoration(
              hintText: 'Nombre de usuario',
              labelText: 'Usuario',
              prefixIcon: Icons.person,
            ),
            onChanged: (value) => registerForm.username = value,
            validator: (value) => (value != null && value.isNotEmpty) ? null : 'Introduce un nombre',
          ),
          const SizedBox(height: 20),
          TextFormField(
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecorations.authInputDecoration(
              hintText: 'correo@ejemplo.com',
              labelText: 'Email',
              prefixIcon: Icons.alternate_email,
            ),
            onChanged: (value) => registerForm.email = value,
            validator: (value) {
              String pattern = r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regExp = RegExp(pattern);
              return regExp.hasMatch(value ?? '') ? null : 'Introduce un email válido';
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            autocorrect: false,
            obscureText: true,
            decoration: InputDecorations.authInputDecoration(
              hintText: '********',
              labelText: 'Contraseña',
              prefixIcon: Icons.lock_outline,
            ),
            onChanged: (value) => registerForm.password = value,
            validator: (value) => (value != null && value.length >= 6) ? null : 'Mínimo 6 caracteres',
          ),
          const SizedBox(height: 30),
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            disabledColor: Colors.grey,
            elevation: 0,
            color: Colors.deepPurple,
            onPressed: registerForm.isLoading ? null : () async {
              FocusScope.of(context).unfocus();
              final authService = Provider.of<AuthService>(context, listen: false);
              
              if (!registerForm.isValidForm()) return;

              registerForm.isLoading = true;

              final String? errorMessage = await authService.createUser(registerForm.email, registerForm.password);

              if (errorMessage == null) {
                Navigator.pushReplacementNamed(context, 'home');
              } else {
                NotificationsService.showSnackbar('Error al crear la cuenta: $errorMessage');
                registerForm.isLoading = false;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              child: Text(
                registerForm.isLoading ? 'Espere' : 'Registrarse',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}