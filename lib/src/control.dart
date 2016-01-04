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

    gamekey.listUsers().then((users) {
      if (users == null) {
        view.warningoverlay.innerHtml =
          "Could not connect to gamekey service. "
          "Highscore will not working properly. ";
      }
    });

    // New game is started by user
    view.startButton.onClick.listen((_) {
      if (snakeTrigger != null) snakeTrigger.cancel();
      if (miceTrigger != null) miceTrigger.cancel();
      game = new SnakeGame(gamesize);
      view.generateField(game);
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
   * Moves all mice.
   */
  void _moveMice() {
    if (game.gameOver) {
      game.stop();
      view.update(game);
      return;
    }
    game.moveMice();
    view.update(game);
  }

  /**
   * Moves the snake.
   */
  void _moveSnake() {
    if (game.gameOver) {
      game.stop();
      view.update(game);
      return;
    }
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
