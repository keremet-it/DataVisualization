/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization.chart;

import com.keremet.datavisualization.Graph;
import com.keremet.datavisualization.Main;
import com.keremet.datavisualization.Series;
import com.keremet.datavisualization.Tooltip;
import com.keremet.datavisualization.interfaces.Zoomable;
import java.util.ArrayList;
import java.util.HashMap;
import processing.core.PGraphics;

/**
 *
 * @author Владелец
 */
public class AreaChart extends Chart implements Zoomable {

    float zeroPosition = 0;
    private float smooth_value = (float) 0;
    float transparent = (float) 0.5;

    public AreaChart(Main main, HashMap<String, String> attributes, Series[] series) {
        this.main = main;
        this.parameters = attributes; // атрибуты входят в параметры.
        this.series = series;

        this.type = Chart.VERTICAL_CHART;

        if (parameters.containsKey("isspline")) {
            if (parameters.get("isspline").equals("1")) {
                smooth_value = (float) 0.8;
            }
        }
    }

    public void draw(int frame, int framesCount) {
        boolean showValues = Graph.attributes.containsKey("showvalues") && Graph.attributes.get("showvalues").equals("1") ? true : false;

        float zoomCoeficient = Graph.zoomCoeficient;

        float xLimit = Graph.layout.getX() + (Graph.layout.getWidth() / framesCount * frame);

        main.strokeWeight(2);
        float xMax = Graph.layout.getX() + Graph.layout.getWidth();
        float xMin = Graph.layout.getX();

        for (int j = 0; j < series.length; j++, Graph.chartNumber++) {

            if (!series[j].getVisible()) {
                continue;
            }

            HashMap<String, Float> points = (HashMap<String, Float>) (series[j].getPoints()).clone();

            float size = points.get("length");

            for (int i = 0; i < size; i++) {
                float x1 = points.get(main.str(i) + ".x") - Graph.layout.getX();
                x1 *= zoomCoeficient;
                x1 += Graph.layout.getX();
                x1 -= Graph.currentPosition;
                points.put(main.str(i) + ".x", x1);
            }
            float shapeMaxX = -1, shapeMinX = 10000000;
            main.fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber), 200);
            main.noStroke();
            main.beginShape();

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < size - 1; i++) {

                float x1 = points.get(main.str(i) + ".x");
                float y1 = points.get(main.str(i) + ".y");

                float x0 = i > 0 ? points.get(main.str(i - 1) + ".x") : x1;
                float y0 = i > 0 ? points.get(main.str(i - 1) + ".y") : y1;

                float x2 = points.get(main.str(i + 1) + ".x");
                float y2 = points.get(main.str(i + 1) + ".y");

                float x3 = i < size - 2 ? points.get(main.str(i + 2) + ".x") : x2;
                float y3 = i < size - 2 ? points.get(main.str(i + 2) + ".y") : y2;

                ArrayList<Point> controlPoints = getControlPoints(new Point(x0, y0), new Point(x1, y1), new Point(x2, y2), new Point(x3, y3), smooth_value);

                Point p1 = new Point(x1, y1);
                Point p2 = controlPoints.get(0);
                Point p3 = controlPoints.get(1);
                Point p4 = new Point(x2, y2);

                //main.fill(0, 2 * ((j + 1) * 30), ((j * 4 + 1) * 30), 200);
                //main.stroke(0, 0, 0, 0);

                int steps = 60;

                boolean flag = false;

                for (int k = 0; k < steps; k++) {
                    float x = main.bezierPoint(p1.getX(), p2.getX(), p3.getX(), p4.getX(), (float) k / steps);

                    if (x > xMax || x > xLimit) {
                        flag = true;
                        break;
                    } else if (x < xMin) {
                        continue;
                    }
                    float y = main.bezierPoint(p1.getY(), p2.getY(), p3.getY(), p4.getY(), (float) k / steps);

                    main.vertex(x, y);

                    shapeMaxX = x > shapeMaxX ? x : shapeMaxX;
                    shapeMinX = x < shapeMinX ? x : shapeMinX;

                }
                if (xMin <=p4.getX() && p4.getX() <= xMax && p4.getX() <= xLimit) {
                    main.vertex(p4.getX(), p4.getY());

                    shapeMaxX = p4.getX() > shapeMaxX ? p4.getX() : shapeMaxX;
                    shapeMinX = p4.getX() < shapeMinX ? p4.getX() : shapeMinX;
                }
                if (flag) {
                    break;
                }

                //main.fill(0);
                main.textAlign(main.CENTER);
                if (xMin <= x1 && x1 <= xMax) {

                    if (series[j].getActive()) {
                        if (series[j].getActiveValueIndex() == i) {
                            main.ellipse(x1, y1, 12, 12);
                        }
                    }

                    if (showValues) {
                        float temp = series[j].getValues()[i];
                        String labelText = main.str(temp);

                        while (true) {
                            char c = labelText.charAt(labelText.length() - 1);
                            if (c == '0' || c == '.') {
                                labelText = labelText.substring(0, labelText.length() - 1);
                            } else {
                                break;
                            }
                            if (c == '.') {
                                break;
                            }
                        }

                        main.text(labelText, x1, y1 - 10);
                    }
                }
                //main.fill(0, 0, 0, 0);

            }

            if (shapeMaxX != -1 && shapeMinX != 10000000) {

                main.vertex(shapeMaxX, zeroPosition);
                main.vertex(shapeMinX, zeroPosition);
            }


            main.endShape();
        }

        main.strokeWeight(1);

    }

    public ArrayList<Point> getControlPoints(Point p0, Point p1, Point p2, Point p3, float smooth_value) {
        float x0 = p0.getX(), y0 = p0.getY(), x1 = p1.getX(), y1 = p1.getY(), x2 = p2.getX(), y2 = p2.getY(), x3 = p3.getX(), y3 = p3.getY();

        float xc1 = (float) ((x0 + x1) / 2.0);
        float yc1 = (float) ((y0 + y1) / 2.0);
        float xc2 = (float) ((x1 + x2) / 2.0);
        float yc2 = (float) ((y1 + y2) / 2.0);
        float xc3 = (float) ((x2 + x3) / 2.0);
        float yc3 = (float) ((y2 + y3) / 2.0);

        float len1 = (float) Math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
        float len2 = (float) Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
        float len3 = (float) Math.sqrt((x3 - x2) * (x3 - x2) + (y3 - y2) * (y3 - y2));

        float k1 = len1 / (len1 + len2);
        float k2 = len2 / (len2 + len3);

        float xm1 = xc1 + (xc2 - xc1) * k1;
        float ym1 = yc1 + (yc2 - yc1) * k1;

        float xm2 = xc2 + (xc3 - xc2) * k2;
        float ym2 = yc2 + (yc3 - yc2) * k2;

        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;

        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;

        ArrayList<Point> ans = new ArrayList<Point>();

        ans.add(new Point(ctrl1_x, ctrl1_y));
        ans.add(new Point(ctrl2_x, ctrl2_y));

        return ans;
    }

    public void preprocessing(HashMap<String, Float> layoutParameters) {

        float minY = layoutParameters.get("graph.preprocessing.minY");
        float maxY = layoutParameters.get("graph.preprocessing.maxY");

        float startY = layoutParameters.get("graph.preprocessing.startY");
        float endY = layoutParameters.get("graph.preprocessing.endY");

        float startX = layoutParameters.get("graph.preprocessing.startX");
        float endX = layoutParameters.get("graph.preprocessing.endX");

        zeroPosition = Graph.layout.getHeight() - layoutParameters.get("graph.preprocessing.zero.position.y") + 2 * Graph.layout.getY();

        float canvasInnerSpaceWidth = layoutParameters.get("graph.preprocessing.canvasInnerSpaceWidth");

        for (int i = 0; i < series.length; i++) { // по каждой серии графика

            if (!series[i].getVisible()) {
                continue;
            }

            float[] values = series[i].getValues(); //получаем значения

            float tY = 0, tX = 0;
            int tJ = 0;

            HashMap<String, Float> points = new HashMap<String, Float>(); // соббстно, приближаемся к кульминации действа
            for (int j = 0; j < values.length; j++) {

                float y = main.map(values[j], minY, maxY, startY, endY);
                float x = main.map(j, 0, values.length - 1, startX + canvasInnerSpaceWidth, endX - canvasInnerSpaceWidth);

                points.put(main.str(j) + ".x", x);
                points.put(main.str(j) + ".y", y);

                tY = y;
                tX = x;
                tJ = j + 1;
            } // цикл k 

            points.put(main.str(tJ) + ".x", tX);
            points.put(main.str(tJ) + ".y", tY);

            points.put("length", (float) values.length + 1);

            series[i].setPoints(points);
        }// цикл j         
    }

    public void invertY() {
        //float captionHeight = Graph.resources.containsKey("caption")? Graph.theme.get("caption.textsize") + 15 : 0;
        //float marginTop = Graph.theme.get("margin.top") + captionHeight;
        float marginTop = Graph.layout.getY();
        float canvasHeight = Graph.layout.getHeight();

        for (int j = 0; j < series.length; j++) {

            if (!series[j].getVisible()) {
                continue;
            }

            HashMap<String, Float> points = series[j].getPoints();
            float length = points.get("length");

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < length; i++) {
                float y = points.get(main.str(i) + ".y") - marginTop;
                y = canvasHeight - y + marginTop;
                points.put(main.str(i) + ".y", y);
            }

            series[j].setPoints(points);
        }
    }

    public boolean getValueByCursor(float mouseX, float mouseY) {
        return false;
    }

    public Tooltip getTooltip(int mouseX, int mouseY) {
        float pointX = 0, pointY = 0;
        String text = new String();

        //minimal space between cursor and spline

        float zoomCoeficient = Graph.zoomCoeficient;

        float xMax = Graph.layout.getX() + Graph.layout.getWidth();
        float xMin = Graph.layout.getX();

        for (int j = 0; j < series.length; j++) {

            if (!series[j].getVisible()) {
                continue;
            }

            HashMap<String, Float> points = (HashMap<String, Float>) (series[j].getPoints()).clone();

            float size = points.get("length");

            for (int i = 0; i < size; i++) {
                float x1 = points.get(main.str(i) + ".x") - Graph.layout.getX();
                x1 *= zoomCoeficient;
                x1 += Graph.layout.getX();
                x1 -= Graph.currentPosition;
                points.put(main.str(i) + ".x", x1);
            }

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < size - 1; i++) {

                float x1 = points.get(main.str(i) + ".x");
                float y1 = points.get(main.str(i) + ".y");

                float x0 = i > 0 ? points.get(main.str(i - 1) + ".x") : x1;
                float y0 = i > 0 ? points.get(main.str(i - 1) + ".y") : y1;

                float x2 = points.get(main.str(i + 1) + ".x");
                float y2 = points.get(main.str(i + 1) + ".y");

                float x3 = i < size - 2 ? points.get(main.str(i + 2) + ".x") : x2;
                float y3 = i < size - 2 ? points.get(main.str(i + 2) + ".y") : y2;

                ArrayList<Point> controlPoints = getControlPoints(new Point(x0, y0), new Point(x1, y1), new Point(x2, y2), new Point(x3, y3), smooth_value);

                Point p1 = new Point(x1, y1);
                Point p2 = controlPoints.get(0);
                Point p3 = controlPoints.get(1);
                Point p4 = new Point(x2, y2);

                int steps = 20;

                for (int k = 0; k < steps; k++) {
                    float x = main.bezierPoint(p1.getX(), p2.getX(), p3.getX(), p4.getX(), (float) k / steps);
                    if (x > xMax) {
                        break;
                    } else if (x < xMin) {
                        continue;
                    }
                    float y = main.bezierPoint(p1.getY(), p2.getY(), p3.getY(), p4.getY(), (float) k / steps);

                    if (Math.pow(mouseX - x, 2) + Math.pow(mouseY - y, 2) < Graph.minDif) {

                        Graph.minDif = (float) (Math.pow(mouseX - x, 2) + Math.pow(mouseY - y, 2));

                        //делаем неактивной серию
                        Graph.activeSeries.setActive(false);
                        //делаем ссылку на активную серию
                        Graph.activeSeries = series[j];

                        Graph.activeSeries.setActive(true);

                        Graph.activeChart = this;

                        if (Math.abs(x1 - mouseX) <= Math.abs(x2 - mouseX)) {
                            Graph.activeSeries.setActiveValueIndex(i);
                            pointX = x1;
                            pointY = y1;

                            text = series[j].getAttribute("name") + ", " + Graph.labels[i] + ": " + series[j].getValues()[i];
                        } else {
                            Graph.activeSeries.setActiveValueIndex(i + 1);
                            pointX = x2;
                            pointY = y2;
                            text = series[j].getAttribute("name") + ", " + Graph.labels[i + 1] + ": " + series[j].getValues()[i + 1];
                        }
                    }
                }
            }
        }

        if (pointX == 0 && pointY == 0) {
            return null;
        } else {
            return new Tooltip(main, text, pointX, pointY);
        }
    }

    public void zoom(float coeficient) {
    }

    public Tooltip switchActiveValueIndex(float mouseX, float mouseY) {
        float pointX = 0, pointY = 0;
        String text = new String();

        float minDif = Graph.layout.getWidth() + Graph.layout.getX();

        for (int j = 0; j < series.length; j++) {
            if (series[j].getActive() && series[j].getVisible()) {

                HashMap<String, Float> points = (HashMap<String, Float>) (series[j].getPoints()).clone();
                float size = points.get("length");

                //вытаскиваем данные и рисуем. все просто!       
                for (int i = 0; i < size - 1; i++) {

                    float x1 = points.get(main.str(i) + ".x");
                    float y1 = points.get(main.str(i) + ".y");

                    if (Math.abs(x1 - mouseX) <= minDif) {
                        Graph.activeSeries.setActiveValueIndex(i);
                        pointX = x1;
                        pointY = y1;

                        text = series[j].getAttribute("name") + ", " + Graph.labels[i] + ": " + series[j].getValues()[i];

                        series[j].setActiveValueIndex(i);

                        minDif = Math.abs(x1 - mouseX);
                    }
                }
                return new Tooltip(main, text, pointX, pointY);
            }
        }
        return null;
    }
}
