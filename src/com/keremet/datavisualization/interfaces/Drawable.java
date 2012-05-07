/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization.interfaces;

import com.keremet.datavisualization.Main;
import com.keremet.datavisualization.Series;
import com.keremet.datavisualization.Tooltip;
import java.util.HashMap;

/**
 *
 * @author Владелец
 */
// @todo Разобраться с интерфейсом Zoomable. Нужен ли он?
public interface Drawable {

    public void draw(int frame, int framesCount);

    public void preprocessing(HashMap<String, Float> layoutParameters);

    public void invertY();

    //public float getValueByCursor(float mouseX, float mouseY);

    public Tooltip getTooltip(int mouseX, int mouseY);
        
}