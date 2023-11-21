
package taller2.model;

import java.sql.Connection;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import javax.swing.JOptionPane;
import javax.swing.table.DefaultTableModel;

/**
 *
 * @author Desde LMS
 */

//COPIADO Y MODIFICADO DESDE LMS
public class Metodos_BD {
    
    public PreparedStatement Pstmt;
    public ResultSet Rs;
    
    public void addClient(Client client){
        Connection Conn;
        String Sentencia;
        Sentencia="Insert Into Cliente (RUT, Nombre, Apellido, Sector, Estado) Values ('"+client.getRUT()+"','"
                  + ""+client.getNombre()+"','"+client.getApellido()+"','"+client.getSector()+"','"+ client.getEstado() +"')";
        try {
            Conn = Conexion.ConectarBD();
            Pstmt = Conn.prepareStatement(Sentencia);
            Pstmt.executeUpdate();
            Pstmt.close();
            Conn.close();
            JOptionPane.showMessageDialog(null, "Usuario ingresado","Sistema",1);
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null, ex,"Error",0);
        }
    }

    public String[] searchClient(String RUT){
        Connection Conn;
        String Datos[] = null;
        String SentenciaSelect;
        SentenciaSelect="SELECT Nombre, Apellido, Sector, Estado "
                        + "FROM cliente "
                        + "WHERE RUT = '"+ RUT +"';";
        try {            
            Conn=Conexion.ConectarBD();
            Pstmt= Conn.prepareStatement(SentenciaSelect);
            Rs=Pstmt.executeQuery();
            if (Rs.next()) {
                Datos= new String[4];
                Datos[0] = Rs.getString("Nombre");
                Datos[1] = Rs.getString("Apellido");
                Datos[2] = Rs.getString("Sector");
                Datos[3] = Rs.getString("Estado");
            } else {
                JOptionPane.showMessageDialog(null, "Persona no Existe","Error",0);
            }
            Pstmt.close();
            Conn.close();
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null, ex,"Error",0);  
        }
        return Datos;
    }
    
    public void modifyClient(Client client){
        Connection Conn;
        String SentenciaUpdate;
        SentenciaUpdate="UPDATE cliente "
                        + "SET Nombre = '"+ client.getNombre() +"', Apellido = '"+ client.getApellido() +"',"
                        + "Sector = '"+ client.getSector() +"', Estado = '"+ client.getEstado() +"' "
                        + "WHERE RUT = '"+client.getRUT()+"';";
        try {
            Conn = Conexion.ConectarBD();
            Pstmt = Conn.prepareStatement(SentenciaUpdate);
            Pstmt.executeUpdate();
            Pstmt.close();
            Conn.close();
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null, ex,"Error",0);
        }
    }

    public void filterBySector(DefaultTableModel Tabla, String sector){
        System.out.println("Sector: "+ sector);
        Connection Conn;
        String SentenciaSelect;
        SentenciaSelect = "SELECT RUT, Nombre, Apellido FROM cliente WHERE Sector = '" 
                + sector +"';";
        try {
            Conn = Conexion.ConectarBD();
            Pstmt = Conn.prepareStatement(SentenciaSelect);
            Rs = Pstmt.executeQuery();
            while(Rs.next()){
                Tabla.addRow(new String[]{Rs.getString("RUT"),
                                            Rs.getString("Nombre"),
                                            Rs.getString("Apellido"),
                                            sector});
            }
            Pstmt.close();
            Conn.close();
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null, ex);
        }
    }
    
    public void filterByStatus(DefaultTableModel Tabla, String status){
        Connection Conn;
        String SentenciaSelect;
        SentenciaSelect = "SELECT RUT, Nombre, Apellido, Sector FROM cliente WHERE Estado = '" 
                + status +"';";
        try {
            Conn = Conexion.ConectarBD();
            Pstmt = Conn.prepareStatement(SentenciaSelect);
            Rs = Pstmt.executeQuery();
            while(Rs.next()){
                Tabla.addRow(new String[]{Rs.getString("RUT"),
                                            Rs.getString("Nombre"),
                                            Rs.getString("Apellido"),
                                            Rs.getString("Sector")});
            }
            Pstmt.close();
            Conn.close();
        } catch (SQLException ex) {
            JOptionPane.showMessageDialog(null, ex);
        }
    }
    
    /*    
    //Método Eliminar
    // NO SE USA, DADO QUE NO ESTÁ ENTRE LO SOLICITADO
    public void Eliminar_Persona(Persona persona){
        Connection Conn;
        String SentenciaBuscar, SentenciaEliminar,NombreBD;
        SentenciaBuscar="Select Nombre From persona Where Rut='"+persona.getRut()+"'";
        SentenciaEliminar="Delete From persona Where Rut='"+persona.getRut()+"'";
        
   
        try {
            Conn=Conexion.ConectarBD();
            Pstmt=Conn.prepareStatement(SentenciaBuscar);
            Rs=Pstmt.executeQuery();
            if (Rs.next()) {
                NombreBD=Rs.getString("Nombre");
                Pstmt=Conn.prepareStatement(SentenciaEliminar);
                Pstmt.execute();
                JOptionPane.showMessageDialog(null, "Usuario: "+NombreBD+" eliminado","Sistema",1);
            } else {
                JOptionPane.showMessageDialog(null, "Usuario no encontrado","Error",0);
            }
            Pstmt.close();
            Conn.close();
        } catch (SQLException ex) {
           JOptionPane.showMessageDialog(null, ex,"Error",0);
        }
    }
    
    */
}
