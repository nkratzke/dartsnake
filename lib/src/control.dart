part of dartsnake;

/**
 * Parameter to define the speed of a [Snake].
 * A [snakeSpeed] of 250ms means 4 movements per second.
 */
Duration snakeSpeed = Duration(milliseconds: 250);

/**
 * Parameter to define the speed of a [Mouse].
 * A [miceSpeed] of 1000ms means 1 movement per second.
 */
Duration miceSpeed = Duration(milliseconds: 750);

/**
 * Parameter to define the acceleration of a [Mouse].
 * An [acceleration] of 0.01 means 1% speed increase for every eaten mouse.
 */
double acceleration = 0.05;

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

    _loadParameter();

    view.generateField(game);

    // New game is started by user
    view.startButton.onClick.listen((_) {
      if (snakeTrigger != null) snakeTrigger.cancel();
      if (miceTrigger != null) miceTrigger.cancel();
      snakeTrigger = new Timer.periodic(snakeSpeed, (_) => _moveSnake());
      miceTrigger = new Timer.periodic(miceSpeed, (_) => _moveMice());
      _newGame();
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
   * Loads the game parameters.
   */
  void _loadParameter() async {
    var response = await http.get(Uri.http(window.location.host, "/parameter.json"));
    var parameters = jsonDecode(response.body);
    snakeSpeed = Duration(milliseconds: parameters['snakeSpeed'] as int);
    miceSpeed = Duration(milliseconds: parameters['miceSpeed'] as int);
    acceleration = parameters['acceleration'] as double;
  }

  /**
   * Handles Game Over.
   */
  void _gameOver() async {
    snakeTrigger.cancel();
    miceTrigger.cancel();

    game.stop();
    view.update(game);
  }

  /**
   * Initiates a new game.
   */
  void _newGame() async {
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
