create schema tienda;

CREATE TABLE tienda.Cliente (
  id_cliente SERIAL PRIMARY KEY,
	tipo_identificacion VARCHAR(10) NOT NULL CHECK (tipo_identificacion IN ('CEDULA', 'RUC', 'PASAPORTE')),
  identificacion VARCHAR(13) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  direccion TEXT,
  telefono VARCHAR(20),
  email VARCHAR(255) UNIQUE NOT NULL,
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP,
	UNIQUE (tipo_identificacion, identificacion)
);

CREATE TABLE tienda.Tipo_Producto (
  id_tipo_producto SERIAL PRIMARY KEY,
  nombre VARCHAR(100) UNIQUE NOT NULL,
  descripcion TEXT,
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP
);

CREATE TABLE tienda.Proveedor (
  id_proveedor SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  contacto VARCHAR(100),
  telefono VARCHAR(20),
  direccion TEXT,
  email VARCHAR(255),
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP
);

CREATE TABLE tienda.Producto (
  id_producto SERIAL PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  precio DECIMAL(10, 2) NOT NULL CHECK (precio >= 0),
  costo DECIMAL(10, 2) CHECK (costo >= 0),
  id_tipo_producto INT NOT NULL,
  id_proveedor INT NOT NULL,
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP,
  FOREIGN KEY (id_tipo_producto) REFERENCES tienda.Tipo_Producto(id_tipo_producto),
  FOREIGN KEY (id_proveedor) REFERENCES tienda.Proveedor(id_proveedor)
);

CREATE TABLE tienda.Inventario (
  id_inventario SERIAL PRIMARY KEY,
  id_producto INT UNIQUE NOT NULL,
  cantidad INT NOT NULL CHECK (cantidad >= 0),
	activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP,
  FOREIGN KEY (id_producto) REFERENCES tienda.Producto(id_producto)
);

CREATE TABLE tienda.Factura (
  id_factura SERIAL PRIMARY KEY,
  id_cliente INT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado VARCHAR(20) DEFAULT 'PENDIENTE' CHECK (estado IN ('PENDIENTE', 'PAGADA', 'ANULADA')),
  subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
  impuesto DECIMAL(10, 2) DEFAULT 0 CHECK (impuesto >= 0),
  total DECIMAL(10, 2) NOT NULL CHECK (total >= 0),
  activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  actualizado_en TIMESTAMP,
  FOREIGN KEY (id_cliente) REFERENCES tienda.Cliente(id_cliente)
);

CREATE TABLE tienda.Detalle_Factura (
  id_detalle SERIAL PRIMARY KEY,
  id_factura INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL CHECK (cantidad > 0),
  precio_unitario DECIMAL(10, 2) NOT NULL CHECK (precio_unitario >= 0),
  subtotal_linea DECIMAL(10, 2) NOT NULL CHECK (subtotal_linea >= 0),
	activo BOOLEAN DEFAULT TRUE,
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	actualizado_en TIMESTAMP,
  FOREIGN KEY (id_factura) REFERENCES tienda.Factura(id_factura),
  FOREIGN KEY (id_producto) REFERENCES tienda.Producto(id_producto)
);
