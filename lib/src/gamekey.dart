part of dartsnake;

/**
 * Provides parts of the GameKey REST API necessary for the SnakeGame.
 */
class GameKey {

  // URI of GameKey Service
  Uri _uri;

  // Game ID
  String _gid;

  // Game secret
  String _secret;

  // Service reachable?
  bool _available = false;

  /**
   * Constructor
   */
  GameKey(String host, int port, this._gid, this._secret) {
    this._uri = new Uri.http("$host:$port", "/");
  }

  /**
   * Game ID
   */
  String get gameId => this._gid;


  /**
   * URI of GameKey REST API
   */
  Uri get uri => this._uri;

  /**
   * Helper method to generate parameter body for REST requests.
   */
  static String parameter(Map<String, String> p) => (new Uri(queryParameters: p)).query;

  /**
   * Registers a non existing user with the gamekey service.
   * - Returns user map with stored values on success
   * - Returns null if user could not be stored (due to several reasons, gamekey service not reachable, user already existing)
   */
  Future<Map> registerUser(String name, String pwd) async {
    if (!_available) return new Future.value(null);
    try {
      final answer = await HttpRequest.request(
          "${this._uri.resolve("/user")}",
          method: 'POST',
          sendData: parameter({
            'name'   : "$name",
            'pwd' : "$pwd",
          }),
          requestHeaders: {
            'content-type': 'application/x-www-form-urlencoded',
            'charset': 'UTF-8'
          }
      );
      return answer.status == 200 ? JSON.decode(answer.responseText) : throw answer.responseText;
    } catch (error, stacktrace) {
      print ("GameKey.registerUser() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   * Returns detailed user information as Map.
   * Additionally, this method can be used to authenticate a user.
   * A user must know his [id] and his [password].
   */
  Future<Map> getUser(String id, String pwd) async {
    if (!_available) return new Future.value(null);
    try {
      final uri = this._uri.resolve("/user/$id").resolveUri(new Uri(queryParameters: { 'pwd' : "$pwd" }));
      final answer = await HttpRequest.request("$uri", method: 'GET');
      return answer.status == 200 ? JSON.decode(answer.responseText) : throw answer.responseText;
    } catch (error, stacktrace) {
      print ("GameKey.getUser() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   * This method can be used to authenticate a game.
   * A game must know its [id] and its [secret].
   * This method is used to check periodically gamekey service availability
   * and sets _available flag accordingly.
   */
  Future<bool> authenticate() async {
    try {
      final uri = this._uri.resolve("/game/$_gid").resolveUri(new Uri(queryParameters: { 'secret' : "$_secret" }));
      final answer = await HttpRequest.request("$uri", method: 'GET');
      if (answer.status == 200) { this._available = true; }
      return answer.status == 200 ? true : throw answer.responseText;
    } catch (error, stacktrace) {
      print ("GameKey.getGame() caused following error: '$error'");
      print ("$stacktrace");
      this._available = false;
      return false;
    }
  }

  /**
   * Returns the user id of a given name.
   * Returns null if name is not present or on error.
   */
  Future<String> getUserId(String name) async {
    if (!_available) return new Future.value(null);
    try {
      final users = await listUsers();
      if (users == null) return null;
      final user = users.firstWhere((user) => user['name'] == name, orElse: null);
      return user == null ? null : user['id'];
    } catch (error, stacktrace) {
      print ("GameKey.getUserId() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   * Lists all users registered with the gamekey service.
   */
  Future<List<Map>> listUsers() async {
    if (!_available) return new Future.value([]);
    try {
      final answer = await HttpRequest.request("${this._uri.resolve("/users")}", method: 'GET');
      return JSON.decode(answer.responseText);
    } catch (error, stacktrace) {
      print ("GameKey.listUsers() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   * Retrieves all states stored for this game.
   */
  Future<List<Map>> getStates() async {
    if (!_available) return new Future.value([]);
    try {
      final uri = this._uri.resolve("/gamestate/$_gid").resolveUri(new Uri(queryParameters: { 'secret' : "$_secret" }));
      final answer = await HttpRequest.request("$uri", method: 'GET');
      return JSON.decode(answer.responseText);
    } catch (error, stacktrace) {
      print ("GameKey.getStates() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   * Stores an arbitrary state encoded as map for a user with identifier [uid]
   * for this game.
   */
  Future<bool> storeState(String uid, Map state) async {
    if (!_available) return new Future.value(false);
    try {
      final answer = await HttpRequest.request(
          "${this._uri.resolve("/gamestate/$_gid/$uid")}",
          method: 'POST',
          sendData: parameter({
            'secret' : "$_secret",
            'state' : "${JSON.encode(state)}",
          }),
          requestHeaders: {
            'content-type': 'application/x-www-form-urlencoded',
            'charset': 'UTF-8'
          }
      );
      return answer.status == 200 ? true : throw answer.responseText;
    } catch (error, stacktrace) {
      print ("GameKey.storeState() caused following error: '$error'");
      print ("$stacktrace");
      return false;
    }
  }
}