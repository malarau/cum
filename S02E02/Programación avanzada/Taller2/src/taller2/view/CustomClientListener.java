/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package taller2.view;

import java.awt.event.ActionListener;

/**
 *
 * @author Matias Lara
 */
public interface CustomClientListener {
    
    public void setCustomAddListener(ActionListener addButtonListener);
    public void setCustomModifyListener(ActionListener addButtonListener);
    public void setCustomSearchListener(ActionListener addButtonListener);
    public void setCustomFilterListener(ActionListener addButtonListener);    
}
