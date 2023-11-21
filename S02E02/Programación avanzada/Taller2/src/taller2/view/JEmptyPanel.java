/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package taller2.view;

import java.awt.BorderLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;

/**
 *
 * @author Matias Lara
 */
public class JEmptyPanel extends JPanel {

    public JEmptyPanel(String panelName) {
        super.setLayout(new BorderLayout());
        JLabel label = new JLabel("No disponible aún: "+panelName);
        label.setHorizontalAlignment(JLabel.CENTER);
        label.setVerticalAlignment(JLabel.CENTER);
        this.add(label, BorderLayout.CENTER);
    }
    
}
