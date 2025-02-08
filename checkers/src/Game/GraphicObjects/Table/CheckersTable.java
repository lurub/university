package Game.GraphicObjects.Table;


import Game.GameObjects.FactoryM.ConcreteFactoryM;
import Game.GameObjects.FactoryM.Factory;
import Game.GameObjects.Pieces.Piece;
import Game.GameObjects.Players.NPlayerExceededException;
import Game.GameObjects.Players.Player;
import Game.GraphicObjects.Start.CheckersStart;
import Game.Observer.CreateTimerObservable;

import java.awt.*;
import javax.swing.*;
import java.lang.Exception;
import java.util.ArrayList;

/**
 * <h1>CheckersTable Class</h1> 
 * it is the class that has all the features and methods that concern the <b>creation</b> and <b>management</b> of the board.
 * @author <a href="https://github.com/Luruu">Luca Rubino</a>
 * @author <a href="https://github.com/RenatoEsposito1999">Renato Esposito</a>
 * @version 1.0
 * @since 31-08-2021
 */

public class CheckersTable extends WindowTable {

    private static CheckersTable Instance; //Singleton

    public  Color activePlayer = Color.red;

    private boolean revisedChecker;
    private Piece pToMove; // Piece to move when a Box is clicked by a player

    /**
     * Constructor.
     * @param N_ROWS number of rows in the field.
     * @param N_COLS number of columns in the field.
     * @param revisedChecker game mode.
     */
    private CheckersTable(int N_ROWS, int N_COLS, boolean revisedChecker) {
        super(N_ROWS, N_COLS);
        this.revisedChecker = revisedChecker;
    }

    /**
     * Singleton (Lazy Initialization because constructor parameters)
     * @param N_ROWS number of rows in the board
     * @param N_COLS number of columns in the board
     * @param revisedChecker game mode chosen by user
     * @return Singleton Instance
     * @see #getInstance()
     */
    public static synchronized CheckersTable getInstance(final int N_ROWS, final int N_COLS, boolean revisedChecker) {
        if (Instance == null)
            Instance = new CheckersTable(N_ROWS, N_COLS, revisedChecker);
        return Instance;
    }
    
    /**
     * Singleton method overload: get the existing instance without specifying unnecessary parameters
     * @return Singleton Instance
     * @throws IstanceException if the instance does not exist it must be created using <code>getInstance(final int, final int, boolean)</code>
     */
    public static synchronized CheckersTable getInstance() throws IstanceException {
        if (Instance == null)
            throw new IstanceException("ISTANCE NULL. Please use method: public static synchronized CheckersTable getInstance(<see args into code>)");
        return Instance;
    }

    /**
     * Set player and timer.
     * @param p1 first player. 
     * @param p2 secondo player.
     * @param timer_value value of the timer.
     * @throws IstanceException Exception checkersTable getInstance() 
     * @throws CloneNotSupportedException Exception
     * @throws NPlayerExceededException Exception
     */
    public void startGame(Player p1, Player p2, int timer_value) throws IstanceException, CloneNotSupportedException, NPlayerExceededException {
        this.p1 = p1;
        this.p2 = p2;
        this.timer_value = timer_value;
        initializeWindow();
        observerList.add(p1);
        observerList.add(p2);
        observerList.add(panelInfo);
        timer = new CreateTimerObservable(observerList, 2, this.timer_value);
    }

    
    /**
     * Shows the moves allowed to click on a piece.
     * @param pClicked piece clicked on the table.
     */
    protected void suggestions(Piece pClicked) {
        pToMove = pClicked;
        pToMove.showSuggestions(pToMove.setRowbyColor());
    }


