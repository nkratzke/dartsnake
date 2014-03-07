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
const miceSpeed = const Duration(milliseconds: 1000);

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
   * Constructor to create a controller object.
   * Registers all necessary event handlers necessary
   * for the user to interact with a [SnakeGame].
   */
  SnakeGameController() {

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
    if (game.gameOver) { game.stop(); view.update(game); return; }
    game._moveMice();
    view.update(game);
  }

  /**
   * Moves the snake.
   */
  void _moveSnake() {
    if (game.gameOver) { game.stop(); view.update(game); return; }
    game._moveSnake();
    if (game.gameOver) return;
    view.update(game);
  }
}
