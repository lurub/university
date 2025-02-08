package Game.GameObjects.Pieces;
import java.awt.*;

import Game.GameObjects.Players.NPlayerExceededException;
import Game.GameObjects.Players.Player;
import Game.GraphicObjects.Table.IstanceException;
/**
 * <h1>Pawn Class</h1> 
 * This class represents the pawn object and encapsulates its movement logic.
 * @author <a href="https://github.com/Luruu">Luca Rubino</a>
 * @author <a href="https://github.com/RenatoEsposito1999">Renato Esposito</a>
 * @version 1.0
 * @since 31-08-2021
 */
public class Pawn extends Piece{
    public final static int PAWN_POINTS = 1;
    public final static String PAWGREEN_Path    = "/images/PawnGreen.png";
    public final static String PAWRED_Path      = "/images/PawnRed.png";

/**
 * @param c the color of the pawn piece.
 * @param p the owner player who has the ability to move the piece.
 * @throws IstanceException Exception
 * @throws NPlayerExceededException Exception
 */
    public Pawn(Color c, Player p) throws NPlayerExceededException, IstanceException{
        super(c, PAWN_POINTS, p);
    }

/**
 * This method determines the possible movements of the checker piece.
 * @param direction the direction of the boxes to be analyzed.
 * @return 0: //It's useless but necessary because of override.
 */
    @Override
    public int showSuggestions(int direction){
        super.showSuggestions(direction);
        return 0;
    }
    
/**
 * This method determines the path of the image to be drawn on the game table.
 * @return the path of the image to be drawn on the game table.
 */
    @Override
    public String getPathIMG(){
        return (getColor() == Color.red) ? PAWRED_Path : PAWGREEN_Path ;
    }
}
