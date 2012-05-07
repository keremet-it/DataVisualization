/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

import com.keremet.datavisualization.interfaces.Drawable;
import com.keremet.datavisualization.chart.Point;
import com.keremet.datavisualization.chart.PieChart;
import com.keremet.datavisualization.chart.AreaChart;
import com.keremet.datavisualization.chart.ColumnChart;
import com.keremet.datavisualization.chart.LineChart;
import com.keremet.datavisualization.chart.Chart;
import java.util.ArrayList;
import java.util.HashMap;
import processing.xml.XMLElement;

/**
 *
 * @author Владелец
 */
public class Graph {
    /*@js
    var $;
    var canvasId;
    var bind = false;
    @js*/

    static Main main;
    ArrayList<Drawable> charts;
    Axis yaxis, xaxis;
    Legend legend;
    public static Theme theme;
    Caption caption;
    ScrollBar scrollbar;
    public static Layout layout;
    private Layout iconsLayout;
    public static HashMap<String, Object> resources;
    public static HashMap<String, String> attributes;
    public static String[] labels;
    public static int type;
    public static float TOP_ALIGN = 0, RIGHT_ALIGN = 1, BOTTOM_ALIGN = 2, LEFT_ALIGN = 4;
    public static int chartNumber = 0;
    public static Series activeSeries = null;
    public static Drawable activeChart = null;
    public static float minDif = 40;
    String resetZoomText = "Reset Zoom";
    //анимация
    float animationTime = (float) 1, fps = 20;
    boolean showAnimation = true, animationIsComplete = true;
    //зумминг
    public static float currentPosition = 0, zoomCoeficient = 1, maxZoom = 1;
    //события
    UserEvent beforeDraw = null, afterDraw = null;
    boolean mouseDown = false, mouseDrag = false;
    float mouseDownX = 0, mouseDownY = 0, mouseUpX = 0, mouseUpY = 0;
    float dragStart = 0, dragEnd = 0, scrollBarPositionBuffer = 0;
    public static int averageAreaSize = 320000;
    boolean mousePressed_ = false, mouseDragged_ = true;
    float downX = 0, downY = 0, upX = 0, upY = 0;

    public Graph(Main main/*@js canvas, jQuery @js*/) {
        /*@js
        
        this.canvasId = "#"+canvas.id;
        this.$ = jQuery;
        animationIsComplete = false;
        @js*/
        main.smooth();

        charts = new ArrayList<Drawable>();
        resources = new HashMap<String, Object>();
        labels = null;
        this.main = main;

        activeSeries = new Series();
    }
    /**
     * Set XML from file.
     * @param path path to XML
     */
    public void setXMLFromUrl(String path) {
        
        XMLElement xml = new XMLElement();
        
        try {
            xml = new XMLElement(main, path);
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }

        parseXML(xml);
    }
    
    /**
     * Set XML from String variable
     * @param xmlString contains XML
     */
    public void setXML(String xmlString) {
        XMLElement xml = XMLElement.parse(xmlString);
        parseXML(xml);
    }
    
    /**
     * Parse XMLElement
     * @param xml input XMLElement
     */
    private void parseXML(XMLElement xml) {

        attributes = getAttributes(xml);

        String captionText = attributes.get("caption");
        resources.put("caption", captionText);

        String xAxisName = attributes.get("xaxisname");
        resources.put("xaxisname", xAxisName);

        String yAxisName = attributes.get("yaxisname");
        resources.put("yaxisname", yAxisName);

        resources.put("legendalign", convertOrientation(attributes.containsKey("legendalign") ? attributes.get("legendalign") : "right"));

        {
            XMLElement[] labelsXML = null;

            XMLElement tempXMLElement = xml.getChild("labels");

            if (tempXMLElement != null) {
                labelsXML = tempXMLElement.getChildren("set");
                labels = new String[labelsXML.length];

                for (int i = 0; i < labelsXML.length; i++) {
                    labels[i] = labelsXML[i].getString("label");
                }
            }
        }

        XMLElement[] chartsXML = xml.getChildren("chart");

        //просматриваю все чарты
        if (chartsXML.length > 0) {
            for (int i = 0; i < chartsXML.length; i++) {

                HashMap<String, String> chartAttributes = getAttributes(chartsXML[i]);
                Series[] series = null;

                // 2. обработка cерий
                XMLElement[] seriesXML = chartsXML[i].getChildren("series");

                series = new Series[seriesXML.length];

                //извлечение всех серий
                for (int j = 0; j < seriesXML.length; j++) {

                    HashMap<String, String> seriesAttributes = getAttributes(seriesXML[j]);

                    //теперя будем извлекать данные!
                    XMLElement[] sets = seriesXML[j].getChildren("set");

                    try {
                        //вот оно - задаем серию.
                        series[j] = new Series(parseValuesFromXML(sets), seriesAttributes);
                    } catch (Exception e) {
                        //@todo обработать исключение.
                        e.printStackTrace();
                    }

                    if (parseLabelsFromXML(sets) != null) {
                        labels = parseLabelsFromXML(sets);
                    }
                }
                //j цикл закончился

                //вот оно! создается chart.
                setChart(chartAttributes, series);

                if (chartAttributes.get("type").toLowerCase().equals("columnchart") || chartAttributes.get("type").toLowerCase().equals("piechart")) {
                    attributes.put("zoom", "0");
                }
            }
        }
        //i цикл закончился

        //@todo взять на заметку
        //устанавливаем размеры холста
        if (xml.hasAttribute("width") && xml.hasAttribute("height")) {
            int w = xml.getInt("width");
            int h = xml.getInt("height");

            main.size(w, h);
        }

        theme = new Theme(main);

        initLayout();

        preprocessing();
        /*@js
        if (!bind) {
        bindEvents();
        bind = true;
        }
        @js*/
    }

