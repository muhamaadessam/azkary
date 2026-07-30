import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/azkar_cubit.dart';
import 'azkar_massa_screen.dart';
import 'azkar_sabah_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('Azkar')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => AzkarCubit(),
                        child: const AzkarSabahScreen(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'أذكار الصباح',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontFamily: 'Traditional',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => AzkarCubit(),
                        child: const AzkarMassaScreen(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'أذكار المساء',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontFamily: 'Traditional',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
