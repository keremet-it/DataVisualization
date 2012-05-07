/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */




/**
 * Represents an axis of a graph. 
 * @author Владелец
 */
public class Axis {

    
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
    public Axis( String orientation, String[] labels) {
        
        this.parameters = null;
        this.series = null;
        this.labels = labels;
        this.orientation = orientation.toLowerCase();
        this.title = "";
    }

    public Axis( String orientation, float[] labels) {
        
        this.parameters = null;
        this.series = null;
        this.labels = new String[labels.length];
        for (int i = 0; i < labels.length; i++) {
            this.labels[i] = str(labels[i]);
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

        pushMatrix();
        pushStyle();

        textSize(Graph.theme.get("axis.textsize"));

        if (orientation.equals("y")) {
            drawY();
        } else {
            drawX();
        }

        popMatrix();
        popStyle();
    }
    
    /**
     * Draw X-oriented Axis
     */
    
    private void drawX() {
        HashMap<String, Float> points = (HashMap<String, Float>) (series.getPoints()).clone();
        float length = points.get("length");
        stroke(125);

        textAlign(CENTER);

        float zoomCoeficient = Graph.zoomCoeficient;

        for (int i = 0; i < length; i++) {
            float x1 = points.get(str(i) + ".x") - Graph.layout.getX();
            x1 *= zoomCoeficient;
            x1 += Graph.layout.getX();
            x1 -= Graph.currentPosition;
            points.put(str(i) + ".x", x1);
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

        float addY = (width * height / Graph.averageAreaSize);

        //draw lines
        for (int i = 0; i < length; i++) {

            float x = points.get(str(i) + ".x");
            if (x > xMax) {
                break;
            } else if (x < xMin) {
                continue;
            }
            float y = points.get(str(i) + ".y");

            line(x, y, x, y + 5 + addY);
        }

        addY = 5 + addY + Graph.theme.get("axis.textsize");
        
        //draw lables
        for (int i = 0; i < labels.length; i += delimeter) {
            float x = points.get(str(i) + ".x");
            if (x > xMax) {
                break;
            } else if (x < xMin) {
                continue;
            }
            float y = points.get(str(i) + ".y");

            /*
            pushMatrix();
            translate(x + pp, y + 15);
            rotate(-PI/2);
            textAlign(CENTER);
            
            text(labels[i], 0, 0);
            
            textAlign(LEFT);
            popMatrix();
             * 
             */

            text(labels[i], x + pp, y + addY );

        }

        addY += Graph.theme.get("axis.textsize")+10;
        
        { // вычисление координат расположения надписи оси X
            float x = layout.getX();
            float y = layout.getY();
            float axisWidth = layout.getWidth();
            float axisHeight = layout.getHeight();

            float posX = x + axisWidth / 2;
            float posY = y + axisHeight / 2;

            textAlign(CENTER);
            text(title, posX, layout.getY() + addY);
            textAlign(LEFT);
        }

        stroke(0);
    }
    
    /**
     * Draw Y-oriented Axis
     */
    
    private void drawY() {
        HashMap<String, Float> points = series.getPoints();
        float length = points.get("length");
        stroke(125);
        strokeWeight(1);
        textAlign(RIGHT);

        //draw lines
        for (int i = 0; i < length; i++) {
            float x = points.get(str(i) + ".x");
            float y = points.get(str(i) + ".y");

            line(x - 5, y, x + canvasWidth, y);
        }
        
        float maxTextWidth = 0;
        
        //draw lables
        for (int i = 0; i < labels.length; i++) {
            float x = points.get(str(i) + ".x");
            float y = points.get(str(i) + ".y");

            text(labels[i], x - 10, y + 5);
            
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

            pushMatrix();
            translate(x, posY);
            rotate(-PI / 2);
            textAlign(CENTER);

            text(title, 0, 0);

            textAlign(LEFT);
            popMatrix();
        }

        stroke(0);
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
            float t = map(i, minX, maxX, startX, endX);

            points.put(str((int) j) + ".x", t);
            points.put(str((int) j) + ".y", startY);
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
            float t = map(i, minY, maxY, startY, endY);

            points.put(str((int) j) + ".x", endX);
            points.put(str((int) j) + ".y", t);

            labels[(int) j] = str(i);
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


/**
 * Class Caption represents text at the top of canvas. Used in {@see Graph}
 * @author akanurlan
 * @param main PApplet which provides drawing
 */
public class Caption {
    
    Layout layout;
    String captionText;
    
    
    /**
     * Create Caption 
     * @param main PApplet which provides drawing
     * @param captionText Caption text
     */
    public Caption( String captionText) {
        
        this.captionText = captionText;
    }
    
    /**
     * Set layout which provides space for drawing
     * @param layout
     */
    public void setLayout(Layout layout) {
        this.layout = layout;
    }
    
    /**
     * Draw caption text
     */
    public void draw() {
        float x = layout.getX() + (layout.getWidth()/2);
        float y = layout.getY() + (layout.getHeight()/2) + (Graph.theme.get("caption.textsize")/3);
        pushMatrix();
        pushStyle();
        
        textAlign(CENTER);
        textSize(Graph.theme.get("caption.textsize"));
        
        text(captionText, x, y);

        popStyle();
        popMatrix();        
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


/**
 *
 * @author Владелец
 */
//класс ошибок
public class Error {
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */













/**
 *
 * @author Владелец
 */
public class Graph {
    
    var $;
    var canvasId;
    var bind = false;
    

    static 
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

    public Graph( canvas, jQuery ) {
        
        
        this.canvasId = "#"+canvas.id;
        this.$ = jQuery;
        animationIsComplete = false;
        
        smooth();

        charts = new ArrayList<Drawable>();
        resources = new HashMap<String, Object>();
        labels = null;
        

        activeSeries = new Series();
    }
    /**
     * Set XML from file.
     * @param path path to XML
     */
    public void setXMLFromUrl(String path) {
        
        XMLElement xml = new XMLElement();
        
        try {
            xml = new XMLElement(this, path);
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

            size(w, h);
        } else { 
            console.log(canvasId.substring(1));
            var canvas = document.getElementById(canvasId.substring(1));
            //size(canvas.width, canvas.height);
            console.log(canvas.width + " " + canvas.height);
            size(800, 500);
        }

        theme = new Theme();

        initLayout();

        preprocessing();
        
        if (!bind) {
        bindEvents();
        bind = true;
        }
        
    }

    // returns all attributes of XMLElement
    private HashMap<String, String> getAttributes(XMLElement xml) {

        HashMap<String, String> map = new HashMap<String, String>();

        //здесь будет происходить замена кода при помощи make_Processingjs.xml
        String[] names = xml.attributes;
        for (int k = 0; k < names.length; k++) {
            map.put(names[k]["name"].toLowerCase(), names[k]["value"]);
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
                chart = new AreaChart(attributes, series);
            } else if (attributes.get("type").toLowerCase().equals("columnchart")) {
                chart = new ColumnChart(attributes, series);
            } else if (attributes.get("type").toLowerCase().equals("linechart")) {
                chart = new LineChart(attributes, series);
            } else if (attributes.get("type").toLowerCase().equals("piechart")) {
                chart = new PieChart(attributes, series, labels);
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
        float right = width - getTheme().get("margin.right");
        float bottom = height - getTheme().get("margin.bottom");

        //создаем элементы для вертикальных графиков
        if (type == Chart.VERTICAL_CHART) {

            if (attributes.containsKey("showlegend")) {
                if (attributes.get("showlegend").equals("1")) {
                    legend = new Legend(charts);
                    legend.setOrientation(resources.containsKey("legendalign") ? (Float) resources.get("legendalign") : 0);
                }
            } else {
                legend = new Legend(charts);
                legend.setOrientation(resources.containsKey("legendalign") ? (Float) resources.get("legendalign") : 0);
            }

            yaxis = new Axis("y", new String[0]);
            yaxis.setTitle((String) resources.get("yaxisname"));

            xaxis = new Axis("x", labels);
            xaxis.setTitle((String) resources.get("xaxisname"));

            caption = new Caption((String) resources.get("caption"));

            if (attributes.containsKey("zoom") && attributes.get("zoom").equals("1")) {
                scrollbar = new ScrollBar();

                for (int i = 0; i < charts.size(); i++) {
                    if (charts.get(i).constructor == LineChart || charts.get(i).constructor == AreaChart) {
                        maxZoom = Math.max(maxZoom, (float) ((Chart) charts.get(i)).seriesLength() - (float) 1.5);
                    }
                }

            }

        } else if (type == Chart.RADIAL_CHART) {
            caption = new Caption((String) resources.get("caption"));
            /*
            if (attributes.containsKey("showlegend")) {
            if (attributes.get("showlegend").equals("1")) {
            legend = new Legend(charts);
            legend.setOrientation(resources.containsKey("legendalign") ? (Float) resources.get("legendalign") : 0);
            }
            } else {
            legend = new Legend(charts);
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
                bottom -= 5 + (width * height / averageAreaSize) + getTheme().get("axis.textsize") + 10;

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

                left += 5 + textWidth(str(maxValue * 10)) + 10;

                if (resources.containsKey("yaxisname")) {
                    left += getTheme().get("axis.textsize") + 10;
                }
            }

            //если легенда существует
            if (legend != null) {

                pushMatrix();
                pushStyle();

                textSize(Graph.theme.get("legend.textsize"));

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

                popMatrix();
                popStyle();
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
                    Layout tempLayout = new Layout(right, top, width - right - getTheme().get("margin.right"), bottom - top);

                    legend.setLayout(tempLayout);
                } else if (legend.getOrientation() == BOTTOM_ALIGN) {
                    //Layout tempLayout = new Layout(left, bottom + (xaxis.constructor == Axis ? xaxis.layout.getHeight() : 0), right - left, height - bottom - theme.get("margin.bottom") - (xaxis.constructor == Axis ? xaxis.layout.getHeight() : 0));
                    Layout tempLayout = new Layout(left, bottom + (xaxis != null ? xaxis.layout.getHeight() : 0) + (scrollbar != null ? scrollbar.layout.getHeight() : 0), right - left, height - bottom - theme.get("margin.bottom") - (xaxis != null ? xaxis.layout.getHeight() : 0) - (scrollbar != null ? scrollbar.layout.getHeight() : 0));
                    legend.setLayout(tempLayout);
                }
            }

        }
        if (caption != null) {
            Layout tempLayout = new Layout(left, getTheme().get("margin.top"), right - left, top - getTheme().get("margin.top"));

            caption.setLayout(tempLayout);
        }

        iconsLayout = new Layout(right, theme.get("margin.top"), width - right - theme.get("margin.right"), top - theme.get("margin.top"));
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
                if (charts.get(i).constructor == ColumnChart) {
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

                if (charts.get(i).constructor == LineChart || charts.get(i).constructor == AreaChart) {
                    Chart line = (Chart) charts.get(i);

                    for (int j = 0; j < line.seriesQty(); j++) {
                        if (!line.series[j].getVisible()) {
                            continue;
                        }
                        float[] values = line.getSeries(j).getValues();

                        maxY = max(values) > maxY ? max(values) : maxY;
                        minY = min(values) < minY ? min(values) : minY;
                    }
                } else if (charts.get(i).constructor == ColumnChart) {
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

            float zeroPosition = map(0, minY, maxY, layout.getY(), layout.getY() + layout.getHeight());

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

            //------РАСЧЕТ ГРАФ�?КОВ-------
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

        
        if (showAnimation) {
        animate();
        showAnimation = false;
        return;
        }
        

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
            textAlign(LEFT);
            text(resetZoomText, Graph.layout.getX() + Graph.layout.getWidth() - textWidth(resetZoomText) - 20, Graph.layout.getY() + 20);
        }

        if (afterDraw != null && afterDraw.getFlag()) {
            afterDraw.fire();
        }
    }

    private void animate() {
        int framesCount = (int) (animationTime * fps);

        
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
        

    }

    private void clear() {
        noStroke();
        fill(250, 250, 255);
        rect(0, 0, width, height);
        fill(0);
    }

    private void drawCaption() {
        if (caption != null) {
            caption.draw();
        }

    }

    private void drawIcons() {
        /*
        pushStyle();
        fill(0);
        rect(iconsLayout.getX() + iconsLayout.getWidth() - 20, iconsLayout.getY(), 20, 20);
        popStyle();
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
            cursor(ARROW);
            //dragging charts
            if (layout.isInside(x1, y1)) {
                if (attributes.containsKey("zoom") && attributes.get("zoom").equals("1")) {
                    mouseDrag = true;

                    draw();

                    noStroke();
                    fill(0, 162, 232, 125);

                    dragEnd = x2;

                    dragEnd = dragEnd < layout.getX() + layout.getWidth() ? dragEnd : layout.getX() + layout.getWidth();
                    dragEnd = dragEnd > layout.getX() ? dragEnd : layout.getX();

                    rect(dragStart, layout.getY(), dragEnd - dragStart, layout.getHeight());

                    fill(0);
                    stroke(0);

                }
            } else if (scrollbar != null) {
                if (scrollbar.layout.isInside(x1, y1)) {
                    if (scrollbar.getDragPosition() <= x1 && x1 <= scrollbar.getDragPosition() + scrollbar.getRunnerWidth()) {

                        cursor(HAND);
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
                cursor(HAND);
            } else {
                cursor(ARROW);
            }

            if (scrollbar != null && scrollbar.layout.isInside(x1, y1)) {
                flag = true;
                cursor(HAND);
            }

        }
        if (!flag) {

            if (layout.isInside(x1, y1)) {
                cursor(ARROW);

                minDif = 40;
                Tooltip tooltip = null;
                if (type == Chart.VERTICAL_CHART) {
                    for (int i = 0; i < charts.size(); i++) {
                        if (charts.get(i).constructor == LineChart) {
                            Tooltip temp = charts.get(i).getTooltip((int) x1, (int) y1);
                            tooltip = temp != null ? temp : tooltip;
                        }
                    }

                    if (tooltip == null) {
                        for (int i = 0; i < charts.size(); i++) {
                            if (charts.get(i).constructor == AreaChart) {
                                Tooltip temp = charts.get(i).getTooltip((int) x1, (int) y1);
                                tooltip = temp != null ? temp : tooltip;
                            }
                        }
                    }

                    if (tooltip == null) {
                        for (int i = 0; i < charts.size(); i++) {
                            if (charts.get(i).constructor == ColumnChart) {
                                tooltip = charts.get(i).getTooltip((int) x1, (int) y1);
                                break;
                            }
                        }
                    }

                    if (tooltip == null && activeChart != null) {
                        if (activeChart.constructor == ColumnChart) {
                            activeChart = null;
                            activeSeries.setActiveValueIndex(0);
                            activeSeries.setActive(false);
                            activeSeries = new Series();
                            draw();
                        } else if (activeChart.constructor == LineChart) {

                            tooltip = ((LineChart) activeChart).switchActiveValueIndex(x1, y1);
                        } else if (activeChart.constructor == AreaChart) {

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
                    cursor(HAND);
                } else {
                    cursor(ARROW);
                }

            } else {
                cursor(ARROW);
            }
        }
    }
    
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
    

    public static void convertNumber() {
    }

    public void setBeforeDrawFunction(  func  ) {
        beforeDraw = new UserEvent(   func  );
    }

    public void setAfterDrawFunction(  func  ) {
        afterDraw = new UserEvent(   func  );
    }

    public static float textWidth(String text) {
        return float($p.textWidth(text));
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


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
}/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */









/**
 *
 * @author Владелец
 */
public class Legend {

    
    ArrayList<String> names;
    Layout layout;
    float orientation;
    ArrayList<Drawable> charts;

    public Legend( ArrayList<Drawable> charts) {
        

        this.charts = charts;

        names = new ArrayList<String>();
        if (Graph.type != Chart.RADIAL_CHART) {
            for (int i = 0; i < charts.size(); i++) {
                Chart chart = (Chart) charts.get(i);
                for (int j = 0; j < chart.seriesQty(); j++) {
                    names.add(chart.getSeries(j).getAttribute("name"));
                }
            }
        } else {
        }
    }

    public void setLayout(Layout layout) {
        this.layout = layout;
    }

    public void draw() {

        textAlign(RIGHT);

        if (orientation == Graph.RIGHT_ALIGN) {

            float dx = 0, dy = 0;

            float x = layout.getX();
            float y = layout.getY();
            float legendWidth = layout.getWidth();
            float legendHeight = layout.getHeight();

            pushMatrix();
            pushStyle();

            float textInterval = 15;

            float textHeight = (names.size() - 1) * Graph.theme.get("legend.textsize") + (names.size() - 2) * textInterval;

            translate(x + 20, y + (legendHeight - textHeight) / 2);
            textSize(Graph.theme.get("legend.textsize"));
            textAlign(LEFT);

            fill(0);
            stroke(0);

            float yPosition = 0;

            Graph.chartNumber = 0;

            for (int i = 0; i < charts.size(); i++) {

                Chart chart = (Chart) charts.get(i);

                for (int j = 0; j < chart.seriesQty(); j++, yPosition += textInterval + Graph.theme.get("legend.textsize"), Graph.chartNumber++) {

                    pushStyle();
                    fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));
                    stroke(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));

                    if (chart.getSeries(j).getAttribute("enabled") == "1") {
                        fill(125);
                        stroke(125);
                    }
                    drawPictogram(charts.get(i), 0, yPosition - Graph.theme.get("legend.textsize") + 3);
                    
                    fill(0);
                    stroke(0);
                    
                    if (chart.getSeries(j).getAttribute("enabled") == "1") {
                        fill(125);
                        stroke(125);
                    }
                    
                    text(chart.getSeries(j).getAttribute("name"), Graph.theme.get("legend.textsize") + 10, yPosition);
                    popStyle();
                }
            }
            popStyle();
            popMatrix();
            

            Graph.chartNumber = 0;

        } else if (orientation == Graph.BOTTOM_ALIGN) {

            float textWidth_ = 0;
            int seriesCount = 0;

            float legendWidth = layout.getWidth();
            float textHeight = Graph.theme.get("legend.textsize") + 10;

            for (int i = 0; i < names.size(); i++) {
                float nameTextWidth = Graph.textWidth(names.get(i));

                if (seriesCount * 50 + textWidth_ + nameTextWidth > legendWidth) {
                    textHeight += Graph.theme.get("legend.textsize") + 10;
                    seriesCount = 0;
                    textWidth_ = 0;
                }

                textWidth_ += nameTextWidth;
                seriesCount++;
                text(names.get(i), layout.getX() + textWidth_ + ((seriesCount - 1) * 50), layout.getY() + textHeight);
            }
        }
    }

    private void drawPictogram(Drawable chart, float x, float y) {
        float textSize = Graph.theme.get("legend.textsize");

        if (chart.constructor == LineChart) {
            strokeWeight(2);
            line(x, y + (textSize / 2) + (textSize / 10), x + 15 + 4 * (textSize / 10), y + (textSize / 2) + (textSize / 10));
            ellipse(x + (15 + 4 * (textSize / 10)) / 2, y + (textSize / 2) + (textSize / 10), 6 + (textSize / 10), 6 + (textSize / 10));
        } else if (chart.constructor == ColumnChart) {
            strokeWeight(1);
            rect(x, y + (textSize / 10), textSize, textSize);
        } else if (chart.constructor == AreaChart) {
            strokeWeight(1);
            beginShape();

            vertex(x, y + (textSize / 2));
            vertex(x + (textSize / 3), y);
            vertex(x + (2 * textSize / 3), y + (textSize / 4));
            vertex(x + textSize, y);
            vertex(x + textSize, y + textSize);
            vertex(x, y + textSize);
            vertex(x, y + (textSize / 2));
            endShape();
        }
    }

    public void setOrientation(float orientation) {
        this.orientation = orientation;
    }

    public float getOrientation() {
        return orientation;
    }

    public Series getSeriesByCoords(float x, float y) {

        Series series = null;

        float legendX = layout.getX();
        float legendY = layout.getY();
        float legendWidth = layout.getWidth();
        float legendHeight = layout.getHeight();

        pushMatrix();
        pushStyle();

        float textInterval = 15;

        float textHeight = (names.size() - 1) * Graph.theme.get("legend.textsize") + (names.size() - 2) * textInterval;

        textSize(Graph.theme.get("legend.textsize"));
        textAlign(LEFT);

        float addX = legendX + 20;
        float addY = legendY + (legendHeight - textHeight) / 2;

        float yPosition = 0;

        for (int i = 0; i < charts.size(); i++) {
            Chart chart = (Chart) charts.get(i);

            boolean flag = false;

            for (int j = 0; j < chart.seriesQty(); j++, yPosition += textInterval + Graph.theme.get("legend.textsize"), Graph.chartNumber++) {

                String text = chart.getSeries(j).getAttribute("name");

                if (addX + Graph.theme.get("legend.textsize") + 10 <= x && x <= addX + Graph.theme.get("legend.textsize") + 10 + Graph.textWidth(text)
                        && addY + yPosition - Graph.theme.get("legend.textsize") <= y && y <= addY + yPosition) {
                    series = chart.series[j];

                    flag = true;
                    break;
                }
            }
            if (flag) {
                break;
            }
        }

        popMatrix();
        popStyle();

        return series;
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


/**
 *
 * @author Владелец
 */
public class ScrollBar {
    
    
    Layout layout;
    
    float runnerWidth = 0, runnerX = 0;
    float dragPosition = 0;
    public ScrollBar() {
        
    }
    
    public void setLayout(Layout layout) {
        this.layout = layout;
    }
    
    public void draw() {
        noStroke();
        fill(0,100,200,100);
        rect(layout.getX(), layout.getY(), layout.getWidth(), layout.getHeight());
        
        float left = Graph.currentPosition / Graph.zoomCoeficient;
        float right = (Graph.currentPosition + Graph.layout.getWidth()) / Graph.zoomCoeficient;
        
        runnerX = layout.getX() + left;
        runnerWidth = right - left;
        
        fill(0,100,200);
        rect(layout.getX()+ left, layout.getY(), right - left, layout.getHeight());
        stroke(1);
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
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */





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
    private int activeValueIndex = Number.MAX_VALUE;
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
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */





/**
 *
 * @author Владелец
 */
public class Theme {

    
    HashMap<String, Float> properties;
    ArrayList<String> colors;
    //colors: ['#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']

    public Theme() {
        
        
        
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

        properties.put("legend.textsize", (float) 12 + (width*height/Graph.averageAreaSize));
        properties.put("axis.textsize", (float) 12 + (width*height/Graph.averageAreaSize));

        properties.put("caption.textsize", (float) 18 + (width*height/Graph.averageAreaSize));
        
        properties.put("piechart.labels.textsize", (float) 12 + (width*height/Graph.averageAreaSize));
        
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
        return (h.charAt(0) == "#") ? h.substring(1, 7) : h;
    }

    public int getColorR(int index) {
        int add = index / colors.size();

        int ans = parseInt((cutHex(getColor(index % colors.size()))).substring(0, 2), 16);

        add = add * (255 - ans) / 2;

        return ans + add;
    }

    public int getColorG(int index) {

        int add = index / colors.size();

        int ans = parseInt((cutHex(getColor(index % colors.size()))).substring(2, 4), 16);

        add = add * (255 - ans) / 2;

        return ans + add;
    }

    public int getColorB(int index) {

        int add = index / colors.size();

        int ans = parseInt((cutHex(getColor(index % colors.size()))).substring(4, 6), 16);

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
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


/**
 *
 * @author Владелец
 */
public class Tooltip {

    private String text_;
    private float x, y, width_;
    

    public Tooltip( String text_, float x, float y) {
        this(text_, x, y, 0);
    }

    //для ColumnChart учитываем ширину столбца
    public Tooltip( String text_, float x, float y, float width_) {
        
        this.text_ = text_;
        this.x = x;
        this.y = y;
        this.width_ = width_;
    }

    public void draw() {
        float space = (float) (0.2 * Graph.textWidth(text_) > 20 ? 0.2 * Graph.textWidth(text_) : 20);
        float tooltipX = 0, tooltipY = 0, tooltipWidth = 0, tooltipHeight = 0;
        float textWidth_ = Graph.textWidth(text_);
        if (x - Graph.layout.getX() > textWidth_ + space) {
            tooltipX = x - textWidth_ - space - 10;
            tooltipWidth = textWidth_ + 10;
            tooltipY = y - (Graph.theme.get("tooltip.textsize") / 2) - 5;
            tooltipHeight = Graph.theme.get("tooltip.textsize") + 10;
        } else {
            tooltipX = x + width_ + space;
            tooltipWidth = textWidth_ + 20;
            tooltipY = y - (Graph.theme.get("tooltip.textsize") / 2) - 5;
            tooltipHeight = Graph.theme.get("tooltip.textsize") + 10;
        }

        textAlign(LEFT);
        fill(255, 255, 255);

        stroke(0);
        rect(tooltipX, tooltipY, tooltipWidth, tooltipHeight);
        fill(0);
        text(text_, tooltipX + 10, tooltipY + Graph.theme.get("tooltip.textsize") + 5);
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


/**
 *
 * @author Владелец
 */
public class UserEvent {
     var func; 
    boolean flag = true;
    public UserEvent( func  ) {
         this.func = func; 
    }
    
    public void fire() {
         func(); 
        flag = false;
    }
    
    public boolean getFlag() {
        return flag;
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */











/**
 *
 * @author Владелец
 */
public class AreaChart extends Chart implements Zoomable {

    float zeroPosition = 0;
    private float smooth_value = (float) 0;
    float transparent = (float) 0.5;

    public AreaChart( HashMap<String, String> attributes, Series[] series) {
        
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

        strokeWeight(2);
        float xMax = Graph.layout.getX() + Graph.layout.getWidth();
        float xMin = Graph.layout.getX();

        for (int j = 0; j < series.length; j++, Graph.chartNumber++) {

            if (!series[j].getVisible()) {
                continue;
            }

            HashMap<String, Float> points = (HashMap<String, Float>) (series[j].getPoints()).clone();

            float size = points.get("length");

            for (int i = 0; i < size; i++) {
                float x1 = points.get(str(i) + ".x") - Graph.layout.getX();
                x1 *= zoomCoeficient;
                x1 += Graph.layout.getX();
                x1 -= Graph.currentPosition;
                points.put(str(i) + ".x", x1);
            }
            float shapeMaxX = -1, shapeMinX = 10000000;
            fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber), 200);
            noStroke();
            beginShape();

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < size - 1; i++) {

                float x1 = points.get(str(i) + ".x");
                float y1 = points.get(str(i) + ".y");

                float x0 = i > 0 ? points.get(str(i - 1) + ".x") : x1;
                float y0 = i > 0 ? points.get(str(i - 1) + ".y") : y1;

                float x2 = points.get(str(i + 1) + ".x");
                float y2 = points.get(str(i + 1) + ".y");

                float x3 = i < size - 2 ? points.get(str(i + 2) + ".x") : x2;
                float y3 = i < size - 2 ? points.get(str(i + 2) + ".y") : y2;

                ArrayList<Point> controlPoints = getControlPoints(new Point(x0, y0), new Point(x1, y1), new Point(x2, y2), new Point(x3, y3), smooth_value);

                Point p1 = new Point(x1, y1);
                Point p2 = controlPoints.get(0);
                Point p3 = controlPoints.get(1);
                Point p4 = new Point(x2, y2);

                //fill(0, 2 * ((j + 1) * 30), ((j * 4 + 1) * 30), 200);
                //stroke(0, 0, 0, 0);

                int steps = 60;

                boolean flag = false;

                for (int k = 0; k < steps; k++) {
                    float x = bezierPoint(p1.getX(), p2.getX(), p3.getX(), p4.getX(), (float) k / steps);

                    if (x > xMax || x > xLimit) {
                        flag = true;
                        break;
                    } else if (x < xMin) {
                        continue;
                    }
                    float y = bezierPoint(p1.getY(), p2.getY(), p3.getY(), p4.getY(), (float) k / steps);

                    vertex(x, y);

                    shapeMaxX = x > shapeMaxX ? x : shapeMaxX;
                    shapeMinX = x < shapeMinX ? x : shapeMinX;

                }
                if (xMin <=p4.getX() && p4.getX() <= xMax && p4.getX() <= xLimit) {
                    vertex(p4.getX(), p4.getY());

                    shapeMaxX = p4.getX() > shapeMaxX ? p4.getX() : shapeMaxX;
                    shapeMinX = p4.getX() < shapeMinX ? p4.getX() : shapeMinX;
                }
                if (flag) {
                    break;
                }

                //fill(0);
                textAlign(CENTER);
                if (xMin <= x1 && x1 <= xMax) {

                    if (series[j].getActive()) {
                        if (series[j].getActiveValueIndex() == i) {
                            ellipse(x1, y1, 12, 12);
                        }
                    }

                    if (showValues) {
                        float temp = series[j].getValues()[i];
                        String labelText = str(temp);

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

                        text(labelText, x1, y1 - 10);
                    }
                }
                //fill(0, 0, 0, 0);

            }

            if (shapeMaxX != -1 && shapeMinX != 10000000) {

                vertex(shapeMaxX, zeroPosition);
                vertex(shapeMinX, zeroPosition);
            }


            endShape();
        }

        strokeWeight(1);

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

                float y = map(values[j], minY, maxY, startY, endY);
                float x = map(j, 0, values.length - 1, startX + canvasInnerSpaceWidth, endX - canvasInnerSpaceWidth);

                points.put(str(j) + ".x", x);
                points.put(str(j) + ".y", y);

                tY = y;
                tX = x;
                tJ = j + 1;
            } // цикл k 

            points.put(str(tJ) + ".x", tX);
            points.put(str(tJ) + ".y", tY);

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
                float y = points.get(str(i) + ".y") - marginTop;
                y = canvasHeight - y + marginTop;
                points.put(str(i) + ".y", y);
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
                float x1 = points.get(str(i) + ".x") - Graph.layout.getX();
                x1 *= zoomCoeficient;
                x1 += Graph.layout.getX();
                x1 -= Graph.currentPosition;
                points.put(str(i) + ".x", x1);
            }

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < size - 1; i++) {

                float x1 = points.get(str(i) + ".x");
                float y1 = points.get(str(i) + ".y");

                float x0 = i > 0 ? points.get(str(i - 1) + ".x") : x1;
                float y0 = i > 0 ? points.get(str(i - 1) + ".y") : y1;

                float x2 = points.get(str(i + 1) + ".x");
                float y2 = points.get(str(i + 1) + ".y");

                float x3 = i < size - 2 ? points.get(str(i + 2) + ".x") : x2;
                float y3 = i < size - 2 ? points.get(str(i + 2) + ".y") : y2;

                ArrayList<Point> controlPoints = getControlPoints(new Point(x0, y0), new Point(x1, y1), new Point(x2, y2), new Point(x3, y3), smooth_value);

                Point p1 = new Point(x1, y1);
                Point p2 = controlPoints.get(0);
                Point p3 = controlPoints.get(1);
                Point p4 = new Point(x2, y2);

                int steps = 20;

                for (int k = 0; k < steps; k++) {
                    float x = bezierPoint(p1.getX(), p2.getX(), p3.getX(), p4.getX(), (float) k / steps);
                    if (x > xMax) {
                        break;
                    } else if (x < xMin) {
                        continue;
                    }
                    float y = bezierPoint(p1.getY(), p2.getY(), p3.getY(), p4.getY(), (float) k / steps);

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
            return new Tooltip(text, pointX, pointY);
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

                    float x1 = points.get(str(i) + ".x");
                    float y1 = points.get(str(i) + ".y");

                    if (Math.abs(x1 - mouseX) <= minDif) {
                        Graph.activeSeries.setActiveValueIndex(i);
                        pointX = x1;
                        pointY = y1;

                        text = series[j].getAttribute("name") + ", " + Graph.labels[i] + ": " + series[j].getValues()[i];

                        series[j].setActiveValueIndex(i);

                        minDif = Math.abs(x1 - mouseX);
                    }
                }
                return new Tooltip(text, pointX, pointY);
            }
        }
        return null;
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */









/**
 *
 * @author Владелец
 */
public abstract class Chart implements Drawable {

    
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
        textAlign(LEFT);
        fill(255, 255, 255);

        stroke(0);
        rect(x, y, width, height);
        fill(0);
        text(labelText, x + 10, y + Graph.theme.get("tooltip.textsize") + 5);
    }
}/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */








/**
 *
 * @author Владелец
 */
public class ColumnChart extends Chart {

    float zeroPosition = 0;

    public ColumnChart( HashMap<String, String> attributes, Series[] series) {
        
        this.parameters = attributes;
        this.series = series;

        this.type = Chart.VERTICAL_CHART;
    }


    public void draw(int frame, int framesCount) {

        pushStyle();

        boolean showValues = Graph.attributes.containsKey("showvalues") && Graph.attributes.get("showvalues").equals("1") ? true : false;

        noStroke();

        for (int j = 0; j < series.length; j++, Graph.chartNumber++) {

            if (!series[j].getVisible()) {
                continue;
            }

            fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));

            HashMap<String, Float> points = series[j].getPoints();
            float length = points.get("length");

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < length; i++) {
                float x = points.get(str(i) + ".x");
                float y = points.get(str(i) + ".y");
                float w = points.get(str(i) + ".width");
                float h = points.get(str(i) + ".height");

                h *= (float) frame / framesCount;

                rect(x, y, w, h);

                if (series[j].getActive()) {

                    if (series[j].getActiveValueIndex() == i) {

                        pushStyle();
                        fill(Graph.theme.getColorR(Graph.chartNumber) + 60, Graph.theme.getColorG(Graph.chartNumber) + 20, Graph.theme.getColorB(Graph.chartNumber) + 20);
                        rect(x, y, w, h);
                        popStyle();
                    }
                }

                if (showValues) {
                    fill(0);
                    textAlign(CENTER);
                    float x1 = w / 2 + x;
                    float y1 = y + h - 10;

                    float temp = series[j].getValues()[i];
                    String text = str(temp);

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

                    text(text, x1, y1);
                    fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));
                }

            }
            //Graph.chartNumber++;
        }

        stroke(0);

        popStyle();
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
                float y = map(values[j], minY, maxY, startY, endY);
                float x = map(j, 0, values.length, startX, endX);

                x += addX + spaceWidth;

                points.put(str(j) + ".x", x + space);
                points.put(str(j) + ".width", (float) columnWidth - (2 * space));

                if (y != zeroPosition) {
                    points.put(str(j) + ".y", y > zeroPosition ? zeroPosition + 1 : zeroPosition - 2);
                    points.put(str(j) + ".height", y > zeroPosition ? y - zeroPosition - 1 : y - zeroPosition + 2);
                } else {
                    points.put(str(j) + ".y", zeroPosition);
                    points.put(str(j) + ".height", y - zeroPosition);
                }

                points.put(str(j) + ".height", y > zeroPosition ? y - zeroPosition - 1 : y - zeroPosition + 2);
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
                float y = points.get(str(i) + ".y");
                float h = points.get(str(i) + ".height");
                if (h < 0) {
                    points.put(str(i) + ".y", Graph.layout.getHeight() - y + 2 * Graph.layout.getY());
                    points.put(str(i) + ".height", -h);
                } else {
                    points.put(str(i) + ".y", Graph.layout.getHeight() - y + 2 * Graph.layout.getY());
                    points.put(str(i) + ".height", -h);
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
                float x = points.get(str(i) + ".x");
                float y = points.get(str(i) + ".y");
                float width_ = points.get(str(i) + ".width");
                float height_ = points.get(str(i) + ".height");

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
            return new Tooltip(text, colX, colY, colWidth);
        }
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */











/**
 *
 * @author Владелец
 */
public class LineChart extends Chart implements Zoomable {

    private float smooth_value = (float) 0;

    public LineChart( HashMap<String, String> attributes, Series[] series) {
        
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

        pushStyle();

        boolean showValues = Graph.attributes.containsKey("showvalues") && Graph.attributes.get("showvalues").equals("1") ? true : false;

        float xLimit = Graph.layout.getX() + (Graph.layout.getWidth() / framesCount * frame);

        float zoomCoeficient = Graph.zoomCoeficient;

        float xMax = Graph.layout.getX() + Graph.layout.getWidth();
        float xMin = Graph.layout.getX();

        for (int j = 0; j < series.length; j++, Graph.chartNumber++) {

            if (!series[j].getVisible()) {
                continue;
            }

            HashMap<String, Float> points = (HashMap<String, Float>) (series[j].getPoints()).clone();

            float size = points.get("length");

            for (int i = 0; i < size; i++) {
                float x1 = points.get(str(i) + ".x") - Graph.layout.getX();
                x1 *= zoomCoeficient;
                x1 += Graph.layout.getX();
                x1 -= Graph.currentPosition;
                points.put(str(i) + ".x", x1);
            }

            noFill();
            strokeWeight(2);

            if (series[j].getActive()) {
                strokeWeight(4);
            }
            stroke(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));

            beginShape();
            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < size - 1; i++) {

                float x1 = points.get(str(i) + ".x");
                float y1 = points.get(str(i) + ".y");

                float x0 = i > 0 ? points.get(str(i - 1) + ".x") : x1;
                float y0 = i > 0 ? points.get(str(i - 1) + ".y") : y1;

                float x2 = points.get(str(i + 1) + ".x");
                float y2 = points.get(str(i + 1) + ".y");

                float x3 = i < size - 2 ? points.get(str(i + 2) + ".x") : x2;
                float y3 = i < size - 2 ? points.get(str(i + 2) + ".y") : y2;

                ArrayList<Point> controlPoints = getControlPoints(new Point(x0, y0), new Point(x1, y1), new Point(x2, y2), new Point(x3, y3), smooth_value);

                Point p1 = new Point(x1, y1);
                Point p2 = controlPoints.get(0);
                Point p3 = controlPoints.get(1);
                Point p4 = new Point(x2, y2);


                //stroke(0);
                int steps = 80;

                boolean flag = false;

                for (int k = 0; k < steps; k++) {
                    float x = bezierPoint(p1.getX(), p2.getX(), p3.getX(), p4.getX(), (float) k / steps);
                    if (x > xMax || x > xLimit) {
                        flag = true;
                        break;
                    }
                    if (x < xMin) {
                        continue;
                    }
                    float y = bezierPoint(p1.getY(), p2.getY(), p3.getY(), p4.getY(), (float) k / steps);

                    vertex(x, y);
                }
                
                if (xMin <=p4.getX() && p4.getX() <= xMax && p4.getX() <= xLimit) {
                    vertex(p4.getX(), p4.getY());
                }

                if (flag) {
                    break;
                }

                pushStyle();
                textAlign(CENTER);
                if (xMin <= x1 && x1 <= xMax) {
                    fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));
                    strokeWeight(1);
                    stroke(255);

                    ellipse(x1, y1, 8, 8);

                    if (series[j].getActive()) {

                        if (series[j].getActiveValueIndex() == i) {
                            ellipse(x1, y1, 12, 12);
                        }
                    }

                    if (showValues) {
                        float temp = series[j].getValues()[i];
                        String labelText = str(temp);

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

                        text(labelText, x1, y1 - 10);
                    }
                }
                popStyle();
            }
            endShape();

        }

        popStyle();
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

                float y = map(values[j], minY, maxY, startY, endY);
                float x = map(j, 0, values.length - 1, startX + canvasInnerSpaceWidth, endX - canvasInnerSpaceWidth);

                points.put(str(j) + ".x", x);
                points.put(str(j) + ".y", y);

                tY = y;
                tX = x;
                tJ = j + 1;
            } // цикл k 

            points.put(str(tJ) + ".x", tX);
            points.put(str(tJ) + ".y", tY);

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
                float y = points.get(str(i) + ".y") - marginTop;
                y = canvasHeight - y + marginTop;
                points.put(str(i) + ".y", y);
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
                float x1 = points.get(str(i) + ".x") - Graph.layout.getX();
                x1 *= zoomCoeficient;
                x1 += Graph.layout.getX();
                x1 -= Graph.currentPosition;
                points.put(str(i) + ".x", x1);
            }

            //вытаскиваем данные и рисуем. все просто!       
            for (int i = 0; i < size - 1; i++) {

                float x1 = points.get(str(i) + ".x");
                float y1 = points.get(str(i) + ".y");

                float x0 = i > 0 ? points.get(str(i - 1) + ".x") : x1;
                float y0 = i > 0 ? points.get(str(i - 1) + ".y") : y1;

                float x2 = points.get(str(i + 1) + ".x");
                float y2 = points.get(str(i + 1) + ".y");

                float x3 = i < size - 2 ? points.get(str(i + 2) + ".x") : x2;
                float y3 = i < size - 2 ? points.get(str(i + 2) + ".y") : y2;

                ArrayList<Point> controlPoints = getControlPoints(new Point(x0, y0), new Point(x1, y1), new Point(x2, y2), new Point(x3, y3), smooth_value);

                Point p1 = new Point(x1, y1);
                Point p2 = controlPoints.get(0);
                Point p3 = controlPoints.get(1);
                Point p4 = new Point(x2, y2);

                int steps = 20;

                for (int k = 0; k < steps; k++) {
                    float x = bezierPoint(p1.getX(), p2.getX(), p3.getX(), p4.getX(), (float) k / steps);
                    if (x > xMax) {
                        break;
                    } else if (x < xMin) {
                        continue;
                    }
                    float y = bezierPoint(p1.getY(), p2.getY(), p3.getY(), p4.getY(), (float) k / steps);

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
            return new Tooltip(text, pointX, pointY);
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

                    float x1 = points.get(str(i) + ".x");
                    float y1 = points.get(str(i) + ".y");

                    if (Math.abs(x1 - mouseX) <= minDif) {
                        Graph.activeSeries.setActiveValueIndex(i);
                        pointX = x1;
                        pointY = y1;

                        text = series[j].getAttribute("name") + ", " + Graph.labels[i] + ": " + series[j].getValues()[i];

                        series[j].setActiveValueIndex(i);

                        minDif = Math.abs(x1 - mouseX);
                    }
                }
                return new Tooltip(text, pointX, pointY);
            }
        }
        return null;
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */








/**
 *
 * @author Владелец
 */
public class PieChart extends Chart {
    
    private String[] labels;
    
    public PieChart( HashMap<String, String> attributes, Series[] series, String[] labels) {
        
        this.parameters = attributes; // атрибуты входят в параметры.
        this.series = series;
        this.labels = labels;
        
        this.type = Chart.RADIAL_CHART;
    }
    
    public void draw(int frame, int framesCount) {
        
        drawLabels();
        
        stroke(255);
        strokeWeight(2);
        
        HashMap<String, Float> points = series[0].getPoints();
        float length = points.get("length");
        
        float x = float(parameters.get("chart.position.x"));
        float y = float(parameters.get("chart.position.y"));
        float diameter = float(parameters.get("chart.diameter"));
        for (int i = 0; i < length; i++) {
            
            fill(Graph.theme.getColorR(i), Graph.theme.getColorG(i), Graph.theme.getColorB(i));
            
            
            float startAngle = points.get(str(i) + ".angle.start") / framesCount * frame;
            float finishAngle = points.get(str(i) + ".angle.finish") / framesCount * frame;
            float middleAngle = (startAngle + finishAngle) / 2;
            
            if (i == series[0].getActiveValueIndex()) {
                arc(x + 20 * cos(middleAngle), y + 20 * sin(middleAngle), diameter,
                        diameter, startAngle, finishAngle);
                line(x + 20 * cos(middleAngle), y + 20 * sin(middleAngle),
                        x + 20 * cos(middleAngle) + diameter / 2 * cos(startAngle),
                        y + 20 * sin(middleAngle) + diameter / 2 * sin(startAngle));
                line(x + 20 * cos(middleAngle), y + 20 * sin(middleAngle),
                        x + 20 * cos(middleAngle) + diameter / 2 * cos(finishAngle),
                        y + 20 * sin(middleAngle) + diameter / 2 * sin(finishAngle));
            } else {
                arc(x, y, diameter, diameter, startAngle, finishAngle);
                line(x, y, x + diameter / 2 * cos(startAngle), y + diameter / 2 * sin(startAngle));
                line(x, y, x + diameter / 2 * cos(finishAngle), y + diameter / 2 * sin(finishAngle));
            }
        }
    }
    

    public void preprocessing(HashMap<String, Float> layoutParameters) {

        // соббстно, ширина и высота внутренного холста нужны для расчета радиуса окружности и для центра окружности
        float canvasWidth = Graph.layout.getWidth();
        float canvasHeight = Graph.layout.getHeight();

        //координаты центра окружности
        float x = Graph.layout.getX();
        float y = Graph.layout.getY();

        // устанавливаем окружности прямо посередине
        x += canvasWidth / 2;
        y += canvasHeight / 2;

        //отнимаем по 80 пикселей - линии и тексты
        //float LabelsAndLines = 60 + Graph.theme.get("legend.textsize");
        float LabelsAndLines = 80;

        //отнимаем от них по 20%
        canvasWidth -= (float) canvasWidth / 10 > LabelsAndLines ? (float) canvasWidth / 10 : LabelsAndLines;
        canvasHeight -= (float) canvasHeight / 10 > LabelsAndLines ? (float) canvasHeight / 10 : LabelsAndLines;
        float diameter = canvasWidth > canvasHeight ? canvasHeight : canvasWidth; // радиус равен половине минимальной величины.

        // задаем данные в параметры
        parameters.put("chart.position.x", str(x));
        parameters.put("chart.position.y", str(y));
        parameters.put("chart.diameter", str(diameter));
        
        float[] values = series[series.length - 1].getValues();
        
        float valuesSum = 0;
        for (int i = 0; i < values.length; i++) {
            valuesSum += values[i];
        }
        
        HashMap<String, Float> points = new HashMap<String, Float>();

        //float sum = -PI / 2;
        float sum = 0;
        for (int i = 0; i < values.length; i++) {
            float value = map(values[i], 0, valuesSum, 0, 2 * PI);
            
            points.put(str(i) + ".angle.start", sum);
            points.put(str(i) + ".angle.finish", sum + value);
            
            sum += value;
        }
        points.put("length", (float) values.length);
        series[0].setPoints(points);
    }
    

    public void invertY() {
    }

    //
    public boolean getValueByCursor(float mouseX, float mouseY) {
        return false;
    }
    
    public void drawLabels() {
        
        pushStyle();
        
        textSize(Graph.theme.get("piechart.labels.textsize"));
        
        stroke(0);
        strokeWeight(1);
        
        float x = float(parameters.get("chart.position.x"));
        float y = float(parameters.get("chart.position.y"));
        float diameter = float(parameters.get("chart.diameter"));
        float radius = diameter / 2;
        float lineWidth = radius + 30;
        
        HashMap<String, Float> points = series[0].getPoints();
        float length = points.get("length");
        
        float[] values = series[series.length - 1].getValues();
        
        for (int i = 0; i < length; i++) {
            
            float startAngle = points.get(str(i) + ".angle.start");
            float finishAngle = points.get(str(i) + ".angle.finish");
            
            float middleAngle = (startAngle + finishAngle) / 2;
            
            line(x + radius * cos(middleAngle), y + radius * sin(middleAngle), x + lineWidth * cos(middleAngle), y + lineWidth * sin(middleAngle));
            
            float labelX = x + lineWidth * cos(middleAngle);
            float labelY = y + lineWidth * sin(middleAngle);
            
            if (PI/2 < middleAngle && middleAngle < 3 * PI / 2) {
                line(labelX, labelY, labelX = labelX - 10, labelY);
                textAlign(RIGHT);
                text(labels[i], labelX - 5, labelY + 5);
            } else {
                line(labelX, labelY, labelX = labelX + 10, labelY);
                textAlign(LEFT);
                text(labels[i], labelX + 5, labelY + 5);
            }
            
            
        }
        
        popStyle();
    }
    
    public Tooltip getTooltip(int mouseX, int mouseY) {
        
        HashMap<String, Float> points = series[0].getPoints();
        float length = points.get("length");
        
        float x = float(parameters.get("chart.position.x"));
        float y = float(parameters.get("chart.position.y"));
        
        float diameter = float(parameters.get("chart.diameter"));
        
        for (int i = 0; i < length; i++) {
            
            x = float(parameters.get("chart.position.x"));
            y = float(parameters.get("chart.position.y"));
            
            float startAngle = points.get(str(i) + ".angle.start");
            float finishAngle = points.get(str(i) + ".angle.finish");
            
            float middleAngle = (startAngle + finishAngle) / 2;
            
            if (series[0].getActiveValueIndex() == i) {
                x += 20 * cos(middleAngle);
                y += 20 * sin(middleAngle);
            }

            //точка находится вне окружности
            if (Math.pow(mouseX - x, 2) + Math.pow(mouseY - y, 2) > (diameter * diameter / 4)) {
                continue;
            }
            
            Point p1 = new Point(x, y);
            Point p2 = new Point(mouseX, mouseY);
            Point p3 = new Point(p1.getX() + (diameter / 2), p1.getY());
            
            float a = (float) Math.pow(Math.pow(p3.getX() - p1.getX(), 2) + Math.pow(p3.getY() - p1.getY(), 2), 0.5);
            float b = (float) Math.pow(Math.pow(p3.getX() - p2.getX(), 2) + Math.pow(p3.getY() - p2.getY(), 2), 0.5);
            float c = (float) Math.pow(Math.pow(p2.getX() - p1.getX(), 2) + Math.pow(p2.getY() - p1.getY(), 2), 0.5);
            
            float alpha = (float) Math.acos((a * a + c * c - b * b) / (2 * a * c));
            
            if (mouseY < y) {
                alpha = (2 * PI) - alpha;
            }
            
            if (startAngle < alpha && alpha <= finishAngle) {
                
                float dX = x + (diameter / 4);
                float dY = y;
                
                dX = x + (float) ((diameter / 4) * Math.cos(middleAngle));
                dY = y + (float) ((diameter / 4) * Math.sin(middleAngle));
                
                return new Tooltip(str(series[0].getValues()[i]), dX, dY);
            }
        }
        
        return null;
    }
    
    public void slice(float mouseX, float mouseY) {
        
        HashMap<String, Float> points = series[0].getPoints();
        float length = points.get("length");
        
        float x = float(parameters.get("chart.position.x"));
        float y = float(parameters.get("chart.position.y"));
        float diameter = float(parameters.get("chart.diameter"));

        for (int i = 0; i < length; i++) {
            
            x = float(parameters.get("chart.position.x"));
            y = float(parameters.get("chart.position.y"));
            
            float startAngle = points.get(str(i) + ".angle.start");
            float finishAngle = points.get(str(i) + ".angle.finish");
            
            float middleAngle = (startAngle + finishAngle) / 2;
            
            if (series[0].getActiveValueIndex() == i) {
                x += 20 * cos(middleAngle);
                y += 20 * sin(middleAngle);
            }

            //точка находится вне окружности
            if (Math.pow(mouseX - x, 2) + Math.pow(mouseY - y, 2) > (diameter * diameter / 4)) {
                continue;
            }
            
            Point p1 = new Point(x, y);
            Point p2 = new Point(mouseX, mouseY);
            Point p3 = new Point(p1.getX() + (diameter / 2), p1.getY());
            
            float a = (float) Math.pow(Math.pow(p3.getX() - p1.getX(), 2) + Math.pow(p3.getY() - p1.getY(), 2), 0.5);
            float b = (float) Math.pow(Math.pow(p3.getX() - p2.getX(), 2) + Math.pow(p3.getY() - p2.getY(), 2), 0.5);
            float c = (float) Math.pow(Math.pow(p2.getX() - p1.getX(), 2) + Math.pow(p2.getY() - p1.getY(), 2), 0.5);
            
            float alpha = (float) Math.acos((a * a + c * c - b * b) / (2 * a * c));
            
            if (mouseY < y) {
                alpha = (2 * PI) - alpha;
            }

            if (startAngle < alpha && alpha <= finishAngle) {
                
                if (series[0].getActiveValueIndex() == i) {
                    series[0].setActiveValueIndex(Number.MAX_VALUE);
                } else {
                    series[0].setActiveValueIndex(i);
                }
                return;
            }
        }
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


/**
 *
 * @author Владелец
 */
public class Point {

    private float x, y;

    public Point(float x, float y) {
        this.x = x;
        this.y = y;
    }

    public float getX() {
        return x;
    }

    public void setX(float x) {
        this.x = x;
    }

    public float getY() {
        return y;
    }

    public void setY(float y) {
        this.y = y;
    }
}
/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */







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
        
}/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


/**
 *
 * @author Владелец
 */
public interface Zoomable {
    public void zoom(float coeficient);
}

Graph graph;
boolean state = false;

void setup() {
    var canvas_ = document.getElementById("canvas3");

    var xmlString = "<graph caption='Equipment Rentals' yAxisName='Sales' xAxisName='Months'"+
    " zoom='1'>"+
    "<chart type='linechart' isSpline='1'>"+
        "<series name='ColumnCharasdasad 2'>"+
            "<set value='2' label='Apples'/>"+
            "<set value='3' label='Oranges'/>"+
            "<set value='10' label='Pears'/>"+
        "</series>"+
    "</chart>"+
    "</graph>";

    graph = new Graph(canvas_, jQuery);
    graph.setXML(xmlString);
    graph.draw();
}