    // returns all attributes of XMLElement
    private HashMap<String, String> getAttributes(XMLElement xml) {

        HashMap<String, String> map = new HashMap<String, String>();

        //здесь будет происходить замена кода при помощи make_Processingjs.xml
        String[] names = xml.listAttributes();
        for (int k = 0; k < names.length; k++) {
            map.put(names[k].toLowerCase(), xml.getString(names[k]));
        }
        return map;
    }

    // парсит только values. для labels - parseLabelsXML
    private float[] parseValuesFromXML(XMLElement[] xml) throws Exception {

        float[] values = new float[xml.length];

        for (int i = 0; i < xml.length; i++) {
            if (xml[i].hasAttribute("value")) {
                values[i] = xml[i].getFloat("value");
            } else {
                throw new Exception("нет данных : " + xml[i].toString());
            }
        }

        return values;
    }

    private String[] parseLabelsFromXML(XMLElement[] xml) {

        String[] tempLabels = new String[xml.length];

        boolean flag = false;

        for (int i = 0; i < xml.length; i++) {
            if (xml[i].hasAttribute("label")) {
                flag = true;
                tempLabels[i] = xml[i].getString("label");

            } else if (flag) {
                tempLabels[i] = new String();
            }
        }
        if (!flag) {
            return null;
        }
        return tempLabels;
    }

