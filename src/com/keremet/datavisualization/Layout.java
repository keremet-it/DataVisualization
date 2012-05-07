/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

/**
 *
 * @author Владелец
 */
public class Layout {
    private float X, Y, WIDTH, HEIGHT;
    
    public Layout(float X, float Y, float WIDTH, float HEIGHT) {
        this.X = X;
        this.Y = Y;
        this.WIDTH = WIDTH;
        this.HEIGHT = HEIGHT;
    }
    
    public Layout() {
        this.X = 0;
        this.Y = 0;
        this.WIDTH = 0;
        this.HEIGHT = 0;
    }
    
    public float getX() {
        return X;
    }
    
    public float getY() {
        return Y;
    }
    
    public float getWidth() {
        return WIDTH;
    }
    
    public float getHeight() {
        return HEIGHT;
    }

    public void setX(float X) {
        this.X = X;
    }

    public void setY(float Y) {
        this.Y = Y;
    }

    public void setWidth(float WIDTH) {
        this.WIDTH = WIDTH;
    }

    public void setHeight(float HEIGHT) {
        this.HEIGHT = HEIGHT;
    }
    
    boolean isInside(float x, float y) {
        return (X <= x && x <= X + WIDTH && Y <= y && y <= Y + HEIGHT);
    }
}