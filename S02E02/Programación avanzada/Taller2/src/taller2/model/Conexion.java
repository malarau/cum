
package taller2.model;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.swing.JOptionPane;

/**
 *
 * @author Desde LMS
 */

public class Conexion {
    public static String Usuario="root";
    public static String Clave="/PC0m9](rn!B]paZ";
    public static String Url="jdbc:mysql://127.0.0.1:3306/rau";
    public static Connection Conn;
    
    //Método conexión 
    public static Connection ConectarBD(){
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); 
            Conn=DriverManager.getConnection(Url, Usuario, Clave );
            System.out.println("Conexion establecida");
        } catch (ClassNotFoundException | SQLException ex) {
            Conn=null;
            JOptionPane.showMessageDialog(null, ex,"Error",0);
        } 
        return Conn;
    }
}
