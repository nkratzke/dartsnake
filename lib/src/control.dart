part of dartsnake;

class SnakeGameController {

  /**
   * To be controlled model.
   */
  var game = new SnakeGame(gamesize);

  /**
   * Presenting view.
   */
  final view = new SnakeView();

  /**
   * Periodic trigger controlling the snake.
   */
  Timer snakeTrigger;

  /**
   * Periodic trigger controlling the mice.
   */
  Timer miceTrigger;

  /**
   * Constructor to create a SnakeGame object.
   * Registers all necessary event handlers.
   */
  SnakeGameController() {

    // New game is started by user
    view.startButton.onClick.listen((_) {
      if (snakeTrigger != null) snakeTrigger.cancel();
      if (miceTrigger != null) miceTrigger.cancel();
      game = new SnakeGame(gamesize);
      view.generateField(game);
      snakeTrigger = new Timer.periodic(new Duration(milliseconds: 250), (_) => moveSnake());
      miceTrigger = new Timer.periodic(new Duration(milliseconds: 1000), (_) => moveMice());
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
  void moveMice() {
    if (game.gameOver) { game.stop(); view.update(game); return; }
    game.moveMice();
    view.update(game);
  }

  /**
   * Moves the snake.
   */
  void moveSnake() {
    if (game.gameOver) { game.stop(); view.update(game); return; }
    game.moveSnake();
    if (game.gameOver) return;
    view.update(game);
  }
}
