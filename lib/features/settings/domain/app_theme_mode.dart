/// Which theme the app runs in.
///
/// Deliberately its own enum instead of Flutter's `ThemeMode`: the names are
/// written to the database and should not follow a framework type that we do
/// not control. The translation happens where the theme is applied, in
/// `app.dart`.
enum AppThemeMode { system, light, dark }
