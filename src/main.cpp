#include "Game.h"
#include "MenuState.h"

int WinMain(int, char **){
	Game game("Wenova - Rise of Conquerors");

	State * state =  new MenuState(false);
	game.push(state);

	game.run();

	return 0;
}
