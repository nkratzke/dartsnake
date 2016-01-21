part of dartsnake;

/**
 * Constant to define the speed of a [Snake].
 * A [snakeSpeed] of 250ms means 4 movements per second.
 */
const snakeSpeed = const Duration(milliseconds: 250);

/**
 * Constant to define the speed of a [Mouse].
 * A [miceSpeed] of 1000ms means 1 movement per second.
 */
const miceSpeed = const Duration(milliseconds: 750);

/**
 * Constant to define the acceleration of a [Mouse].
 * An [acceleration] of 0.01 means 1% speed increase for every eaten mouse.
 */
const acceleration = 0.05;

/**
 * Constant to define the interval how often it is checked, that
 * a [GameKey] server is reachable.
 * A [gamekeyCheck] of 5 seconds means gamekey service is checked every 5 seconds.
 */
const gamekeyCheck = const Duration(seconds: 30);

/**
 * Constant of the game secret used to authenticate against the gamekey service.
 */
const gameSecret = '2obvious';

/**
 * Constant of the relative path which stores the gamekey settings.
 */
const gamekeySettings = 'gamekey.json';

/**
 * A [SnakeGameController] object registers several handlers
 * to grab interactions of a user with a [SnakeGame] and translate
 * them into valid [SnakeGame] actions.
 *
 * Furthermore a [SnakeGameController] object triggers the
 * movements of a [Snake] object and (several) [Mouse] objects
 * of a [SnakeGame].
 *
 * Necessary updates of the view are delegated to a [SnakeView] object
 * to inform the user about changing [SnakeGame] states.
 */
class SnakeGameController {

  /**
   * Referencing the to be controlled model.
   */
  var game = new SnakeGame(gamesize);

  /**
   * Referencing the presenting view.
   */
  final view = new SnakeView();

  /**
   * Referencing the gamekey API used to store game states.
   * Only initial values. The gamekey API client object
   * will be recreated using data encoded in the gamekey.json
   * file (defined by the [gamekeySettings] constant).
   * The settings file must be placed in the same directory as the
   * game (index.html, snakeclient.dart and style.css).
   */
  var gamekey = new GameKey('undefined', 8080, 'undefined', 'undefined');

  /**
   * Periodic trigger controlling snake movement.
   */
  Timer snakeTrigger;

  /**
   * Periodic trigger controlling mice movement.
   */
  Timer miceTrigger;

  /**
   * Periodic trigger controlling availability of gamekey service.
   */
  Timer gamekeyTrigger;

  /**
   * Constructor to create a controller object.
   * Registers all necessary event handlers necessary
   * for the user to interact with a [SnakeGame].
   */
  SnakeGameController() {

    // Establish gamekey connection
    try {
      // Download gamekey settings. Display warning on problems.
      HttpRequest.getString(gamekeySettings).then((json) {
        final settings = JSON.decode(json);

        // Create gamekey client using connection parameters
        this.gamekey = new GameKey(
            settings['host'],
            settings['port'],
            settings['gameid'],
            gameSecret
        );

        // Check periodically if gamekey service is reachable. Display warning if not.
        this.gamekeyTrigger = new Timer.periodic(gamekeyCheck, (_) async {
          if (await this.gamekey.authenticate()) {
            view.warningoverlay.innerHtml = "";
          } else {
            view.warningoverlay.innerHtml =
              "Could not connect to gamekey service. "
              "Highscore will not working properly.";
          }
        });
      });
    } catch (error, stacktrace) {
      print ("SnakeGameController() caused following error: '$error'");
      print ("$stacktrace");
      view.warningoverlay.innerHtml =
        "Could not get gamekey settings. "
        "Highscore will not working properly.";
    }

    view.generateField(game);
    getHighscores().then((highscore) => view.update(game, scores: highscore));

    // New game is started by user
    view.startButton.onClick.listen((_) {
      if (snakeTrigger != null) snakeTrigger.cancel();
      if (miceTrigger != null) miceTrigger.cancel();
      snakeTrigger = new Timer.periodic(snakeSpeed, (_) => _moveSnake());
      miceTrigger = new Timer.periodic(miceSpeed, (_) => _moveMice());
      game.start();
      view.update(game);
    });

    // Steering of the snake
    window.onKeyDown.listen((KeyboardEvent ev) {
      if (game.stopped) return;
      switch (ev.keyCode) {
        case KeyCode.LEFT:  game.snake.headLeft(); break;
        case KeyCode.RIGHT: game.snake.headRight(); break;
        case KeyCode.UP:    game.snake.headUp(); break;
        case KeyCode.DOWN:  game.snake.headDown(); break;
      }
    });
  }