    /**
     * Move piece into dstBox.
     * @param dstBox destination box of the piece.
     * @throws Exception Exception checkersTable getInstance() 
     */
    public void move(Box dstBox) throws Exception {
        boolean wizardEated = false; 

        Box srcBox = Boxes[pToMove.getCoord().x][pToMove.getCoord().y]; //this Box contain the piece to be moved
        int diff = srcBox.getCoord().x - dstBox.getCoord().x;

        if (diff > 1 || diff < -1){  //If have to eat difference is > 1 or < -1
            int i = (diff > 1) ? pToMove.getCoord().x - 1 : pToMove.getCoord().x + 1;
            int j = (srcBox.getCoord().y > dstBox.getCoord().y) ? pToMove.getCoord().y - 1 : pToMove.getCoord().y + 1;
            Box pToEatBox = Boxes[i][j];
            Piece enemyPiece = Boxes[i][j].getPiece();
            enemyPiece.getOwner().decreaseNpieces();
            checkGameEnd(enemyPiece);
            String enemyPieceClass = enemyPiece.getClass().getSimpleName();
            String pToMoveClass = pToMove.getClass().getSimpleName();

            addOrRemove(pToEatBox, false, pToMove);
            
            if (enemyPieceClass.equals("Wizard") && pToMoveClass.equals("Pawn")) //if pawn eat Wizard
                wizardEated = true; //Pawn will be a new checkers
            
            if ((enemyPieceClass.equals("Pawn") || enemyPieceClass.equals("Checkers")) && pToMoveClass.equals("Wizard")) //if Wizard eat
                respawn(pToEatBox); //add a new piece
            
            Player player = pToMove.getOwner();
            player.addPlayerPoints(enemyPiece.getPoints()); // increase player's score after eating
            panelInfo.updateScore(player);
        }


        pToMove.setCoord(dstBox.getCoord().x, dstBox.getCoord().y);
        Point pieceCoord = pToMove.getCoord();
      
        addOrRemove(srcBox, false, pToMove);  //remove the old piece from the previous Box

        if (canPieceUpgrade() || wizardEated){ //If pawn can upgrade
            Factory factory = new ConcreteFactoryM();
            pToMove = (Piece) factory.factoryMethod("checkers", pToMove.getColor(), pToMove.getOwner());
            pToMove.setCoord(pieceCoord.x, pieceCoord.y);
        }
        addOrRemove(dstBox, true, pToMove);
    }

    /**
     * Respawn a piece in the input box.
     * @param box box in which to insert the respawn piece.
     * @throws Exception
     */
    private void respawn(Box box) throws Exception{
        Factory factory = new ConcreteFactoryM();
        Piece piece = (Piece) factory.factoryMethod("pawn", pToMove.getColor(), pToMove.getOwner());
        pToMove.getOwner().increaseNpieces();
        addOrRemove(box, true, piece);
    }

    /**
     * highlights the boxes on which it is possible to move the selected piece.
     * @param row x coordinate of the box to be highlighted.
     * @param col y coordinate of the box to be highlighted.
     */
    public void showFreeBox(int row, int col){
        Color c = (pToMove.getColor().equals(Color.red)) ? Color.red : Color.green;
            Boxes[row][col].setColor(c);
            Boxes[row][col].repaint();
            pointsListToClear.add(new Point(row, col));
    }

    /**
     * Eliminates the highlighting of the boxes on which it is possible to move.
     */
    public void clearSuggestions(){
        for (Point pointToClear : pointsListToClear){
            Boxes[pointToClear.x][pointToClear.y].setColor(Color.darkGray);
            Boxes[pointToClear.x][pointToClear.y].repaint();
        }
        pointsListToClear.clear();
    }

    //true: adds a new piece - false: remove a piece
    /**
     * Add or remove piece from box
     * @param box box from which remove or add a piece.
     * @param action true if want add, false to remove a piece.
     * @param piece piece to remove or to add.
     */
    private void addOrRemove(Box box, boolean action, Piece piece){
        if(action == true){
            if (!piece.equals(pToMove)) {
                piece.setCoord(box.getCoord().x, box.getCoord().y);
            }
            box.add(piece, BorderLayout.CENTER);
        }
        else
            box.removeAll();
        box.HasPiece(action);
        box.revalidate();
        box.repaint();
    }

