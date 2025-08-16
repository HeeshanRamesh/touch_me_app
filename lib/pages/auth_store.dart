class AuthStore {
  static final Map<String, String> _users = {};

  static bool register(String username, String password) {
    if (_users.containsKey(username)) return false;
    _users[username] = password;
    return true;
  }

  static bool login(String username, String password) {
    return _users[username] == password;
  }
}
