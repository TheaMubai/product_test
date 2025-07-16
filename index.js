const express = require('express');
const cors = require('cors');
require('dotenv').config();
const { pool, poolConnect, sql } = require('./environment/config');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Product API is running...' });
});

app.get('/products', async (req, res) => {
  try {
    await poolConnect;
    const result = await pool.request().query('SELECT * FROM PRODUCTS');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/products/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await poolConnect;
    const result = await pool.request()
      .input('ID', sql.Int, id)
      .query('SELECT * FROM PRODUCTS WHERE PRODUCTID = @ID');

    if (result.recordset.length === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/products', async (req, res) => {
  const { PRODUCTNAME, PRICE, STOCK } = req.body;

  if (!PRODUCTNAME || PRICE <= 0 || STOCK <= 0) {
    return res.status(400).json({ message: 'Invalid input: name, price, and stock are required with valid values' });
  }

  try {
    await poolConnect;
    await pool.request()
      .input('PRODUCTNAME', sql.NVarChar, PRODUCTNAME)
      .input('PRICE', sql.Decimal(10, 2), PRICE)
      .input('STOCK', sql.Int, STOCK)
      .query(`INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK) VALUES (@PRODUCTNAME, @PRICE, @STOCK)`);

    res.status(201).json({ message: 'Product created' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/products/:id', async (req, res) => {
  const { PRODUCTNAME, PRICE, STOCK } = req.body;
  const { id } = req.params;

  if (!PRODUCTNAME || PRICE <= 0 || STOCK <= 0) {
    return res.status(400).json({ message: 'Invalid input: name, price, and stock are required with valid values' });
  }

  try {
    await poolConnect;
    const result = await pool.request()
      .input('ID', sql.Int, id)
      .input('PRODUCTNAME', sql.NVarChar, PRODUCTNAME)
      .input('PRICE', sql.Decimal(10, 2), PRICE)
      .input('STOCK', sql.Int, STOCK)
      .query(`UPDATE PRODUCTS SET PRODUCTNAME=@PRODUCTNAME, PRICE=@PRICE, STOCK=@STOCK WHERE PRODUCTID=@ID`);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }

    res.json({ message: 'Product updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/products/:id', async (req, res) => {
  const { id } = req.params;

  try {
    await poolConnect;
    const result = await pool.request()
      .input('ID', sql.Int, id)
      .query('DELETE FROM PRODUCTS WHERE PRODUCTID=@ID');

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({ message: 'Product not found' });
    }

    res.json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
