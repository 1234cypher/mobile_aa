import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confidence_boost/providers/auth_provider.dart';
import 'package:confidence_boost/providers/task_provider.dart';
import 'package:confidence_boost/providers/success_provider.dart';
import 'package:confidence_boost/providers/user_provider.dart';
import 'package:confidence_boost/providers/project_provider.dart';
import 'package:confidence_boost/providers/mood_provider.dart';
import 'package:confidence_boost/providers/challenge_provider.dart';
import 'package:confidence_boost/providers/community_provider.dart';
import 'package:confidence_boost/providers/learning_provider.dart';
import 'package:confidence_boost/screens/splash_screen.dart';
import 'package:confidence_boost/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null); // ou la locale que tu utilises
  runApp(const ConfidenceBoostApp());
}

class ConfidenceBoostApp extends StatelessWidget {
  const ConfidenceBoostApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SuccessProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
      ],
      child: MaterialApp(
        title: 'ConfidenceBoost',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
