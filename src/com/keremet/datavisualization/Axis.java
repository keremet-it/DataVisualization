/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

import java.util.HashMap;

/**
 * Represents an axis of a graph. 
 * @author Владелец
 */
public class Axis {

    Main main;
    /**
     * 
     */
    public Layout layout;
    Series series;
    HashMap<String, String> parameters;
    String[] labels;
    String orientation, title;
    float pp = 0, canvasWidth = 0;

    /**
     * 
     * @param main 
     * @param orientation
     * @param labels
     */
    public Axis(Main main, String orientation, String[] labels) {
        this.main = main;
        this.parameters = null;
        this.series = null;
        this.labels = labels;
        this.orientation = orientation.toLowerCase();
        this.title = "";
    }

    public Axis(Main main, String orientation, float[] labels) {
        this.main = main;
        this.parameters = null;
        this.series = null;
        this.labels = new String[labels.length];
        for (int i = 0; i < labels.length; i++) {
            this.labels[i] = main.str(labels[i]);
        }
        this.orientation = orientation.toLowerCase();
        this.title = "";
    }
    
    /**
     * Set layout of Axis
     * @param layout Layout of Axis
     */
    public void setLayout(Layout layout) {
        this.layout = layout;
    }

    /**
     * 
     */
    public void draw() {

        main.pushMatrix();
        main.pushStyle();

        main.textSize(Graph.theme.get("axis.textsize"));

        if (orientation.equals("y")) {
            drawY();
        } else {
            drawX();
        }

        main.popMatrix();
        main.popStyle();
    }
    
    /**
     * Draw X-oriented Axis
     */
    
    private void drawX() {
        HashMap<String, Float> points = (HashMap<String, Float>) (series.getPoints()).clone();
        float length = points.get("length");
        main.stroke(125);

        main.textAlign(main.CENTER);

        float zoomCoeficient = Graph.zoomCoeficient;

        for (int i = 0; i < length; i++) {
            float x1 = points.get(main.str(i) + ".x") - Graph.layout.getX();
            x1 *= zoomCoeficient;
            x1 += Graph.layout.getX();
            x1 -= Graph.currentPosition;
            points.put(main.str(i) + ".x", x1);
        }

        float xMax = Graph.layout.getX() + Graph.layout.getWidth();
        float xMin = Graph.layout.getX();

        float delimeter = 1;

        if (Graph.attributes.containsKey("zoom") && Graph.attributes.get("zoom").equals("1")) {
            float textWidthAverage = 0;

            for (int i = 0; i < labels.length; i++) {
                textWidthAverage += Graph.textWidth(labels[i]);
            }

            textWidthAverage /= labels.length - 1;
            float colWidth = layout.getWidth() * Graph.zoomCoeficient / labels.length;

            while (delimeter * colWidth / textWidthAverage < 2) {
                delimeter *= 2;
            }
        }

        float addY = (main.width * main.height / Graph.averageAreaSize);

        //draw lines
        for (int i = 0; i < length; i++) {

            float x = points.get(main.str(i) + ".x");
            if (x > xMax) {
                break;
            } else if (x < xMin) {
                continue;
            }
            float y = points.get(main.str(i) + ".y");

            main.line(x, y, x, y + 5 + addY);
        }

        addY = 5 + addY + Graph.theme.get("axis.textsize");
        
        //draw lables
        for (int i = 0; i < labels.length; i += delimeter) {
            float x = points.get(main.str(i) + ".x");
            if (x > xMax) {
                break;
            } else if (x < xMin) {
                continue;
            }
            float y = points.get(main.str(i) + ".y");

            /*
            main.pushMatrix();
            main.translate(x + pp, y + 15);
            main.rotate(-main.PI/2);
            main.textAlign(main.CENTER);
            
            main.text(labels[i], 0, 0);
            
            main.textAlign(main.LEFT);
            main.popMatrix();
             * 
             */

            main.text(labels[i], x + pp, y + addY );

        }

        addY += Graph.theme.get("axis.textsize")+10;
        
        { // вычисление координат расположения надписи оси X
            float x = layout.getX();
            float y = layout.getY();
            float axisWidth = layout.getWidth();
            float axisHeight = layout.getHeight();

            float posX = x + axisWidth / 2;
            float posY = y + axisHeight / 2;

            main.textAlign(main.CENTER);
            main.text(title, posX, layout.getY() + addY);
            main.textAlign(main.LEFT);
        }

        main.stroke(0);
    }
    
    /**
     * Draw Y-oriented Axis
     */
    
