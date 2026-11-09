import 'package:drift/drift.dart';

/// La compilación web es solo de desarrollo: sin base persistente (se usa [MemoryLocalStore]).
QueryExecutor? openLocalExecutor() => null;
