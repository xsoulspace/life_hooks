/// Provides utility functions for working with [DateTime] objects.
///
/// This class includes methods for converting between [DateTime] and
/// milliseconds since epoch, as well as obtaining the current UTC time.
///
/// @ai Use these utility functions to simplify date and time manipulations
/// in your application.
DateTime dateTimeNowUtc() => DateTime.now().toUtc();

/// Converts milliseconds since epoch to a [DateTime] object.
///
/// Returns null if the provided millisecondsSinceEpoch is null.
///
/// @param millisecondsSinceEpoch The milliseconds since epoch to convert.
/// @returns A [DateTime] object or null if the input is null.
///
/// @ai Use this function to convert timestamps from external sources into
/// [DateTime] objects for easier manipulation.
DateTime? dateTimeFromMilisecondsSinceEpoch(final int? millisecondsSinceEpoch) {
  if (millisecondsSinceEpoch == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
}

/// Converts a [DateTime] object to milliseconds since epoch.
///
/// Returns null if the provided dateTime is null.
///
/// @param dateTime The [DateTime] object to convert.
/// @returns The milliseconds since epoch or null if the input is null.
///
/// @ai Use this function to serialize [DateTime] objects for storage or
/// transmission.
int? dateTimeToMilisecondsSinceEpoch(final DateTime? dateTime) {
  if (dateTime == null) return null;
  return dateTime.millisecondsSinceEpoch;
}
