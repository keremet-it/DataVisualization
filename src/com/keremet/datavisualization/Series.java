/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

import java.util.ArrayList;
import java.util.HashMap;

/**
 *
 * @author Владелец
 */
public class Series {
    //теперя можно хранить докуища данных!!!

    private HashMap<String, Float> points;
    //это массив для начальных данных. обычно все данные задаются ввиде <label, value>, value мы храним в этом массиве.
    private float[] values;
    private HashMap<String, String> attributes;
    private boolean visible = true, active = false;
    private int activeValueIndex = Integer.MAX_VALUE;
    //@todo непонятный конструктор, нужен ли он?
    public Series() {
        points = new HashMap<String, Float>();
        values = new float[0];
    }
    //вызывается при парсинге xml

    public Series(float[] values, HashMap<String, String> attributes) {
        this.values = new float[values.length];
        for (int i = 0; i < values.length; i++) {
            this.values[i] = values[i];
        }
        this.attributes = attributes;
    }

    //по задумке, этот метод будет использоваться для преобразования координат.
    //@todo надо подумать над методом
    public void setPoints(HashMap<String, Float> points) {
        this.points = (HashMap<String, Float>) points.clone();
    }

    public float[] getValues() {
        return values;
    }

    public HashMap<String, Float> getPoints() {
        return (HashMap<String, Float>) points;
    }
    
    public String getAttribute(String key) {
        if (attributes.containsKey(key)) 
        return attributes.get(key); else return new String();
    }
    
    public void setAttribute(String key, String value) {
        attributes.put(key, value);
    }
    
    public void setVisible(boolean flag) {
        visible = flag;
    }
    
    public boolean getVisible() {
        return visible;
    }
    
    public void setActive(boolean flag) {
        active = flag;
    }
    
    public boolean getActive() {
        return active;
    }
    
    public void setActiveValueIndex(int index) {
        activeValueIndex = index;
    }
    
    public int getActiveValueIndex() {
        return activeValueIndex;
    }
}
