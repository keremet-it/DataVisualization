/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import processing.core.PApplet;
import processing.xml.XMLElement;

/**
 *
 * @author Владелец
 */
public class Main extends PApplet {

    public static void main(String[] args) {
        PApplet.main(new String[]{"com.keremet.datavisualization.Main"});
    }
    Graph graph;
    boolean state = false;

    public void setup() {

        graph = new Graph(this);

        String xmlString = new String();

        try {
            BufferedReader r = new BufferedReader(new FileReader("data/combined-column-line.xml"));

            String line = new String();

            while ((line = r.readLine()) != null) {
                xmlString += line;
            }
        } catch (IOException e) {
            System.err.println("IOException at Main.java");
            System.exit(0);
        }

        graph.setXML(xmlString);
        //graph.setXMLFromUrl("data/column-negative.xml");
        graph.setBeforeDrawFunction();
        graph.setAfterDrawFunction();
        graph.draw();

    }
    
    boolean mousePressed_ = false, mouseDragged_ = true;
    float dragStart = 0, dragEnd = 0;
    float downX = 0, downY = 0, upX = 0, upY = 0;

    public void mousePressed() {
        downX = mouseX;
        downY = mouseY;
        graph.mouseDownHandler(mouseX, mouseY);
    }

    public void mouseDragged() {
        graph.mouseDragHandler(downX, downY, mouseX, mouseY);
    }

    public void mouseReleased() {
        graph.mouseUpHandler(mouseX, mouseY);
    }

    public void mouseMoved() {
        graph.mouseMoveHandler(mouseX, mouseY);

    }

    public void draw() {
    }
}