/// [ValidationContext] is the public interface for an object keeping track of the current validation state.
/// A concrete instance is passed into the validation function an updated is return from the validation function.
abstract class ValidationContext {
  /// Use [addError] to add a new error message to the validation context.
  void addError(String message);

  /// Use [addWarning] to ad a new warning message to the validation context.
  void addWarning(String message);
}
