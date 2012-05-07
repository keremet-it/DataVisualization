/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

/**
 *
 * @author Владелец
 */
public class Tooltip {

    private String text_;
    private float x, y, width_;
    Main main;

    public Tooltip(Main main, String text_, float x, float y) {
        this(main, text_, x, y, 0);
    }

    //для ColumnChart учитываем ширину столбца
    public Tooltip(Main main, String text_, float x, float y, float width_) {
        this.main = main;
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

        main.textAlign(main.LEFT);
        main.fill(255, 255, 255);

        main.stroke(0);
        main.rect(tooltipX, tooltipY, tooltipWidth, tooltipHeight);
        main.fill(0);
        main.text(text_, tooltipX + 10, tooltipY + Graph.theme.get("tooltip.textsize") + 5);
    }
}
