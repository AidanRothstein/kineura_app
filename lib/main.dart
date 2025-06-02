import 'package:flutter/material.dart';
import 'app.dart';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

import 'amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Amplify.addPlugins([
      AmplifyAuthCognito(),
      AmplifyAPI(),
      AmplifyStorageS3(),
    ]);
    await Amplify.configure(amplifyconfig);
    safePrint('✅ Amplify configured successfully');
  } on AmplifyAlreadyConfiguredException {
    safePrint('⚠️ Amplify was already configured.');
  } catch (e) {
    safePrint('❌ Failed to configure Amplify: $e');
  }

  runApp(const App());
}