    private void setChart(HashMap<String, String> attributes, Series[] series) {

        Chart chart = null;
        try {
            if (attributes.get("type").toLowerCase().equals("areachart")) {
                chart = new AreaChart(main, attributes, series);
            } else if (attributes.get("type").toLowerCase().equals("columnchart")) {
                chart = new ColumnChart(main, attributes, series);
            } else if (attributes.get("type").toLowerCase().equals("linechart")) {
                chart = new LineChart(main, attributes, series);
            } else if (attributes.get("type").toLowerCase().equals("piechart")) {
                chart = new PieChart(main, attributes, series, labels);
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
        if (chart != null) {
            charts.add(chart);
            type = chart.getType();
        }
    }

    //расчет шаблона графика. здесь создаются элементы графиков(оси, легенда)
    private void initLayout() {
        float top = getTheme().get("margin.top");
        float left = getTheme().get("margin.left");
        float right = main.width - getTheme().get("margin.right");
        float bottom = main.height - getTheme().get("margin.bottom");

        //создаем элементы для вертикальных графиков
        if (type == Chart.VERTICAL_CHART) {

            if (attributes.containsKey("showlegend")) {
                if (attributes.get("showlegend").equals("1")) {
                    legend = new Legend(main, charts);
                    legend.setOrientation(resources.containsKey("legendalign") ? (Float) resources.get("legendalign") : 0);
                }
            } else {
                legend = new Legend(main, charts);
                legend.setOrientation(resources.containsKey("legendalign") ? (Float) resources.get("legendalign") : 0);
            }

            yaxis = new Axis(main, "y", new String[0]);
            yaxis.setTitle((String) resources.get("yaxisname"));

            xaxis = new Axis(main, "x", labels);
            xaxis.setTitle((String) resources.get("xaxisname"));

            caption = new Caption(main, (String) resources.get("caption"));

            if (attributes.containsKey("zoom") && attributes.get("zoom").equals("1")) {
                scrollbar = new ScrollBar(main);

                for (int i = 0; i < charts.size(); i++) {
                    if (charts.get(i) instanceof LineChart || charts.get(i) instanceof AreaChart) {
                        maxZoom = Math.max(maxZoom, (float) ((Chart) charts.get(i)).seriesLength() - (float) 1.5);
                    }
                }

            }

        } else if (type == Chart.RADIAL_CHART) {
            caption = new Caption(main, (String) resources.get("caption"));
            /*
            if (attributes.containsKey("showlegend")) {
            if (attributes.get("showlegend").equals("1")) {
            legend = new Legend(main, charts);
            legend.setOrientation(resources.containsKey("legendalign") ? (Float) resources.get("legendalign") : 0);
            }
            } else {
            legend = new Legend(main, charts);
            legend.setOrientation(resources.containsKey("legendalign") ? (Float) resources.get("legendalign") : 0);
            }
             * 
             */
        }

        if (type == Chart.VERTICAL_CHART) {

            if (scrollbar != null) {
                bottom -= 10;
            }

            //если ось X существует
            if (xaxis != null) {
                //то отнимем от переменной bottom размер шрифта
                bottom -= 5 + (main.width * main.height / averageAreaSize) + getTheme().get("axis.textsize") + 10;

                //если надпись оси X задана
                if (resources.containsKey("xaxisname")) {
                    //отнимем от нижней границы 
                    bottom -= getTheme().get("axis.textsize") + 10;
                }
            }

            //если ось Y существует
            if (yaxis != null) {

                float maxValue = 0;

                for (int i = 0; i < charts.size(); i++) {
                    for (int j = 0; j < ((Chart) charts.get(i)).seriesQty(); j++) {
                        float tempMax = max(((Chart) charts.get(i)).getSeries(j).getValues());
                        maxValue = tempMax > maxValue ? tempMax : maxValue;
                    }
                }

                left += 5 + textWidth(main.str(maxValue * 10)) + 10;

                if (resources.containsKey("yaxisname")) {
                    left += getTheme().get("axis.textsize") + 10;
                }
            }

            //если легенда существует
            if (legend != null) {

                main.pushMatrix();
                main.pushStyle();

                main.textSize(Graph.theme.get("legend.textsize"));

                //если легенда располагается справа
                if (legend.getOrientation() == RIGHT_ALIGN) {
                    //то отнимаем от переменной right ширину легенды.

                    float maxTextWidth = 0; //ширина самого длинного названия серии

                    for (int i = 0; i < charts.size(); i++) {
                        Chart chart = (Chart) charts.get(i);
                        for (int j = 0; j < chart.seriesQty(); j++) {
                            float nameTextWidth = textWidth(chart.getSeries(j).getAttribute("name"));

                            maxTextWidth = nameTextWidth > maxTextWidth ? nameTextWidth : maxTextWidth;
                        }
                    }
                    maxTextWidth += 40 + Graph.theme.get("legend.textsize");

                    right -= maxTextWidth;
                } else if (legend.getOrientation() == BOTTOM_ALIGN) {

                    float textWidth_ = 0;
                    int seriesCount = 0;

                    float canvasWidth = right - left;
                    float tempValue = getTheme().get("legend.textsize") + 10;

                    for (int i = 0; i < charts.size(); i++) {
                        Chart chart = (Chart) charts.get(i);
                        for (int j = 0; j < chart.seriesQty(); j++) {
                            float nameTextWidth = textWidth(chart.getSeries(j).getAttribute("name"));

                            if (seriesCount * 50 + textWidth_ + nameTextWidth > canvasWidth) {
                                tempValue += getTheme().get("legend.textsize") + 10;
                                seriesCount = 0;
                                textWidth_ = 0;
                            }

                            textWidth_ += nameTextWidth;
                            seriesCount++;
                        }
                    }

                    //tempValue *= 3;

                    bottom -= tempValue;

                }

                main.popMatrix();
                main.popStyle();
            }
        }
        //если заголовок существует
        if (caption != null) {
            top += getTheme().get("caption.textsize") + 20;
        }

        { //задаем шаблон расположения для графиков.
            Layout tempLayout = new Layout(left, top, right - left, bottom - top);
            //для начала, мы будем присваивать шаблон каждому из графиков.

            layout = tempLayout;
        }
        if (type == Chart.VERTICAL_CHART) {
            if (yaxis != null) { //задаем шаблон расположения для оси Y
                Layout tempLayout = new Layout(getTheme().get("margin.left"), top, left - getTheme().get("margin.left"), bottom - top);

                yaxis.setLayout(tempLayout);
            }

            if (scrollbar != null) {
                Layout tempLayout = new Layout(left, bottom, right - left, 10);

                scrollbar.setLayout(tempLayout);
            }

            if (xaxis != null) { //задаем шаблон расположения для оси X
                Layout tempLayout = new Layout(left, bottom + (scrollbar != null ? scrollbar.layout.getHeight() : 0), right - left, 5 + getTheme().get("axis.textsize") + 10);
                xaxis.setLayout(tempLayout);
            }

            if (legend != null) { //задаем шаблон расположения для легенды

                if (legend.getOrientation() == RIGHT_ALIGN) {
                    Layout tempLayout = new Layout(right, top, main.width - right - getTheme().get("margin.right"), bottom - top);

                    legend.setLayout(tempLayout);
                } else if (legend.getOrientation() == BOTTOM_ALIGN) {
                    //Layout tempLayout = new Layout(left, bottom + (xaxis instanceof Axis ? xaxis.layout.getHeight() : 0), right - left, main.height - bottom - theme.get("margin.bottom") - (xaxis instanceof Axis ? xaxis.layout.getHeight() : 0));
                    Layout tempLayout = new Layout(left, bottom + (xaxis != null ? xaxis.layout.getHeight() : 0) + (scrollbar != null ? scrollbar.layout.getHeight() : 0), right - left, main.height - bottom - theme.get("margin.bottom") - (xaxis != null ? xaxis.layout.getHeight() : 0) - (scrollbar != null ? scrollbar.layout.getHeight() : 0));
                    legend.setLayout(tempLayout);
                }
            }

        }
        if (caption != null) {
            Layout tempLayout = new Layout(left, getTheme().get("margin.top"), right - left, top - getTheme().get("margin.top"));

            caption.setLayout(tempLayout);
        }

        iconsLayout = new Layout(right, theme.get("margin.top"), main.width - right - theme.get("margin.right"), top - theme.get("margin.top"));
    }

    public void setTheme(XMLElement xml) {

        XMLElement[] XMLColors = xml.getChild("colors").getChildren("set");
        String[] colors = new String[XMLColors.length];

        for (int i = 0; i < XMLColors.length; i++) {
            colors[i] = XMLColors[i].getString("color");
        }
    }

    //соббстно, возвращает максимальное значение из массива
    public static float max(float[] array) {
        float max = array[0];

        for (int i = 0; i < array.length; i++) {
            max = array[i] > max ? array[i] : max;
        }

        return max;
    }

    //соббстно, возвращает минимальное значение из массива
    public static float min(float[] array) {
        float min = array[0];

        for (int i = 0; i < array.length; i++) {
            min = array[i] < min ? array[i] : min;
        }

        return min;
    }

    private void preprocessing() {

        if (type == Chart.RADIAL_CHART) {
            Drawable chart = charts.get(charts.size() - 1);
            chart.preprocessing(new HashMap<String, Float>());

        } else if (type == Chart.VERTICAL_CHART) {

            float startX = layout.getX();
            float endX = startX + layout.getWidth();

            float startY = layout.getY();
            float endY = startY + layout.getHeight();

            float canvasInnerSpaceWidth = 0;

            int columnQnty = 0;

            for (int i = 0; i < charts.size(); i++) {
                if (charts.get(i) instanceof ColumnChart) {
                    Chart chart = (Chart) charts.get(i);
                    boolean flag = false;
                    for (int j = 0; j < chart.seriesQty(); j++) {
                        if (chart.series[j].getVisible()) {
                            float plotWidth = layout.getWidth() / (((Chart) charts.get(i)).seriesLength());
                            canvasInnerSpaceWidth = plotWidth / 2;
                            flag = true;
                            break;
                        }
                    }
                    if (flag) {
                        break;
                    }
                }
            }

            //расчет мин. и макс. значений среди всех серий
            float maxY = 0, minY = 0;
            for (int i = 0; i < charts.size(); i++) {

                if (charts.get(i) instanceof LineChart || charts.get(i) instanceof AreaChart) {
                    Chart line = (Chart) charts.get(i);

                    for (int j = 0; j < line.seriesQty(); j++) {
                        if (!line.series[j].getVisible()) {
                            continue;
                        }
                        float[] values = line.getSeries(j).getValues();

                        maxY = max(values) > maxY ? max(values) : maxY;
                        minY = min(values) < minY ? min(values) : minY;
                    }
                } else if (charts.get(i) instanceof ColumnChart) {
                    Chart bar = (Chart) charts.get(i);

                    for (int j = 0; j < bar.seriesQty(); j++) {
                        if (!bar.series[j].getVisible()) {
                            continue;
                        }

                        float tMaxY = max(bar.getSeries(j).getValues());
                        float tMinY = min(bar.getSeries(j).getValues());
                        maxY = tMaxY > maxY ? tMaxY : maxY;
                        minY = tMinY < minY ? tMinY : minY;
                    }
                } // barchart

            } // максимум и минимум

            float delimeterY = 0;

            {
                float axisMinValue = 0;
                float axisMaxValue = 1;
                float minValue = 0, maxValue = 0;

                if (minY != 0) {
                    minY *= -1;
                    axisMinValue = 1;
                }

                //вычисление порядка максимального значения по модулю
                if (maxY >= 10) {
                    float temp = maxY;
                    while (temp >= 10) {
                        axisMaxValue *= 10;
                        temp /= 10;
                    }
                } else if (0 < maxY && maxY < 1) {
                    float temp = maxY;
                    while (temp < 1) {
                        axisMaxValue /= 10;
                        temp *= 10;
                    }
                }

                if (minY != 0) {
                    if (minY >= 10) {
                        float temp = minY;

                        while (temp >= 10) {
                            axisMinValue *= 10;
                            temp /= 10;
                        }
                    } else if (0 < minY && minY < 1) {
                        float temp = minY;
                        while (temp < 1) {
                            axisMinValue /= 10;
                            temp *= 10;
                        }
                    }
                }

                float[] divLinesQnty = new float[3];
                divLinesQnty[0] = 10;
                divLinesQnty[1] = 5;
                divLinesQnty[2] = 2;

                for (int i = 0; i < 1000; i++) {
                    if (axisMaxValue <= maxY) {
                        axisMaxValue *= (i % 3 == 0 || i % 3 == 2) ? 2 : 2.5;
                    } else if ((axisMaxValue - maxY) * 100 / (maxY) > getTheme().get("graph.freespace.percent")) {
                        break;
                    } else {
                        axisMaxValue *= (i % 3 == 0 || i % 3 == 2) ? 2 : 2.5;
                    };
                }

                if (minY != 0) {
                    for (int i = 0; i < 1000; i++) {
                        if (axisMinValue <= minY) {
                            axisMinValue *= (i % 3 == 0 || i % 3 == 2) ? 2 : 2.5;
                        } else if ((axisMinValue - minY) * 100 / (minY) > getTheme().get("graph.freespace.percent")) {
                            break;
                        } else {
                            axisMinValue *= (i % 3 == 0 || i % 3 == 2) ? 2 : 2.5;
                        };
                    }
                }

                float coef = axisMinValue > 0 ? 2 : 1; // отвечает за соблюдение процента между полосами в обеих направлениях
                float tempDelimeterY = layout.getHeight();
                boolean flag = false;
                for (int i = 0; i < divLinesQnty.length; i++) {
                    if (layout.getHeight() / (coef * divLinesQnty[i]) >= 40) {
                        tempDelimeterY = Math.max(axisMaxValue, axisMinValue) / divLinesQnty[i];
                        flag = true;
                        break;
                    }
                }
                if (!flag) {
                    tempDelimeterY = Math.max(axisMaxValue, axisMinValue) / divLinesQnty[2];
                }

                for (float i = 0; i <= axisMaxValue + axisMinValue; i += tempDelimeterY) {
                    maxValue = i;
                    if (i <= maxY) {
                        continue;
                    }
                    float t = i - maxY;
                    float percent = t * 100 / maxY;
                    if (percent < getTheme().get("graph.freespace.percent")) {
                        continue;
                    } else {
                        break;
                    }
                }

                if (minY != 0) {
                    for (float i = 0; i <= axisMinValue + axisMaxValue; i += tempDelimeterY) {
                        minValue = i;

                        if (i <= minY) {
                            continue;
                        }

                        float t = i - minY;
                        float percent = t * 100 / minY;
                        if (percent < getTheme().get("graph.freespace.percent")) {
                            continue;
                        } else {
                            break;
                        }
                    }
                }

                maxY = maxValue;

                if (minY != 0) {
                    minY = -minValue;
                }

                delimeterY = tempDelimeterY;
            }

            //System.exit(0);

            HashMap<String, Float> layoutParameters = new HashMap<String, Float>();

            String path = "graph.preprocessing."; // легче переименовать путь для заполнения extendedProperties

            layoutParameters.put(path + "minY", minY);
            layoutParameters.put(path + "maxY", maxY);
            layoutParameters.put(path + "delimeter.y", delimeterY);

            float zeroPosition = main.map(0, minY, maxY, layout.getY(), layout.getY() + layout.getHeight());

            layoutParameters.put(path + "zero.position.y", zeroPosition);

            layoutParameters.put(path + "minX", (float) 0);
            if (canvasInnerSpaceWidth > 0) {
                layoutParameters.put(path + "maxX", (float) ((Chart) charts.get(0)).seriesLength());
            } else {
                layoutParameters.put(path + "maxX", (float) ((Chart) charts.get(0)).seriesLength() - 1);
            }
            layoutParameters.put(path + "delimeter.x", (float) 1);

            layoutParameters.put(path + "startX", startX);
            layoutParameters.put(path + "endX", endX);
            layoutParameters.put(path + "startY", startY);
            layoutParameters.put(path + "endY", endY);
            layoutParameters.put(path + "canvasInnerSpaceWidth", canvasInnerSpaceWidth);

            //------РАСЧЕТ ГРАФИКОВ-------
            for (int i = 0; i < charts.size(); i++) {
                charts.get(i).preprocessing(layoutParameters);
            }

            yaxis.preprocessing(layoutParameters);
            xaxis.preprocessing(layoutParameters);

            //invert charts
            for (int i = 0; i < charts.size(); i++) {
                charts.get(i).invertY();
            }


        }
    }

    public void onBeforeDraw() {
    }

    public void onAfterDraw() {
    }

    public void draw() {

        clear();

        if (beforeDraw != null && beforeDraw.getFlag()) {
            beforeDraw.fire();
        }

        /*@js
        if (showAnimation) {
        animate();
        showAnimation = false;
        return;
        }
        @js*/

        drawCaption();
        drawIcons();
        if (type == Chart.VERTICAL_CHART) {
            drawAxes();

            if (legend != null) {
                legend.draw();
            }
        }
        chartNumber = 0;
        for (int i = 0; i < charts.size(); i++) {
            charts.get(i).draw(1, 1);
        }

        if (scrollbar != null) {
            scrollbar.draw();
        }

        if (zoomCoeficient > 1) {
            main.textAlign(main.LEFT);
            main.text(resetZoomText, Graph.layout.getX() + Graph.layout.getWidth() - textWidth(resetZoomText) - 20, Graph.layout.getY() + 20);
        }

        if (afterDraw != null && afterDraw.getFlag()) {
            afterDraw.fire();
        }
    }

    private void animate() {
        int framesCount = (int) (animationTime * fps);

        /*@js
        function d(time) {
        var def =  $.Deferred();
        
        setTimeout(function() {
        var currentFrame =  time / dTime;
        def.resolve(currentFrame);
        }, time);
        
        return def.promise();
        };
        
        var framesCount =   $p.__int_cast(($this_1.animationTime * $this_1.fps));
        var time =  0;
        
        var dTime =  $this_1.animationTime * 1000 / framesCount;
        
        for (var i =  0;  i < framesCount;  i++) {
        time+=dTime;
        var t =  d(time);
        
        $.when(t).done(function(frame) {
        (function(i, framesCount) {
        
        $this_1.$self.clear();
        $this_1.$self.drawCaption();
        if (Graph.type == Chart.VERTICAL_CHART) {
        $this_1.$self.drawAxes();
        
        $this_1.legend.draw(Graph.theme);
        }
        
        for (var j =  0;  j < $this_1.charts.size();  j++) {
        $this_1.charts.get(j).draw(i, framesCount);
        }
        if (i == framesCount-1) animationIsComplete = true;
        })(frame, framesCount);
        });
        }
        @js*/

    }

    private void clear() {
        main.noStroke();
        main.fill(250, 250, 255);
        main.rect(0, 0, main.width, main.height);
        main.fill(0);
    }

    private void drawCaption() {
        if (caption != null) {
            caption.draw();
        }

    }

    private void drawIcons() {
        /*
        main.pushStyle();
        main.fill(0);
        main.rect(iconsLayout.getX() + iconsLayout.getWidth() - 20, iconsLayout.getY(), 20, 20);
        main.popStyle();
         * 
         */
    }

    private void drawAxes() {
        if (attributes.get("showyaxis") == null || attributes.get("showyaxis") == "1") {
            yaxis.draw();
        }
        xaxis.draw();
    }

    public void zoom(float start, float end) {
        start -= layout.getX();
        end -= layout.getX();

        if (start > end) {
            float temp = start;
            start = end;
            end = temp;
        }

        start = start > 0 ? start : 0;
        end = end < layout.getWidth() ? end : layout.getWidth();

        float diff = end - start;

        currentPosition = (start + currentPosition) / zoomCoeficient;
        zoomCoeficient *= layout.getWidth() / diff;
        zoomCoeficient = zoomCoeficient < maxZoom ? zoomCoeficient : maxZoom;
        currentPosition *= zoomCoeficient;

        currentPosition =
                currentPosition < layout.getWidth() * (zoomCoeficient - 1)
                ? currentPosition : layout.getWidth() * (zoomCoeficient - 1);

    }

    public static float min(float x, float y) {
        if (x < y) {
            return x;
        } else {
            return y;
        }
    }

    public static float max(float x, float y) {
        if (x > y) {
            return x;
        } else {
            return y;
        }
    }

    public float convertOrientation(String orientation) {
        if (orientation.equals("right")) {
            return RIGHT_ALIGN;
        } else if (orientation.equals("bottom")) {
            return BOTTOM_ALIGN;
        } else if (orientation.equals("left")) {
            return LEFT_ALIGN;
        } else {
            return TOP_ALIGN;
        }
    }

    public Theme getTheme() {
        return theme;
    }

    public void mouseDownHandler(float x1, float y1) {

        if (!animationIsComplete) {
            return;
        }

        mouseDown = true;
        dragStart = x1;

        mouseDownX = x1;
        mouseDownY = y1;

        if (scrollbar != null && scrollbar.layout.isInside(x1, y1)) {
            scrollbar.setDragPosition();
        }

    }

    public void mouseUpHandler(float x1, float y1) {

        if (!animationIsComplete) {
            return;
        }

        if (mouseDrag) {
            if (layout.isInside(mouseDownX, mouseDownY)) {
                if (attributes.get("zoom").equals("1")) {
                    zoom(dragStart, dragEnd);
                    draw();
                }
            }
        } else {

            boolean flag = false;

            if (zoomCoeficient > 1) {
                float resetZoomTextX = layout.getX() + layout.getWidth() - textWidth(resetZoomText) - 20;
                float resetZoomTextY = layout.getY();
                float resetZoomTextWidth = textWidth(resetZoomText) + 20;
                float resetZoomTextHeight = 20;

                //if "Reset Zoom" is clicked
                if (resetZoomTextX <= x1 && x1 <= resetZoomTextX + resetZoomTextWidth
                        && resetZoomTextY <= y1 && y1 <= resetZoomTextY + resetZoomTextHeight) {

                    zoomCoeficient = 1;
                    currentPosition = 0;

                    draw();

                    flag = true;
                }
            }
            if (!flag) {
                if (layout.isInside(x1, y1)) {
                    if (type == Chart.RADIAL_CHART) {
                        ((PieChart) charts.get(charts.size() - 1)).slice(x1, y1);
                        draw();
                    }
                } else if (legend != null && legend.layout.isInside(x1, y1)) {
                    Series series = legend.getSeriesByCoords(x1, y1);

                    if (series != null) {
                        series.setVisible(!series.getVisible());

                        String value = series.getAttribute("enabled");
                        if (value == null || value == "1") {
                            series.setAttribute("enabled", "0");
                        } else {
                            series.setAttribute("enabled", "1");
                        }

                        preprocessing();
                        draw();
                    }

                } else if (iconsLayout.isInside(x1, y1)) {

                    Layout temp = new Layout(iconsLayout.getX() + iconsLayout.getWidth() - 20, iconsLayout.getY(), 20, 20);

                    if (temp.isInside(x1, y1)) {
                    }
                }
            }
        }

        mouseDown = false;
        mouseDrag = false;
        scrollBarPositionBuffer = 0;
    }
    float px = 0, py = 0;

    public void mouseDragHandler(float x1, float y1, float x2, float y2) {

        if (!animationIsComplete) {
            return;
        }

        if (mouseDown) {
            main.cursor(main.ARROW);
            //dragging charts
            if (layout.isInside(x1, y1)) {
                if (attributes.containsKey("zoom") && attributes.get("zoom").equals("1")) {
                    mouseDrag = true;

                    draw();

                    main.noStroke();
                    main.fill(0, 162, 232, 125);

                    dragEnd = x2;

                    dragEnd = dragEnd < layout.getX() + layout.getWidth() ? dragEnd : layout.getX() + layout.getWidth();
                    dragEnd = dragEnd > layout.getX() ? dragEnd : layout.getX();

                    main.rect(dragStart, layout.getY(), dragEnd - dragStart, layout.getHeight());

                    main.fill(0);
                    main.stroke(0);

                }
            } else if (scrollbar != null) {
                if (scrollbar.layout.isInside(x1, y1)) {
                    if (scrollbar.getDragPosition() <= x1 && x1 <= scrollbar.getDragPosition() + scrollbar.getRunnerWidth()) {

                        main.cursor(main.HAND);
                        currentPosition -= scrollBarPositionBuffer;

                        float temp = (x2 - x1) * zoomCoeficient;

                        //бегунок не может выйти за границы полосы
                        temp = currentPosition + temp >= 0 ? temp : -currentPosition;
                        temp = currentPosition + temp <= layout.getWidth() * (zoomCoeficient - 1) ? temp : layout.getWidth() * (zoomCoeficient - 1) - currentPosition;

                        scrollBarPositionBuffer = temp;

                        currentPosition += temp;

                        draw();
                    }
                }
            }
        }
    }

    public void mouseMoveHandler(float x1, float y1) {
        if (!animationIsComplete) {
            return;
        }

        if (mouseDown) {
            mouseDragHandler(mouseDownX, mouseDownY, x1, y1);
            return;
        }

        boolean flag = false;

        if (zoomCoeficient > 1) {

            float resetZoomTextX = layout.getX() + layout.getWidth() - textWidth(resetZoomText) - 20;
            float resetZoomTextY = layout.getY();
            float resetZoomTextWidth = textWidth(resetZoomText) + 20;
            float resetZoomTextHeight = 20;

            //if "Reset Zoom" is clicked
            if (resetZoomTextX <= x1 && x1 <= resetZoomTextX + resetZoomTextWidth
                    && resetZoomTextY <= y1 && y1 <= resetZoomTextY + resetZoomTextHeight) {
                flag = true;
                main.cursor(main.HAND);
            } else {
                main.cursor(main.ARROW);
            }

            if (scrollbar != null && scrollbar.layout.isInside(x1, y1)) {
                flag = true;
                main.cursor(main.HAND);
            }

        }
        if (!flag) {

            if (layout.isInside(x1, y1)) {
                main.cursor(main.ARROW);

                minDif = 40;
                Tooltip tooltip = null;
                if (type == Chart.VERTICAL_CHART) {
                    for (int i = 0; i < charts.size(); i++) {
                        if (charts.get(i) instanceof LineChart) {
                            Tooltip temp = charts.get(i).getTooltip((int) x1, (int) y1);
                            tooltip = temp != null ? temp : tooltip;
                        }
                    }

                    if (tooltip == null) {
                        for (int i = 0; i < charts.size(); i++) {
                            if (charts.get(i) instanceof AreaChart) {
                                Tooltip temp = charts.get(i).getTooltip((int) x1, (int) y1);
                                tooltip = temp != null ? temp : tooltip;
                            }
                        }
                    }

                    if (tooltip == null) {
                        for (int i = 0; i < charts.size(); i++) {
                            if (charts.get(i) instanceof ColumnChart) {
                                tooltip = charts.get(i).getTooltip((int) x1, (int) y1);
                                break;
                            }
                        }
                    }

                    if (tooltip == null && activeChart != null) {
                        if (activeChart instanceof ColumnChart) {
                            activeChart = null;
                            activeSeries.setActiveValueIndex(0);
                            activeSeries.setActive(false);
                            activeSeries = new Series();
                            draw();
                        } else if (activeChart instanceof LineChart) {

                            tooltip = ((LineChart) activeChart).switchActiveValueIndex(x1, y1);
                        } else if (activeChart instanceof AreaChart) {

                            tooltip = ((AreaChart) activeChart).switchActiveValueIndex(x1, y1);
                        }
                    }
                } else if (type == Chart.RADIAL_CHART) {
                    Drawable pie = charts.get(charts.size() - 1);

                    tooltip = pie.getTooltip((int) x1, (int) y1);
                    if (tooltip == null) {
                        draw();
                    }
                }
                if (tooltip != null) {
                    draw();
                    tooltip.draw();
                }

            } else if (legend != null && legend.layout.isInside(x1, y1)) {

                Series series = legend.getSeriesByCoords(x1, y1);

                if (series != null) {
                    main.cursor(main.HAND);
                } else {
                    main.cursor(main.ARROW);
                }

            } else {
                main.cursor(main.ARROW);
            }
        }
    }
    /*@js
    function bindEvents() {
    
    $(canvasId).live("mousedown", function() {
    downX = mouseX;
    downY = mouseY;
    mouseDownHandler(mouseX, mouseY);
    });
    
    $(canvasId).live("mouseup", function() {
    mouseUpHandler(mouseX, mouseY);
    });		
    
    $(canvasId).live("mousemove", function() {
    mouseMoveHandler(mouseX, mouseY);
    });	
    
    }
    @js*/

    public static void convertNumber() {
    }

    public void setBeforeDrawFunction(/*@js  func  @js*/) {
        beforeDraw = new UserEvent( /*@js  func  @js*/);
    }

    public void setAfterDrawFunction(/*@js  func  @js*/) {
        afterDraw = new UserEvent( /*@js  func  @js*/);
    }

    public static float textWidth(String text) {
        return main.textWidth(text);
    }
}
