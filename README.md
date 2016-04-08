This is a game I wrote in Tcl many years ago (somewhere around 2005). 

The basic idea of the game is that you click on a grouping of 2 or more cubes of the same color (that are touching) and they are removed. 

Additional rules include:
- The number of cubes left on the board when you have no more groups left is subtracted from your "life". When you get to 0 life, the game is over.
- The larger the grouping, the greater the number of points gained when removing it (I don't remember the formula offhand, but it's not linear)
- There are some special cube types that activate when a grouping includes/touches them
 - **2x**, **3x** : multiply the score for the grouping
 - **+1** : increase the grouping by 1 in every direction
 - **W** : wildcard, included with any group touching it

It's a pretty simple game, but it was fun to write at the time.

It is my intention to re-implement it in Javascript, to be played in the browser... for no reason other than my own entertainment *(in writing it, that is)*.
