/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

/**
 *
 * @author Владелец
 */
public class ScrollBar {
    
    Main main;
    Layout layout;
    
    float runnerWidth = 0, runnerX = 0;
    float dragPosition = 0;
    public ScrollBar(Main main) {
        this.main = main;
    }
    
    public void setLayout(Layout layout) {
        this.layout = layout;
    }
    
    public void draw() {
        main.noStroke();
        main.fill(0,100,200,100);
        main.rect(layout.getX(), layout.getY(), layout.getWidth(), layout.getHeight());
        
        float left = Graph.currentPosition / Graph.zoomCoeficient;
        float right = (Graph.currentPosition + Graph.layout.getWidth()) / Graph.zoomCoeficient;
        
        runnerX = layout.getX() + left;
        runnerWidth = right - left;
        
        main.fill(0,100,200);
        main.rect(layout.getX()+ left, layout.getY(), right - left, layout.getHeight());
        main.stroke(1);
    }
    
    public float getRunnerX() {
        return runnerX;
    }
    
    public float getRunnerWidth() {
        return runnerWidth;
    }
    
    public void setDragPosition() {
        dragPosition = runnerX;
    }
    
    public float getDragPosition() {
        return dragPosition;
    }
}