  /**
   * Retrieves TOP 10 highscore from Gamekey service.
   * - Returns List of max. 10 highscore entries. { 'name': STRING, 'score': INT }
   * - Returns [] if gamekey service is not available.
   * - Returns [] if no highscores are present.
   */
  Future<List<Map>> getHighscores() async {
    var scores = [];
    try {
      final states = await gamekey.getStates();
      scores = states.map((entry) => {
        'name' : "${entry['username']}",
        'score' : entry['state']['points']
      }).toList();
      scores.sort((a, b) => b['score'] - a['score']);
    } catch (error, stacktrace) {
      print (error);
      print (stacktrace);
    }
    return scores.take(10);
  }

  /**
   * Handles Game Over.
   */
  dynamic _gameOver() async {
    snakeTrigger.cancel();
    miceTrigger.cancel();

    game.stop();
    view.update(game);

    // Show TOP 10 Highscore
    final highscore = await getHighscores();
    view.showHighscore(game, highscore);

    // Handle save button
    document.querySelector('#save')?.onClick?.listen((_) async {

      String user = view.user;
      String pwd  = view.password;

      if (user?.isEmpty) { view.warn("Please provide user name."); return; }

      String id = await gamekey.getUserId(user);
      if (id == null) {
        view.warn(
          "User $user not found. Shall we create it?"
          "<button id='create'>Create</button>"
          "<button id='cancel' class='discard'>Cancel</button>"
        );
        document.querySelector('#cancel')?.onClick?.listen((_) => _newGame());
        document.querySelector('#create')?.onClick?.listen((_) async {
          final usr = await gamekey.registerUser(user, pwd);
          if (usr == null) {
            view.warn(
              "Could not register user $user. "
              "User might already exist or gamekey service not available."
            );
            return;
          }
          view.warn("");
          final stored = await gamekey.storeState(usr['id'], {
            'version': '0.0.2',
            'points': game.miceCounter
          });
          if (stored) {
            view.warn("${game.miceCounter} mice stored for $user");
            view.closeForm();
            _newGame();
            return;
          } else {
            view.warn("Could not save highscore. Retry?");
            return;
          }
        });
      }

      // User exists.
      if (id != null) {
        final user = await gamekey.getUser(id, pwd);
        if (user == null) { view.warn("Wrong access credentials."); return; };
        final stored = await gamekey.storeState(user['id'], {
          'version': '0.0.2',
          'points': game.miceCounter
        });
        if (stored) {
          view.warn("${game.miceCounter} mice stored for ${user['name']}");
          view.closeForm();
          _newGame();
          return;
        } else {
          view.warn("Could not save highscore. Retry?");
          return;
        }
      }
    });

    // Handle cancel button
    document.querySelector('#close')?.onClick?.listen((_) => _newGame());
  }

  /**
   * Initiates a new game.
   */
  dynamic _newGame() async {
    view.closeForm();
    game = new SnakeGame(gamesize);

    // Show TOP 10 Highscore
    final highscore = await getHighscores();
    view.update(game, scores: highscore);
  }

  /**
   * Moves all mice.
   */
  void _moveMice() {
    if (game.gameOver) { _gameOver(); return; }
    game.moveMice();
    view.update(game);
  }

  /**
   * Moves the snake.
   */
  void _moveSnake() {
    if (game.gameOver) { _gameOver(); return; }

    final mice = game.miceCounter;
    game.moveSnake();
    if (game.miceCounter > mice) { _increaseSnakeSpeed(); }
    if (game.gameOver) return;
    view.update(game);
  }

  /**
   * Increases Snake speed for every eaten mouse.
   */
  void _increaseSnakeSpeed() {
    snakeTrigger.cancel();
    final newSpeed = snakeSpeed * pow(1.0 - acceleration, game.miceCounter);
    snakeTrigger = new Timer.periodic(newSpeed, (_) => _moveSnake());
  }
}
