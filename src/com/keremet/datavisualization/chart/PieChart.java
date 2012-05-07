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
public class PieChart extends Chart {
    
    private String[] labels;
    
    public PieChart(Main main, HashMap<String, String> attributes, Series[] series, String[] labels) {
        this.main = main;
        this.parameters = attributes; // атрибуты входят в параметры.
        this.series = series;
        this.labels = labels;
        
        this.type = Chart.RADIAL_CHART;
    }
    
    public void draw(int frame, int framesCount) {
        
        drawLabels();
        
        main.stroke(255);
        main.strokeWeight(2);
        
        HashMap<String, Float> points = series[0].getPoints();
        float length = points.get("length");
        
        float x = new Float(parameters.get("chart.position.x"));
        float y = new Float(parameters.get("chart.position.y"));
        float diameter = new Float(parameters.get("chart.diameter"));
        for (int i = 0; i < length; i++) {
            
            main.fill(Graph.theme.getColorR(i), Graph.theme.getColorG(i), Graph.theme.getColorB(i));
            
            
            float startAngle = points.get(main.str(i) + ".angle.start") / framesCount * frame;
            float finishAngle = points.get(main.str(i) + ".angle.finish") / framesCount * frame;
            float middleAngle = (startAngle + finishAngle) / 2;
            
            if (i == series[0].getActiveValueIndex()) {
                main.arc(x + 20 * main.cos(middleAngle), y + 20 * main.sin(middleAngle), diameter,
                        diameter, startAngle, finishAngle);
                main.line(x + 20 * main.cos(middleAngle), y + 20 * main.sin(middleAngle),
                        x + 20 * main.cos(middleAngle) + diameter / 2 * main.cos(startAngle),
                        y + 20 * main.sin(middleAngle) + diameter / 2 * main.sin(startAngle));
                main.line(x + 20 * main.cos(middleAngle), y + 20 * main.sin(middleAngle),
                        x + 20 * main.cos(middleAngle) + diameter / 2 * main.cos(finishAngle),
                        y + 20 * main.sin(middleAngle) + diameter / 2 * main.sin(finishAngle));
            } else {
                main.arc(x, y, diameter, diameter, startAngle, finishAngle);
                main.line(x, y, x + diameter / 2 * main.cos(startAngle), y + diameter / 2 * main.sin(startAngle));
                main.line(x, y, x + diameter / 2 * main.cos(finishAngle), y + diameter / 2 * main.sin(finishAngle));
            }
        }
    }
    
    @Override
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
        parameters.put("chart.position.x", main.str(x));
        parameters.put("chart.position.y", main.str(y));
        parameters.put("chart.diameter", main.str(diameter));
        
        float[] values = series[series.length - 1].getValues();
        
        float valuesSum = 0;
        for (int i = 0; i < values.length; i++) {
            valuesSum += values[i];
        }
        
        HashMap<String, Float> points = new HashMap<String, Float>();

