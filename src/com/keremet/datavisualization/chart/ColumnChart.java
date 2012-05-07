/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization.chart;

import com.keremet.datavisualization.Graph;
import com.keremet.datavisualization.Main;
import com.keremet.datavisualization.Series;
import com.keremet.datavisualization.Tooltip;
import java.util.HashMap;

/**
 *
 * @author Владелец
 */
public class ColumnChart extends Chart {

    float zeroPosition = 0;

    public ColumnChart(Main main, HashMap<String, String> attributes, Series[] series) {
        this.main = main;
        this.parameters = attributes;
        this.series = series;

        this.type = Chart.VERTICAL_CHART;
    }

    @Override
    public void draw(int frame, int framesCount) {

        main.pushStyle();

        boolean showValues = Graph.attributes.containsKey("showvalues") && Graph.attributes.get("showvalues").equals("1") ? true : false;

        main.noStroke();

        for (int j = 0; j < series.length; j++, Graph.chartNumber++) {

            if (!series[j].getVisible()) {
                continue;
            }

            main.fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));

            HashMap<String, Float> points = series[j].getPoints();
            float length = points.get("length");

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < length; i++) {
                float x = points.get(main.str(i) + ".x");
                float y = points.get(main.str(i) + ".y");
                float w = points.get(main.str(i) + ".width");
                float h = points.get(main.str(i) + ".height");

                h *= (float) frame / framesCount;

                main.rect(x, y, w, h);

                if (series[j].getActive()) {

                    if (series[j].getActiveValueIndex() == i) {

                        main.pushStyle();
                        main.fill(Graph.theme.getColorR(Graph.chartNumber) + 60, Graph.theme.getColorG(Graph.chartNumber) + 20, Graph.theme.getColorB(Graph.chartNumber) + 20);
                        main.rect(x, y, w, h);
                        main.popStyle();
                    }
                }

                if (showValues) {
                    main.fill(0);
                    main.textAlign(main.CENTER);
                    float x1 = w / 2 + x;
                    float y1 = y + h - 10;

                    float temp = series[j].getValues()[i];
                    String text = main.str(temp);

                    while (true) {
                        char c = text.charAt(text.length() - 1);
                        if (c == '0' || c == '.') {
                            text = text.substring(0, text.length() - 1);
                        } else {
                            break;
                        }
                        if (c == '.') {
                            break;
                        }
                    }

                    if (y1 - 15 <= Graph.layout.getY()) {
                        y1 = y + h + 20;
                    }

                    main.text(text, x1, y1);
                    main.fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));
                }

            }
            //Graph.chartNumber++;
        }

        main.stroke(0);

        main.popStyle();
    }

    public void preprocessing(HashMap<String, Float> layoutParameters) {

        float minY = layoutParameters.get("graph.preprocessing.minY");
        float maxY = layoutParameters.get("graph.preprocessing.maxY");

        float startY = layoutParameters.get("graph.preprocessing.startY");
        float endY = layoutParameters.get("graph.preprocessing.endY");

        float startX = layoutParameters.get("graph.preprocessing.startX");
        float endX = layoutParameters.get("graph.preprocessing.endX");

        zeroPosition = layoutParameters.get("graph.preprocessing.zero.position.y");

        float plotWidth = Graph.layout.getWidth() / (seriesLength()); // ширина одного участка для столбцов
        //float plotWidth = Graph.layout.get("graph.canvas.width") / (seriesLength()); // ширина одного участка для столбцов
        float spaceWidth = plotWidth / 10; //10% от plotWidth
        float columnWidth = 0; // ширина одного столбца =)                
        float addX = 0;
        HashMap<String, Float> points = new HashMap<String, Float>();

        int seriesQty = 0;

        for (int i = 0; i < series.length; i++) {
            if (series[i].getVisible()) {
                seriesQty++;
            }
        }
        
        columnWidth = (plotWidth - (2 * spaceWidth)) / seriesQty;
        
        float space = plotWidth/80;
        
        for (int i = 0; i < series.length; i++) {

            if (!series[i].getVisible()) {
                continue;
            }

            float[] values = series[i].getValues();

            for (int j = 0; j < values.length; j++) {
                float y = main.map(values[j], minY, maxY, startY, endY);
                float x = main.map(j, 0, values.length, startX, endX);

                x += addX + spaceWidth;

                points.put(main.str(j) + ".x", x + space);
                points.put(main.str(j) + ".width", (float) columnWidth - (2 * space));

                if (y != zeroPosition) {
                    points.put(main.str(j) + ".y", y > zeroPosition ? zeroPosition + 1 : zeroPosition - 2);
                    points.put(main.str(j) + ".height", y > zeroPosition ? y - zeroPosition - 1 : y - zeroPosition + 2);
                } else {
                    points.put(main.str(j) + ".y", zeroPosition);
                    points.put(main.str(j) + ".height", y - zeroPosition);
                }

                points.put(main.str(j) + ".height", y > zeroPosition ? y - zeroPosition - 1 : y - zeroPosition + 2);
            } // цикл k 

            points.put("length", (float) values.length);

            series[i].setPoints(points);

            addX += columnWidth;
        }
    }

    public void invertY() {

        zeroPosition = Graph.layout.getHeight() - zeroPosition + 2 * Graph.layout.getY();

        float temp = Graph.layout.getY() + Graph.layout.getHeight();

        for (int j = 0; j < series.length; j++) {

            if (!series[j].getVisible()) {
                continue;
            }

            HashMap<String, Float> points = series[j].getPoints();
            float length = points.get("length");

            for (int i = 0; i < length; i++) {
                float y = points.get(main.str(i) + ".y");
                float h = points.get(main.str(i) + ".height");
                if (h < 0) {
                    points.put(main.str(i) + ".y", Graph.layout.getHeight() - y + 2 * Graph.layout.getY());
                    points.put(main.str(i) + ".height", -h);
                } else {
                    points.put(main.str(i) + ".y", Graph.layout.getHeight() - y + 2 * Graph.layout.getY());
                    points.put(main.str(i) + ".height", -h);
                }

            }
            series[j].setPoints(points);
        }
    }

    public Tooltip getTooltip(int mouseX, int mouseY) {

        float colX = 0, colY = 0, colWidth = 0;
        String text = new String();

        for (int j = 0; j < series.length; j++) {
            if (!series[j].getVisible()) {
                continue;
            }
            HashMap<String, Float> points = series[j].getPoints();

            float length = points.get("length");

            boolean flag = false;

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < length; i++) {
                float x = points.get(main.str(i) + ".x");
                float y = points.get(main.str(i) + ".y");
                float width_ = points.get(main.str(i) + ".width");
                float height_ = points.get(main.str(i) + ".height");

                if (height_ < 0) {
                    y += height_;
                    height_ = -height_;
                }

                if (x <= mouseX && mouseX <= x + width_ && y <= mouseY && mouseY <= y + height_) {

                    //делаем неактивной серию
                    Graph.activeSeries.setActive(false);
                    //делаем ссылку на активную серию
                    Graph.activeSeries = series[j];

                    Graph.activeSeries.setActive(true);

                    Graph.activeSeries.setActiveValueIndex(i);

                    Graph.activeChart = this;

                    colX = x;
                    colY = y;
                    colWidth = width_;
                    text = series[j].getAttribute("name") + ", " + Graph.labels[i] + ": " + series[j].getValues()[i];
                    flag = true;
                    break;
                }
            }

            if (flag) {
                break;
            }
        }
        //if ()

        if (colX == 0 && colY == 0) {
            return null;
        } else {
            return new Tooltip(main, text, colX, colY, colWidth);
        }
    }
}
