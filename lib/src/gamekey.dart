part of dartsnake;

/**
 * Provides part of the GameKey REST API necessary for the SnakeGame.
 */
class GameKey {

  // URI of GameKey Service
  Uri _uri;

  // Game ID
  String _gid;

  // Game secret
  String _secret;


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
   *
   */
  Future<Map> registerUser(String name, String pwd) async {
    try {
      final pending = new Completer();
      final request = new HttpRequest();
      request
        ..open("POST", "${this._uri.resolve("/user")}")
        ..setRequestHeader('content-type', 'application/x-www-form-urlencoded')
        ..setRequestHeader('charset', 'UTF-8')
        ..onLoadEnd.listen((_) => pending.complete(request.status != 200 ? throw request.responseText : JSON.decode(request.responseText)))
        ..send(parameter({
          'name'   : "$name",
          'pwd' : "$pwd",
        }));
      return pending.future;
    } catch (error, stacktrace) {
      print ("GameKey.registerUser() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   *
   */
  Future<Map> getUser(String id, String pwd) async {
    try {
      final pending = new Completer();
      final request = new HttpRequest();

      final uri = this._uri.resolve("/user/$id");
      uri.query = { 'pwd' : "$pwd" };
      request
        ..open("GET", "${this._uri.resolve("/user/$id")}")
        ..onLoadEnd.listen((_) => pending.complete(request.status != 200 ? throw request.responseText : JSON.decode(request.responseText)))
        ..send();
      return pending.future;
    } catch (error, stacktrace) {
      print ("GameKey.getUser() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   *
   */
  Future<List<Map>> listUsers() async {
    try {
      final pending = new Completer();
      final answer = await HttpRequest.request("${this._uri.resolve("/users")}", method: 'GET');
      return JSON.decode(answer.responseText);
    } catch (error, stacktrace) {
      print ("GameKey.listUsers() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }

  /**
   *
   */
  Future<List<Map>> listGames() async {
    try {
      final pending = new Completer();
      final answer = await HttpRequest.request("${this._uri.resolve("/games")}", method: 'GET');
      return JSON.decode(answer.responseText);
    } catch (error, stacktrace) {
      print ("GameKey.listGames() caused following error: '$error'");
      print ("$stacktrace");
      return null;
    }
  }
}