        //float sum = -main.PI / 2;
        float sum = 0;
        for (int i = 0; i < values.length; i++) {
            float value = main.map(values[i], 0, valuesSum, 0, 2 * main.PI);
            
            points.put(main.str(i) + ".angle.start", sum);
            points.put(main.str(i) + ".angle.finish", sum + value);
            
            sum += value;
        }
        points.put("length", (float) values.length);
        series[0].setPoints(points);
    }
    
    @Override
    public void invertY() {
    }

    //@Override
    public boolean getValueByCursor(float mouseX, float mouseY) {
        return false;
    }
    
    public void drawLabels() {
        
        main.pushStyle();
        
        main.textSize(Graph.theme.get("piechart.labels.textsize"));
        
        main.stroke(0);
        main.strokeWeight(1);
        
        float x = new Float(parameters.get("chart.position.x"));
        float y = new Float(parameters.get("chart.position.y"));
        float diameter = new Float(parameters.get("chart.diameter"));
        float radius = diameter / 2;
        float lineWidth = radius + 30;
        
        HashMap<String, Float> points = series[0].getPoints();
        float length = points.get("length");
        
        float[] values = series[series.length - 1].getValues();
        
        for (int i = 0; i < length; i++) {
            
            float startAngle = points.get(main.str(i) + ".angle.start");
            float finishAngle = points.get(main.str(i) + ".angle.finish");
            
            float middleAngle = (startAngle + finishAngle) / 2;
            
            main.line(x + radius * main.cos(middleAngle), y + radius * main.sin(middleAngle), x + lineWidth * main.cos(middleAngle), y + lineWidth * main.sin(middleAngle));
            
            float labelX = x + lineWidth * main.cos(middleAngle);
            float labelY = y + lineWidth * main.sin(middleAngle);
            
            if (main.PI/2 < middleAngle && middleAngle < 3 * main.PI / 2) {
                main.line(labelX, labelY, labelX = labelX - 10, labelY);
                main.textAlign(main.RIGHT);
                main.text(labels[i], labelX - 5, labelY + 5);
            } else {
                main.line(labelX, labelY, labelX = labelX + 10, labelY);
                main.textAlign(main.LEFT);
                main.text(labels[i], labelX + 5, labelY + 5);
            }
            
            
        }
        
        main.popStyle();
    }
    
    public Tooltip getTooltip(int mouseX, int mouseY) {
        
        HashMap<String, Float> points = series[0].getPoints();
        float length = points.get("length");
        
        float x = new Float(parameters.get("chart.position.x"));
        float y = new Float(parameters.get("chart.position.y"));
        
        float diameter = new Float(parameters.get("chart.diameter"));
        
        for (int i = 0; i < length; i++) {
            
            x = new Float(parameters.get("chart.position.x"));
            y = new Float(parameters.get("chart.position.y"));
            
            float startAngle = points.get(main.str(i) + ".angle.start");
            float finishAngle = points.get(main.str(i) + ".angle.finish");
            
            float middleAngle = (startAngle + finishAngle) / 2;
            
            if (series[0].getActiveValueIndex() == i) {
                x += 20 * main.cos(middleAngle);
                y += 20 * main.sin(middleAngle);
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
                alpha = (2 * main.PI) - alpha;
            }
            
            if (startAngle < alpha && alpha <= finishAngle) {
                
                float dX = x + (diameter / 4);
                float dY = y;
                
                dX = x + (float) ((diameter / 4) * Math.cos(middleAngle));
                dY = y + (float) ((diameter / 4) * Math.sin(middleAngle));
                
                return new Tooltip(main, main.str(series[0].getValues()[i]), dX, dY);
            }
        }
        
        return null;
    }
    
    public void slice(float mouseX, float mouseY) {
        
        HashMap<String, Float> points = series[0].getPoints();
        float length = points.get("length");
        
        float x = new Float(parameters.get("chart.position.x"));
        float y = new Float(parameters.get("chart.position.y"));
        float diameter = new Float(parameters.get("chart.diameter"));

        for (int i = 0; i < length; i++) {
            
            x = new Float(parameters.get("chart.position.x"));
            y = new Float(parameters.get("chart.position.y"));
            
            float startAngle = points.get(main.str(i) + ".angle.start");
            float finishAngle = points.get(main.str(i) + ".angle.finish");
            
            float middleAngle = (startAngle + finishAngle) / 2;
            
            if (series[0].getActiveValueIndex() == i) {
                x += 20 * main.cos(middleAngle);
                y += 20 * main.sin(middleAngle);
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
                alpha = (2 * main.PI) - alpha;
            }

            if (startAngle < alpha && alpha <= finishAngle) {
                
                if (series[0].getActiveValueIndex() == i) {
                    series[0].setActiveValueIndex(Integer.MAX_VALUE);
                } else {
                    series[0].setActiveValueIndex(i);
                }
                return;
            }
        }
    }
}
