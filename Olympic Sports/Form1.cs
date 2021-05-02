using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using System.Configuration;


namespace Olimpic_Sport
{
    public partial class Form1 : Form
    {
        OracleConnection con = null;
        public Form1()
        {
            this.setConnection();
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            this.updateDataGrid();
        }
        private void updateDataGrid()
        {
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = "SELECT * FROM population";
            cmd.CommandType = CommandType.Text;
            OracleDataReader dr = cmd.ExecuteReader();
            DataTable dt = new DataTable();
            dt.Load(dr);
            dataGridView1.DataSource = dt.DefaultView;
            dr.Close();
        }
        private void setConnection()
        {
            String connectionString = ConfigurationManager.ConnectionStrings["myConnectionString"].ConnectionString;
            con = new OracleConnection(connectionString);
            try
            {
                con.Open();
            }
            catch (Exception exp) { }
        }

        private void AUD(string sql_stml, int state) {
            String msg = "";
            OracleCommand cmd = con.CreateCommand();
            cmd.CommandText = sql_stml;
            cmd.CommandType = CommandType.Text;

            switch (state) {
                case 0:
                    msg = "Row Inserted Successfully";
                    cmd.Parameters.Add("COUNTRY", OracleDbType.Varchar2, 20).Value = tb_country.Text;
                    cmd.Parameters.Add("CODE", OracleDbType.Varchar2, 5).Value = tb_code.Text;
                    cmd.Parameters.Add("POPULATION", OracleDbType.Int32, 20).Value = Int32.Parse(tb_population.Text);
                    cmd.Parameters.Add("GDP_PER_CAPITA", OracleDbType.Int32, 20).Value = Int32.Parse(tb_country.Text);
                    break;
                case 1:
                    msg = "Row Updated Successfully";
                    cmd.Parameters.Add("CODE", OracleDbType.Varchar2, 5).Value = tb_code.Text;
                    cmd.Parameters.Add("POPULATION", OracleDbType.Int32, 20).Value = Int32.Parse(tb_population.Text);
                    cmd.Parameters.Add("GDP_PER_CAPITA", OracleDbType.Int32, 20).Value = Int32.Parse(tb_country.Text);
                    cmd.Parameters.Add("COUNTRY", OracleDbType.Varchar2, 20).Value = tb_country.Text;
                    break;
                case 2:
                    msg = "Row Deleted Successfully";
                    cmd.Parameters.Add("COUNTRY", OracleDbType.Varchar2, 20).Value = tb_country.Text;
                    break;
            }
            try {
                int n = cmd.ExecuteNonQuery();
                if (n > 0)
                {
                    MessageBox.Show(msg);
                    this.updateDataGrid();
                }
            }
            catch (Exception ex) { }
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }
        
        private void resetAll()
        {
            tb_country.Text = "";
            tb_code.Text = "";
            tb_population.Text = "";
            tb_gdp.Text = "";
            
            btn_add.Enabled = true;
            btn_update.Enabled = false;
            btn_delete.Enabled = false;
        }

        private void btn_reset_Click(object sender, EventArgs e)
        {
            this.resetAll();
        }

        private void btn_delete_Click(object sender, EventArgs e)
        {
            String sql = "DELETE FROM POPULATION " +
                "WHERE COUNTRY = :COUNTRY";
            this.AUD(sql, 2);
            this.resetAll();
        }

        private void btn_update_Click(object sender, EventArgs e)
        {
            String sql = "UPDATE POPULATION SET CODE = :CODE," +
               "POPULATION=:POPULATION, GDP_PER_CAPITA=:GDP_PER_CAPITA " +
               "WHERE COUNTRY = :COUNTRY";
            this.AUD(sql, 1);
        }

        private void btn_add_Click(object sender, EventArgs e)
        {
            String sql = "INSERT INTO POPULATION(COUNTRY, CODE, POPULATION, GDP_PER_CAPITA) " +
               "VALUES(:COUNTRY, :CODE, :POPULATION, :GDP_PER_CAPITA)";
            this.AUD(sql, 0);
            btn_add.Enabled = false;
            btn_update.Enabled = true;
            btn_delete.Enabled = true;
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {
            DataGrid dg = sender as DataGrid;
            DataRowView dr = (DataRowView)dg.SelectedItem as DataRowView;
            if (dr != null)
            {
                tb_country.Text = dr["COUNTY"].ToString();
                tb_code.Text = dr["CODE"].ToString();
                tb_population.Text = dr["POPULATION"].ToString();
                tb_gdp.Text = dr["GDP_PER_CAPITA"].ToString();

                btn_add.Enabled = false;
                btn_update.Enabled = true;
                btn_delete.Enabled = true;

            }
        }
    }
}
