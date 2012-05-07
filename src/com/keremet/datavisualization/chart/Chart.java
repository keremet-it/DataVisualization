/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization.chart;

import com.keremet.datavisualization.Graph;
import com.keremet.datavisualization.Layout;
import com.keremet.datavisualization.interfaces.Drawable;
import com.keremet.datavisualization.Main;
import com.keremet.datavisualization.Series;
import java.util.HashMap;

/**
 *
 * @author Владелец
 */
public abstract class Chart implements Drawable {

    Main main;
    Layout layout;
    public static final int RADIAL_CHART = 0, VERTICAL_CHART = 1, HORIZONTAL_CHART = 2;
    public Series[] series;
    public HashMap<String, String> parameters;
    public int type = 0;

    public void setLayout(Layout layout) {
        this.layout = layout;
    }

    public int getType() {
        return type;
    }

    //количество серий
    public int seriesQty() {
        return series.length;
    }

    //длина серий
    public int seriesLength() {
        return series[series.length - 1].getValues().length;
    }

    //получить i-ую серию
    public Series getSeries(int i) {
        return series[i];
    }

    //задать i-ую серию
    public void setSeries(int i, Series s) {
        series[i] = s;
    }

    //задать точки i-го графика
    public void setPoints(int i, HashMap<String, Float> points) {
        series[i].setPoints(points);
    }

    //получить атрибуты чарта
    public HashMap<String, String> getParameters() {
        return parameters;
    }

    public String getParameter(String key) {
        return parameters.get(key);
    }

    protected void drawTooltip(float x, float y, float width, float height, String labelText) {
        main.textAlign(main.LEFT);
        main.fill(255, 255, 255);

        main.stroke(0);
        main.rect(x, y, width, height);
        main.fill(0);
        main.text(labelText, x + 10, y + Graph.theme.get("tooltip.textsize") + 5);
    }
}