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
public class Theme {

    Main main;
    HashMap<String, Float> properties;
    ArrayList<String> colors;
    //colors: ['#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']

    public Theme(Main main) {
        
        this.main = main;
        
        colors = new ArrayList<String>();
        colors.add("#058DC7");
        colors.add("#50B432");
        colors.add("#ED561B");
        colors.add("#DDDF00");
        colors.add("#24CBE5");
        colors.add("#64E572");
        colors.add("#FF9655");
        colors.add("#6AF9C4");

        properties = new HashMap<String, Float>();
        properties.put("margin.left", (float) 5);
        properties.put("margin.top", (float) 5);
        properties.put("margin.right", (float) 5);
        properties.put("margin.bottom", (float) 5);

        properties.put("legend.textsize", (float) 12 + (main.width*main.height/Graph.averageAreaSize));
        properties.put("axis.textsize", (float) 12 + (main.width*main.height/Graph.averageAreaSize));

        properties.put("caption.textsize", (float) 18 + (main.width*main.height/Graph.averageAreaSize));
        
        properties.put("piechart.labels.textsize", (float) 12 + (main.width*main.height/Graph.averageAreaSize));
        
    }

    public float get(String text) {

        text = text.toLowerCase();

        if (properties.containsKey(text)) {
            return properties.get(text);
        }
        
        if (text.contains("freespace")) {
            return 10;
        } else if (text.contains("textsize")) {
            return 15;
        } else if (text.contains("margin")) {
            return 15;
        }

        return 0;
    }

    public String getColor(int index) {
        return colors.get(index);
    }

    public String cutHex(String h) {
        return (h.charAt(0) == '#') ? h.substring(1, 7) : h;
    }

    public int getColorR(int index) {
        int add = index / colors.size();

        int ans = Integer.parseInt((cutHex(getColor(index % colors.size()))).substring(0, 2), 16);

        add = add * (255 - ans) / 2;

        return ans + add;
    }

    public int getColorG(int index) {

        int add = index / colors.size();

        int ans = Integer.parseInt((cutHex(getColor(index % colors.size()))).substring(2, 4), 16);

        add = add * (255 - ans) / 2;

        return ans + add;
    }

    public int getColorB(int index) {

        int add = index / colors.size();

        int ans = Integer.parseInt((cutHex(getColor(index % colors.size()))).substring(4, 6), 16);

        add = add * (255 - ans) / 2;

        return ans + add;
    }
    /*
    function hexToR(h) {
    return parseInt((cutHex(h)).substring(0, 2), 16)
    }
    
    function hexToG(h) {
    return parseInt((cutHex(h)).substring(2, 4), 16)
    }
    
    function hexToB(h) {
    return parseInt((cutHex(h)).substring(4, 6), 16)
    }
    
    function cutHex(h) {
    return (h.charAt(0) == "#") ? h.substring(1, 7) : h
    }
     * 
     */
}
