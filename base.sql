
create schema Vmoran;

--CLIENTES
CREATE TABLE Vmoran.clientes (
    id_cliente serial PRIMARY KEY,
    identificacion VARCHAR(15) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);



--EMPLEADOS
CREATE TABLE Vmoran.empleados (
    id_empleado serial PRIMARY KEY,
    identificacion VARCHAR(15) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    especialidad VARCHAR(100),
    telefono VARCHAR(20),
    email VARCHAR(150) UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);


--SERVICIOS 
CREATE TABLE Vmoran.servicios (
    id_servicio serial PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_minutos INT NOT NULL CHECK (duracion_minutos > 0),
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP
);



--(TABLAS TRANSACICONALES)
--CITAS
CREATE TABLE Vmoran.citas (
    id_cita serial PRIMARY KEY,
    id_cliente int NOT NULL,
    id_empleado int NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('Programada', 'Atendida', 'Cancelada')),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP,

    CONSTRAINT fk_citas_cliente FOREIGN KEY (id_cliente) REFERENCES Vmoran.clientes(id_cliente),
    CONSTRAINT fk_citas_empleado FOREIGN KEY (id_empleado) REFERENCES Vmoran.empleados(id_empleado)
);


--DETALLE_CITA
CREATE TABLE Vmoran.detalle_cita (
    id_detalle serial PRIMARY KEY,
    id_cita int NOT NULL,
    id_servicio int NOT NULL,
    precio_aplicado NUMERIC(10,2) NOT NULL CHECK (precio_aplicado >= 0),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP,

    CONSTRAINT fk_detalle_cita FOREIGN KEY (id_cita) REFERENCES Vmoran.citas(id_cita),

    CONSTRAINT fk_detalle_servicio FOREIGN KEY (id_servicio) REFERENCES Vmoran.servicios(id_servicio)
);


--PAGOS
CREATE TABLE Vmoran.pagos (
    id_pago serial PRIMARY KEY,
    id_cita int NOT NULL,
    fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago VARCHAR(30) NOT NULL CHECK (metodo_pago IN ('Efectivo', 'Tarjeta', 'Transferencia')), 
    monto NUMERIC(10,2) NOT NULL CHECK (monto >= 0),
    activo BOOLEAN DEFAULT TRUE,
    creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP,

    CONSTRAINT fk_pagos_cita FOREIGN KEY (id_cita) REFERENCES Vmoran.citas(id_cita)
);
