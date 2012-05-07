/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.keremet.datavisualization;

/**
 *
 * @author Владелец
 */
public class UserEvent {
    /*@js var func; @js*/
    boolean flag = true;
    public UserEvent(/*@js func @js*/ ) {
        /*@js this.func = func; @js*/
    }
    
    public void fire() {
        /*@js func(); @js*/
        flag = false;
    }
    
    public boolean getFlag() {
        return flag;
    }
}
