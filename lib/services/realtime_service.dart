import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class RealtimeService {
  static RealtimeChannel subscribeToTable({
    required String channelName,
    required String table,
    required String filter,
    required Function(PostgresChangeEvent event, Map<String, dynamic> record) callback,
  }) {
    return SupabaseService.client
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: filter.split('=')[0],
            value: filter.split('=')[1],
          ),
          callback: (payload) {
            callback(payload.eventType, payload.newRecord);
          },
        )
        .subscribe();
  }
}
