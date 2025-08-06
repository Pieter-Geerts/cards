import 'package:cards/helpers/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';

// Generate mocks for all these classes
@GenerateNiceMocks([MockSpec<DatabaseHelper>(), MockSpec<NavigatorObserver>()])
void main() {}