    /**
     * Return true if pawn can become a checker.
     * @return true if pawn can become a checker.
     */
    private boolean canPieceUpgrade(){
        String StrPiece = pToMove.getClass().getSimpleName();
        boolean isRedOnEnemyFstLine = pToMove.getColor() == Color.red && pToMove.getCoord().x == 0;
        boolean isGreenOnEnemyFstLine = pToMove.getColor() == Color.green && pToMove.getCoord().x == N_ROWS - 1;

        return StrPiece.equals("Pawn") && (isGreenOnEnemyFstLine || isRedOnEnemyFstLine);
    }

    /**
     * Check if you are moving out of bounds.
     * @param k index to check.
     * @return true if the move is illegal, false otherwise.
     */
    public boolean illegalMove(int k){
        return k >= N_ROWS || k < 0;
    }

    /**
     * Switch player turn.
     */
    public void switchTurn(){
        activePlayer = (activePlayer.equals(Color.red)) ? Color.green : Color.red;
        Player p = (activePlayer.equals(Color.red)) ? p1 : p2;
        panelInfo.switchTurn(p);
    }

    /**
     * Check if the game is over.
     * @param enemyPiece piece of the enemy eaten.
     */
    private void checkGameEnd(Piece enemyPiece){
        if (enemyPiece.getOwner().getNpieces() == 0){
            JOptionPane.showMessageDialog(null, "Game over! " + enemyPiece.getOwner().getPlayerName() + " lost.");
            returnToStart();
        }
    }

    /**
     * Determine the winner if the time runs out.
     * @param winner the winner of the game
     * @param obj null if the games is draw.
     */
    public void timeElapsed(Player winner, Object obj){
        if (obj != null)
            JOptionPane.showMessageDialog(null, "Time out! \n The games is draw");
        else
            JOptionPane.showMessageDialog(null, "Time out! \n The winner is " + winner.getPlayerName());
        returnToStart();
    }

    /**
     * Return to the initial checkersStart window.
     */
    public void returnToStart(){
        frame.dispose();
        Instance = null; // when another game is started, a new object must be instantiated to use the class constructor 
        Player.count_players = 0;
        CheckersStart CT = CheckersStart.getInstance();
        CT.getFrame().setVisible(true);
    }

    /**
     * Stop the timer.
     */
    public void stopTimer(){
        timer.stop();
    }

    /**
     * Reset the timer and return the game to the starting state.
     */
    @Override
    public  void reStartPanelInfo(){
        timer.reStartTimer();
        panelInfo.switchTurn(p1);
        activePlayer = p1.getPlayerColor();
        panelInfo.updateScore(p1);
        panelInfo.updateScore(p2);
        panelInfo.reSetNMOVE();
    }

    
    // Getters and Setters methods..
    /**
     * Return the player who can move his pieces.
     * @return the player who can move his pieces.
     */
    public Player getActivePlayer(){
        return (activePlayer.equals(Color.red)) ? p1 : p2;
    }

    /**
     * Return piece to move.
     * @return piece to move.
     */
    public Piece getPToMove() {
        return this.pToMove;
    }

    /**
     * Set piece to move.
     * @param pToMove piece to move
     */
    public void setPToMove(Piece pToMove) {
        this.pToMove = pToMove;
    }   
    /**
     * Return the game mode.
     * @return the game mode.
     */
    public boolean getRevisedChecker(){
        return revisedChecker;
    }

    /**
     * Return the list containing the suggestions to clean.
     * @return the list containing the suggestions to clean.
     */
    public ArrayList<Point> getPointsListToClear() {
        return this.pointsListToClear;
    }

    /**
     * Set the list containing the suggestions to clean.
     * @param pointsListToClear the list containing the suggestions to clean.
     */
    public void setPointsListToClear(ArrayList<Point> pointsListToClear) {
        this.pointsListToClear = pointsListToClear;
    }


}
