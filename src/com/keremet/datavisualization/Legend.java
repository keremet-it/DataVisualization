/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

import com.keremet.datavisualization.chart.AreaChart;
import com.keremet.datavisualization.chart.Chart;
import com.keremet.datavisualization.chart.ColumnChart;
import com.keremet.datavisualization.chart.LineChart;
import com.keremet.datavisualization.interfaces.Drawable;
import java.util.ArrayList;

/**
 *
 * @author Владелец
 */
public class Legend {

    Main main;
    ArrayList<String> names;
    Layout layout;
    float orientation;
    ArrayList<Drawable> charts;

    public Legend(Main main, ArrayList<Drawable> charts) {
        this.main = main;

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

        main.textAlign(main.RIGHT);

        if (orientation == Graph.RIGHT_ALIGN) {

            float dx = 0, dy = 0;

            float x = layout.getX();
            float y = layout.getY();
            float legendWidth = layout.getWidth();
            float legendHeight = layout.getHeight();

            main.pushMatrix();
            main.pushStyle();

            float textInterval = 15;

            float textHeight = (names.size() - 1) * Graph.theme.get("legend.textsize") + (names.size() - 2) * textInterval;

            main.translate(x + 20, y + (legendHeight - textHeight) / 2);
            main.textSize(Graph.theme.get("legend.textsize"));
            main.textAlign(main.LEFT);

            main.fill(0);
            main.stroke(0);

            float yPosition = 0;

            Graph.chartNumber = 0;

            for (int i = 0; i < charts.size(); i++) {

                Chart chart = (Chart) charts.get(i);

                for (int j = 0; j < chart.seriesQty(); j++, yPosition += textInterval + Graph.theme.get("legend.textsize"), Graph.chartNumber++) {

                    main.pushStyle();
                    main.fill(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));
                    main.stroke(Graph.theme.getColorR(Graph.chartNumber), Graph.theme.getColorG(Graph.chartNumber), Graph.theme.getColorB(Graph.chartNumber));

                    if (chart.getSeries(j).getAttribute("enabled") == "1") {
                        main.fill(125);
                        main.stroke(125);
                    }
                    drawPictogram(charts.get(i), 0, yPosition - Graph.theme.get("legend.textsize") + 3);
                    
                    main.fill(0);
                    main.stroke(0);
                    
                    if (chart.getSeries(j).getAttribute("enabled") == "1") {
                        main.fill(125);
                        main.stroke(125);
                    }
                    
                    main.text(chart.getSeries(j).getAttribute("name"), Graph.theme.get("legend.textsize") + 10, yPosition);
                    main.popStyle();
                }
            }
            main.popStyle();
            main.popMatrix();
            

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
                main.text(names.get(i), layout.getX() + textWidth_ + ((seriesCount - 1) * 50), layout.getY() + textHeight);
            }
        }
    }

    private void drawPictogram(Drawable chart, float x, float y) {
        float textSize = Graph.theme.get("legend.textsize");

        if (chart instanceof LineChart) {
            main.strokeWeight(2);
            main.line(x, y + (textSize / 2) + (textSize / 10), x + 15 + 4 * (textSize / 10), y + (textSize / 2) + (textSize / 10));
            main.ellipse(x + (15 + 4 * (textSize / 10)) / 2, y + (textSize / 2) + (textSize / 10), 6 + (textSize / 10), 6 + (textSize / 10));
        } else if (chart instanceof ColumnChart) {
            main.strokeWeight(1);
            main.rect(x, y + (textSize / 10), textSize, textSize);
        } else if (chart instanceof AreaChart) {
            main.strokeWeight(1);
            main.beginShape();

            main.vertex(x, y + (textSize / 2));
            main.vertex(x + (textSize / 3), y);
            main.vertex(x + (2 * textSize / 3), y + (textSize / 4));
            main.vertex(x + textSize, y);
            main.vertex(x + textSize, y + textSize);
            main.vertex(x, y + textSize);
            main.vertex(x, y + (textSize / 2));
            main.endShape();
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

        main.pushMatrix();
        main.pushStyle();

        float textInterval = 15;

        float textHeight = (names.size() - 1) * Graph.theme.get("legend.textsize") + (names.size() - 2) * textInterval;

        main.textSize(Graph.theme.get("legend.textsize"));
        main.textAlign(main.LEFT);

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

        main.popMatrix();
        main.popStyle();

        return series;
    }
}