    private void drawY() {
        HashMap<String, Float> points = series.getPoints();
        float length = points.get("length");
        main.stroke(125);
        main.strokeWeight(1);
        main.textAlign(main.RIGHT);

        //draw lines
        for (int i = 0; i < length; i++) {
            float x = points.get(main.str(i) + ".x");
            float y = points.get(main.str(i) + ".y");

            main.line(x - 5, y, x + canvasWidth, y);
        }
        
        float maxTextWidth = 0;
        
        //draw lables
        for (int i = 0; i < labels.length; i++) {
            float x = points.get(main.str(i) + ".x");
            float y = points.get(main.str(i) + ".y");

            main.text(labels[i], x - 10, y + 5);
            
            maxTextWidth = Graph.textWidth(labels[i]) > maxTextWidth? Graph.textWidth(labels[i]) : maxTextWidth;
        }
        
        { // вычисление координат расположения надписи оси X
            float x = layout.getX() + layout.getWidth() - maxTextWidth - 20;
            float y = layout.getY();
            float axisHeight = layout.getHeight();
//            float x = Graph.layout.get("graph.yaxis.position.x");
//            float y = Graph.layout.get("graph.yaxis.position.y");
//            float axisWidth = Graph.layout.get("graph.yaxis.width");
//            float axisHeight = Graph.layout.get("graph.yaxis.height"0);

            //float posX = x - ;    
            float posY = y + axisHeight / 2;

            main.pushMatrix();
            main.translate(x, posY);
            main.rotate(-main.PI / 2);
            main.textAlign(main.CENTER);

            main.text(title, 0, 0);

            main.textAlign(main.LEFT);
            main.popMatrix();
        }

        main.stroke(0);
    }

    /**
     * Preprocessing
     * @param layoutParameters data containing the characteristics of the canvas, such as height, width, etc.
     */
    public void preprocessing(HashMap<String, Float> layoutParameters) {
        if (orientation.equals("y")) {
            preprocessingY(layoutParameters);
        } else {
            preprocessingX(layoutParameters);
        }
    }
    /**
     * Calculate data for X-oriented Axis and save data to series
     * @param layoutParameters data containing the characteristics of the canvas, such as height, width, etc.
     */
    private void preprocessingX(HashMap<String, Float> layoutParameters) {

        float minX = layoutParameters.get("graph.preprocessing.minX");
        float maxX = layoutParameters.get("graph.preprocessing.maxX");

        float delimeter = layoutParameters.get("graph.preprocessing.delimeter.x");

        float startY = layout.getY();
        float endY = startY + layout.getHeight();
        float startX = layout.getX();
        float endX = startX + layout.getWidth();

        //float startY = Graph.layout.get("graph.xaxis.position.y");
        //float endY = Graph.layout.get("graph.xaxis.position.y") + Graph.layout.get("graph.xaxis.height");
        //float startX = Graph.layout.get("graph.xaxis.position.x");
        //float endX = Graph.layout.get("graph.xaxis.position.x") + Graph.layout.get("graph.xaxis.width");

        pp = layoutParameters.get("graph.preprocessing.canvasInnerSpaceWidth");

        HashMap<String, Float> points = new HashMap<String, Float>();

        for (float i = minX, j = 0; i <= maxX; i += delimeter, j++) {
            float t = main.map(i, minX, maxX, startX, endX);

            points.put(main.str((int) j) + ".x", t);
            points.put(main.str((int) j) + ".y", startY);
        }
        points.put("length", (float) (maxX / delimeter + 1));

        series = new Series();
        series.setPoints(points);
    }
    
    /*
     * Calculate data for Y-oriented Axis and save data to series
     */
    private void preprocessingY(HashMap<String, Float> extendedParameters) {

        float minY = extendedParameters.get("graph.preprocessing.minY");
        float maxY = extendedParameters.get("graph.preprocessing.maxY");

        float delimeter = extendedParameters.get("graph.preprocessing.delimeter.y");

        float startY = layout.getY();
        float endY = startY + layout.getHeight();
        float startX = layout.getX();
        float endX = startX + layout.getWidth();

        //canvasWidth = Graph.layout.get("graph.canvas.width");2222222 здесь ошибка
        canvasWidth = Graph.layout.getWidth();

        HashMap<String, Float> points = new HashMap<String, Float>();

        labels = new String[(int) ((maxY - minY) / delimeter) + 1];

        for (float i = minY, j = 0; i <= maxY; i += delimeter, j++) {
            float t = main.map(i, minY, maxY, startY, endY);

            points.put(main.str((int) j) + ".x", endX);
            points.put(main.str((int) j) + ".y", t);

            labels[(int) j] = main.str(i);
        }

        for (int i = 0; i < labels.length / 2; i++) {
            String temp = labels[i];
            labels[i] = labels[labels.length - i - 1];
            labels[labels.length - i - 1] = temp;
        }

        points.put("length", (float) ((maxY - minY) / delimeter + 1));
        series = new Series();
        series.setPoints(points);
    }
    
    /*
     * Return labels of Axis
     */
    /**
     * 
     * @return
     */
    public String[] getLabels() {
        return labels;
    }
    /*
     * Set title of Axis
     */
    /**
     * 
     * @param title
     */
    public void setTitle(String title) {
        this.title = title;
        if (this.title == null) this.title = "";
    }
}
