package Game.Image;

import java.awt.*;
import java.io.File;
import java.io.IOException;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
/**
 * <h1>ImageFunctions Interface</h1>
 * Interface that contains all methods to manage images.
 */
public interface ImageFunctions {

       public static BufferedImage readFile(String pathRelative){
        String absPath = getAbsolutePath(pathRelative);
        BufferedImage img = null;
        try {
            img = ImageIO.read(new File(absPath));
        } catch (IOException ex) {
            System.out.println("ERROR: " + ex.getMessage() + " pathimg: " + "\"" + absPath + "\"");
        }
        return img;
    }
    
    /**
     * this method is necessary to access file on the file system.
     * @param pathRelative path to convert to AbsolutePath
     * @return absolute path string
     */
    static String getAbsolutePath(String pathRelative){
        String filePath = new File("").getAbsolutePath();
        return filePath.concat(pathRelative);
    }

    /**
     * This method scales the image to the desired size.
     * @return BufferedImage scaled
     * @param imgIn BufferedImage input
     * @param wid width BufferedImage scaled oputput 
     * @param hei height BufferedImage scaled oputput 
     * @see #scale(String pathAbs, int wid, int hei)
     */
    static BufferedImage scale(BufferedImage imgIn, int wid, int hei) {
        if (imgIn == null)
            return null;

        BufferedImage imgOut = new BufferedImage(wid, hei, imgIn.getType());
        Graphics2D g2D = imgOut.createGraphics();

        g2D.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2D.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g2D.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        g2D.drawImage(imgIn, 0, 0, wid, hei, null);
        g2D.dispose();
        return imgOut;
    } 

    /**
     * This method scales the image to the desired size.
     * @return BufferedImage scaled
     * @param pathAbs path of input BufferedImage 
     * @param wid width BufferedImage scaled oputput 
     * @param hei height BufferedImage scaled oputput 
     * @see #scale(BufferedImage imgIn, int wid, int hei)
     */
    static BufferedImage scale(String pathAbs, int wid, int hei) {
        BufferedImage imgIn = readFile(pathAbs);
        return scale(imgIn,wid,hei);
    }
}
