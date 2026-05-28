import 'dart:io';

import 'package:postgres/postgres.dart';

Future<void> main(List<String> args) async {
  final databaseUrl = _readEnvValue('DATABASE_URL');

  if (databaseUrl == null || databaseUrl.isEmpty) {
    stderr.writeln('DATABASE_URL is missing. Set it in .env before running.');
    exitCode = 1;
    return;
  }

  final migrationFile = File('migrations/001_create_profiles.sql');
  if (!migrationFile.existsSync()) {
    stderr.writeln('Migration file not found: ${migrationFile.path}');
    exitCode = 1;
    return;
  }

  final migrationSql = migrationFile.readAsStringSync();
  final connection = await Connection.openFromUrl(databaseUrl);

  try {
    print('Connected to PostgreSQL successfully.');

    for (final statement in migrationSql.split(';')) {
      final sql = statement.trim();
      if (sql.isEmpty) continue;
      await connection.execute(sql);
    }
    print('Migration applied: ${migrationFile.path}');

    final rows = await connection.execute(
      'SELECT id, username, full_name, email, phone_number, created_at FROM public.profiles ORDER BY created_at ASC LIMIT 10',
    );

    print('profiles rows: ${rows.length}');
    for (final row in rows) {
      final data = row.toColumnMap();
      print(
        '${data['id']} | ${data['username']} | ${data['full_name']} | ${data['email']} | ${data['phone_number']} | ${data['created_at']}',
      );
    }
  } on PgException catch (error) {
    stderr.writeln('PostgreSQL error: $error');
    exitCode = 1;
  } catch (error) {
    stderr.writeln('Unexpected error: $error');
    exitCode = 1;
  } finally {
    await connection.close();
  }
}

String? _readEnvValue(String key) {
  final envFile = File('.env');
  if (!envFile.existsSync()) return null;

  for (final line in envFile.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#') || !trimmed.contains('=')) {
      continue;
    }

    final index = trimmed.indexOf('=');
    final currentKey = trimmed.substring(0, index).trim();
    if (currentKey != key) continue;

    return trimmed.substring(index + 1).trim();
  }

  return null;
}
