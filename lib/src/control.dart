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
 * Constant of the gamekey service.
 */
const gamekeyHost = '127.0.0.1';

/**
 * Constant of the gamekey service (port).
 */
const gamekeyPort = 8080;

/**
 * Constant of the game ID used to authenticate against the gamekey service.
 */
const gameId = 'cbcdfdad-accb-414d-b165-4f9512b7041b';

/**
 * Constant of the game secret used to authenticate against the gamekey service.
 */
const gameSecret = '10a1c9b5888eee11';

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
   */
  final gamekey = new GameKey(gamekeyHost, gamekeyPort, gameId, gameSecret);

  /**
   * Periodic trigger controlling snake movement.
   */
  Timer snakeTrigger;

  /**
   * Periodic trigger controlling mice movement.
   */
  Timer miceTrigger;

  /**
   * Constructor to create a controller object.
   * Registers all necessary event handlers necessary
   * for the user to interact with a [SnakeGame].
   */
  SnakeGameController() {

    // Check if gamekey service is reachable. Display warning if not.
    gamekey.listGames().then((games) {
      if (games == null) {
        view.warningoverlay.innerHtml =
          "Could not connect to gamekey service. "
          "Highscore will not working properly. ";
      }
    });

    view.generateField(game);

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
   * Handles Game Over.
   */
  void _gameOver() {
    game.stop();
    view.update(game);

    // Show highscore
    view.showHighscore(game);

    // Handle save button
    document.querySelector('#save').onClick.listen((_) async {

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
        document.querySelector('#cancel').onClick.listen((_) => _newGame());
        document.querySelector('#create').onClick.listen((_) async {
          final usr = await gamekey.registerUser(user, pwd);
          if (usr == null) { view.warn("Could not register user $user. User might already exist?"); return; }
          view.warn("");
          final stored = await gamekey.storeState(usr['id'], {
            'version': '0.0.1',
            'points': "${game.miceCounter}"
          });
          if (stored) {
            view.warn("${game.miceCounter} mice stored for $user");
            view.closeForm();
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
          'version': '0.0.1',
          'points': "${game.miceCounter}"
        });
        if (stored) {
          view.warn("${game.miceCounter} mice stored for ${user['name']}");
          view.closeForm();
          return;
        } else {
          view.warn("Could not save highscore. Retry?");
          return;
        }
      }
    });

    // Handle cancel button
    document.querySelector('#close').onClick.listen((_) => _newGame());

    snakeTrigger.cancel();
    miceTrigger.cancel();
  }

  /**
   * Initiates a new game.
   */
  void _newGame() {
    view.closeForm();
    game = new SnakeGame(gamesize);
    view.update(game);
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
