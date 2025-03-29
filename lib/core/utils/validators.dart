class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O email é obrigatório';
    }

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, informe um email válido';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'A senha é obrigatória';
    }

    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'O nome é obrigatório';
    }

    if (value.length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'O telefone é obrigatório';
    }

    final RegExp phoneRegex = RegExp(
      r'^\+?[0-9]{10,15}$',
    );

    if (!phoneRegex.hasMatch(value)) {
      return 'Por favor, informe um telefone válido';
    }

    return null;
  }

  static String? validateCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'O código é obrigatório';
    }

    if (value.length != 6) {
      return 'O código deve ter 6 dígitos';
    }

    return null;
  }

  static String? validateServiceTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'O título é obrigatório';
    }

    if (value.length < 5) {
      return 'O título deve ter pelo menos 5 caracteres';
    }

    return null;
  }

  static String? validateServiceDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'A descrição é obrigatória';
    }

    if (value.length < 20) {
      return 'A descrição deve ter pelo menos 20 caracteres';
    }

    return null;
  }

  static String? validateServicePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'O preço é obrigatório';
    }

    final RegExp priceRegex = RegExp(
      r'^\d+([.,]\d{1,2})?$',
    );

    if (!priceRegex.hasMatch(value)) {
      return 'Por favor, informe um preço válido';
    }

    final double price = double.parse(value.replaceAll(',', '.'));

    if (price <= 0) {
      return 'O preço deve ser maior que zero';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'O endereço é obrigatório';
    }

    if (value.length < 5) {
      return 'Por favor, informe um endereço completo';
    }

    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'O campo $fieldName é obrigatório';
    }

    return null;
  }

  static String? validateOptional(String? value) {
    return null;
  }
}
