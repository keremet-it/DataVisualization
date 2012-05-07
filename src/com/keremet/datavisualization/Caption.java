package com.keremet.datavisualization;

/**
 * Class Caption represents text at the top of canvas. Used in {@see Graph}
 * @author akanurlan
 * @param main PApplet which provides drawing
 */
public class Caption {
    Main main;
    Layout layout;
    String captionText;
    
    
    /**
     * Create Caption 
     * @param main PApplet which provides drawing
     * @param captionText Caption text
     */
    public Caption(Main main, String captionText) {
        this.main = main;
        this.captionText = captionText;
    }
    
    /**
     * Set layout which provides space for drawing
     * @param layout
     */
    public void setLayout(Layout layout) {
        this.layout = layout;
    }
    
    /**
     * Draw caption text
     */
    public void draw() {
        float x = layout.getX() + (layout.getWidth()/2);
        float y = layout.getY() + (layout.getHeight()/2) + (Graph.theme.get("caption.textsize")/3);
        main.pushMatrix();
        main.pushStyle();
        
        main.textAlign(main.CENTER);
        main.textSize(Graph.theme.get("caption.textsize"));
        
        main.text(captionText, x, y);

        main.popStyle();
        main.popMatrix();        
    }
}
