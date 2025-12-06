import 'dart:convert';
// unused import removed

import 'package:chefkit/blocs/auth/auth_cubit.dart';
import 'package:chefkit/blocs/profile/profile_bloc.dart';
import 'package:chefkit/blocs/profile/profile_events.dart';
import 'package:chefkit/blocs/profile/profile_state.dart';
import 'package:chefkit/common/constants.dart';
import 'package:chefkit/common/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:chefkit/l10n/app_localizations.dart';

import '../../../domain/models/user_profile.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();
  final TextEditingController _specialtyInputController =
      TextEditingController();

  List<String> _specialties = <String>[];
  String _avatarUrl = '';
  bool _wasSaving = false;
  String? _lastError;
  bool _formInitialized = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile;
    if (profile != null) {
      _hydrateFromProfile(profile);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _storyController.dispose();
    _specialtyInputController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(UserProfile profile) {
    _fullNameController.text = profile.name;
    _bioController.text = profile.bio ?? '';
    _storyController.text = profile.story ?? '';
    _specialties = List<String>.from(profile.specialties ?? const <String>[]);
    _avatarUrl = profile.avatarUrl;
    _formInitialized = true;
  }

  void _refreshFromProfile(UserProfile profile, {required bool syncText}) {
    if (syncText) {
      _fullNameController.text = profile.name;
      _bioController.text = profile.bio ?? '';
      _storyController.text = profile.story ?? '';
      _formInitialized = true;
    }

    final updatedSpecialties = List<String>.from(
      profile.specialties ?? const <String>[],
    );
    final updatedAvatar = profile.avatarUrl;

    if (!listEquals(_specialties, updatedSpecialties) ||
        _avatarUrl != updatedAvatar) {
      setState(() {
        _specialties = updatedSpecialties;
        _avatarUrl = updatedAvatar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.profile != current.profile ||
          previous.error != current.error ||
          previous.saving != current.saving,
      listener: (context, state) {
        if (!mounted) return;

        if (state.profile != null) {
          final shouldSyncText =
              !_formInitialized || (_wasSaving && !state.saving);
          _refreshFromProfile(state.profile!, syncText: shouldSyncText);
        }

        if (state.error != null &&
            state.error!.isNotEmpty &&
            state.error != _lastError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.profileUpdateError(state.error!),
              ),
            ),
          );
          _lastError = state.error;
        } else if (state.error == null) {
          _lastError = null;
        }

        if (_wasSaving && !state.saving && state.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.profileUpdateSuccess),
            ),
          );
          _lastError = null;
        }

        _wasSaving = state.saving;
      },
      builder: (context, state) {
        final profile = state.profile;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              AppLocalizations.of(context)!.personalInfoTitle,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.red600.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[200],
                          backgroundImage:
                              _avatarUrl.isNotEmpty &&
                                  _avatarUrl.startsWith('http')
                              ? NetworkImage(_avatarUrl)
                              : null,
                          child:
                              (_avatarUrl.isEmpty ||
                                  !_avatarUrl.startsWith('http'))
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final userId = context.read<AuthCubit>().state.userId;
                          if (userId != null) {
                            _onEditAvatarPressed(context, userId);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.red600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildLabeledField(
                  label: AppLocalizations.of(context)!.fullNameLabel,
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // Only show chef-specific fields if user is a chef
                if (state.profile?.isChef ?? false) ...[
                  _buildLabeledField(
                    label: AppLocalizations.of(context)!.bioLabel,
                    controller: _bioController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  _buildLabeledField(
                    label: AppLocalizations.of(context)!.storyLabel,
                    controller: _storyController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    AppLocalizations.of(context)!.specialtiesLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final item in _specialties)
                        Chip(
                          label: Text(item),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(() {
                              _specialties = List<String>.from(_specialties)
                                ..remove(item);
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _specialtyInputController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addSpecialty(),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(
                              context,
                            )!.addSpecialtyHint,
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _addSpecialty,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.saving
                        ? null
                        : () => _onSavePressed(context, state.profile!.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.saveChanges,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addSpecialty() {
    final text = _specialtyInputController.text.trim();
    if (text.isEmpty) return;
    if (_specialties.contains(text)) {
      _specialtyInputController.clear();
      return;
    }
    setState(() {
      _specialties = List<String>.from(_specialties)..add(text);
    });
    _specialtyInputController.clear();
  }

  void _onSavePressed(BuildContext context, String userId) {
    final fullName = _fullNameController.text.trim();
    final bio = _bioController.text.trim();
    final story = _storyController.text.trim();
    final specialties = List<String>.from(_specialties);

    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fullNameEmptyError),
        ),
      );
      return;
    }

    context.read<ProfileBloc>().add(
      UpdatePersonalInfo(
        userId: userId,
        fullName: fullName,
        bio: bio,
        story: story,
        specialties: specialties,
      ),
    );
  }
}

Widget _buildLabeledField({
  required String label,
  required TextEditingController controller,
  int maxLines = 1,
  TextInputAction? textInputAction,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        maxLines: maxLines,
        textInputAction: textInputAction,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.red600.withOpacity(0.5),
              width: 1,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ],
  );
}

Future<void> _onEditAvatarPressed(BuildContext context, String userId) async {
  try {
    print('=== _onEditAvatarPressed called ===');
    print('Opening image picker...');

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );

    print('Picked result: ${picked?.path ?? "null - user cancelled"}');
    if (picked == null) {
      print('User cancelled image selection');
      return;
    }

    print('Reading image bytes...');
    final bytes = await picked.readAsBytes();
    print('Image size: ${bytes.length} bytes');

    print('Encoding to base64...');
    final b64 = base64Encode(bytes);
    print('Base64 length: ${b64.length} characters');

    final authState = context.read<AuthCubit>().state;
    final accessToken = authState.accessToken;
    print('Access token present: ${accessToken != null}');
    if (accessToken != null) {
      final preview = accessToken.length > 16
          ? '${accessToken.substring(0, 16)}...'
          : accessToken;
      print('Access token preview: $preview');
    }

    final String baseUrl = AppConfig.baseUrl; // Use centralized config
    print('Upload URL: $baseUrl/api/users/$userId/avatar');

    print('Uploading to backend...');
    final resp = await http.post(
      Uri.parse('$baseUrl/api/users/$userId/avatar'),
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'image_base64': b64}),
    );

    print('Upload response: ${resp.statusCode}');
    print('Response body: ${resp.body}');
    print('Response headers: ${resp.headers}');

    if (resp.statusCode == 200) {
      print('✅ Upload successful! Reloading profile...');
      context.read<ProfileBloc>().add(LoadProfile(userId: userId));
    } else {
      print('❌ Upload failed: ${resp.statusCode} ${resp.body}');
      debugPrint('Avatar upload failed: ${resp.statusCode} ${resp.body}');
    }
  } catch (e) {
    print('❌ Error in _onEditAvatarPressed: $e');
    debugPrint('Avatar upload error: $e');
  }
}
