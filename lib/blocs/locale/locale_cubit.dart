import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleCubit extends Cubit<Locale> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const String _localeKey = 'selected_locale';

  LocaleCubit([Locale? initialLocale])
    : super(initialLocale ?? const Locale('en'));

  Future<void> setLocale(Locale locale) async {
    await _storage.write(key: _localeKey, value: locale.languageCode);
    emit(locale);
  }
}
