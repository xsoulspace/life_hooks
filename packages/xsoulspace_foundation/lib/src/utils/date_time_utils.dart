/// Provides utility functions for working with [DateTime] objects.
///
/// This class includes methods for converting between [DateTime] and
/// milliseconds since epoch, as well as obtaining the current UTC time.
///
/// @ai Use these utility functions to simplify date and time manipulations
/// in your application.
DateTime dateTimeNowUtc() => DateTime.now().toUtc();
