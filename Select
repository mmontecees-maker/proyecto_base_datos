--INSERT

--1) Top 5 clientes por monto pagado (solo pagos activos)
--Enunciado:
--El negocio quiere premiar a los clientes que más han pagado. Calcula el total pagado por cada cliente (solo pagos activo = TRUE), y muestra nombres, apellidos, email y el total pagado, ordenado de mayor a menor. Usa un CTE.


WITH TotalPagosClientes AS (
    SELECT 
        c.nombres, 
        c.apellidos, 
        c.email, 
        SUM(p.monto) AS total_pagado
    FROM Vmoran.clientes c
    INNER JOIN Vmoran.citas ci ON c.id_cliente = ci.id_cliente
    INNER JOIN Vmoran.pagos p ON ci.id_cita = p.id_cita
    WHERE p.activo = TRUE  -- Solo consideramos pagos activos
    GROUP BY c.id_cliente, c.nombres, c.apellidos, c.email
)
SELECT 
    nombres, 
    apellidos, 
    email, 
    total_pagado
FROM TotalPagosClientes
ORDER BY total_pagado DESC
LIMIT 5;

--2) Servicios más solicitados y su ingreso estimado (detalle de cita)
--Enunciado:
--Dirección quiere saber qué servicios son los más demandados y cuánto se factura por ellos. Para cada servicio, calcula: número de atenciones (filas de detalle_cita) y el ingreso estimado (sumando precio_aplicado), considerando citas y detalles activos. Agrega ranking por demanda y por ingreso con funciones de ventana.


WITH EstadisticasServicios AS (
    SELECT 
        s.nombre AS servicio,
        COUNT(dc.id_detalle) AS numero_atenciones,
        SUM(dc.precio_aplicado) AS ingreso_estimado
    FROM Vmoran.servicios s
    INNER JOIN Vmoran.detalle_cita dc ON s.id_servicio = dc.id_servicio
    INNER JOIN Vmoran.citas c ON dc.id_cita = c.id_cita
    WHERE s.activo = TRUE 
      AND dc.activo = TRUE 
      AND c.activo = TRUE
    GROUP BY s.id_servicio, s.nombre
)
SELECT 
    servicio,
    numero_atenciones,
    ingreso_estimado,
    RANK() OVER (ORDER BY numero_atenciones DESC) AS ranking_demanda,
    RANK() OVER (ORDER BY ingreso_estimado DESC) AS ranking_ingreso
FROM EstadisticasServicios
ORDER BY ranking_demanda ASC;



--3) Agenda del día: citas programadas por empleado (con hora y cliente)
--Enunciado:
--El coordinador quiere ver la agenda del día: lista las citas con estado = 'Programada' para la fecha actual, mostrando empleado, cliente, hora y servicio(s) asociados. Ordena por empleado y hora.

WITH AgendaDelDia AS (
    SELECT 
        e.nombres || ' ' || e.apellidos AS empleado,
        cl.nombres || ' ' || cl.apellidos AS cliente,
        c.hora,
        s.nombre AS servicio,
        e.id_empleado
    FROM Vmoran.citas c
    INNER JOIN Vmoran.empleados e ON c.id_empleado = e.id_empleado
    INNER JOIN Vmoran.clientes cl ON c.id_cliente = cl.id_cliente
    INNER JOIN Vmoran.detalle_cita dc ON c.id_cita = dc.id_cita
    INNER JOIN Vmoran.servicios s ON dc.id_servicio = s.id_servicio
    WHERE c.estado = 'Programada'
      AND c.fecha = CURRENT_DATE  
      AND c.activo = TRUE
      AND dc.activo = TRUE
)
SELECT 
    empleado,
    cliente,
    hora,
    STRING_AGG(servicio, ', ') AS servicios_solicitados
FROM AgendaDelDia
GROUP BY empleado, cliente, hora, id_empleado
ORDER BY empleado, hora;


--4) Tasa de conversión de citas a pagos por mes
--Enunciado:
--Gerencia quiere medir la conversión mensual: de todas las citas activas por mes, ¿cuántas terminaron con al menos un pago? Muestra por mes: total de citas, citas con pago y porcentaje de conversión.

WITH ResumenMensual AS (
    SELECT 
        DATE_TRUNC('month', c.fecha) AS mes,
        COUNT(c.id_cita) AS total_citas,
        COUNT(p.id_pago) AS citas_con_pago
    FROM Vmoran.citas c
    LEFT JOIN Vmoran.pagos p ON c.id_cita = p.id_cita AND p.activo = TRUE
    WHERE c.activo = TRUE
    GROUP BY DATE_TRUNC('month', c.fecha)
)
SELECT 
    TO_CHAR(mes, 'YYYY-MM') AS periodo,
    total_citas,
    citas_con_pago,
    CASE 
        WHEN total_citas > 0 THEN 
            ROUND((citas_con_pago::NUMERIC / total_citas::NUMERIC) * 100, 2)
        ELSE 0 
    END AS porcentaje_conversion
FROM ResumenMensual
ORDER BY mes DESC;

--5) Auditoría: citas atendidas sin pago o con pago incompleto
--Enunciado:
--Contabilidad necesita detectar citas con estado = 'Atendida' que: (a) no tienen pagos, o (b) tienen pagos por debajo del total estimado del servicio (suma de precio_aplicado en el detalle). Muestra cliente, fecha/hora, total estimado, total pagado y la diferencia.

WITH ResumenDetalle AS (
    SELECT 
        id_cita,
        SUM(precio_aplicado) AS total_estimado
    FROM Vmoran.detalle_cita
    WHERE activo = TRUE
    GROUP BY id_cita
),
ResumenPagos AS (
    SELECT 
        id_cita,
        SUM(monto) AS total_pagado
    FROM Vmoran.pagos
    WHERE activo = TRUE
    GROUP BY id_cita
)
SELECT 
    cl.nombres || ' ' || cl.apellidos AS cliente,
    ci.fecha,
    ci.hora,
    COALESCE(rd.total_estimado, 0) AS total_estimado,
    COALESCE(rp.total_pagado, 0) AS total_pagado,
    (COALESCE(rd.total_estimado, 0) - COALESCE(rp.total_pagado, 0)) AS diferencia
FROM Vmoran.citas ci
JOIN Vmoran.clientes cl ON ci.id_cliente = cl.id_cliente
LEFT JOIN ResumenDetalle rd ON ci.id_cita = rd.id_cita
LEFT JOIN ResumenPagos rp ON ci.id_cita = rp.id_cita
WHERE ci.estado = 'Atendida' 
  AND ci.activo = TRUE
  AND (
    rp.total_pagado IS NULL                
    OR rp.total_pagado < rd.total_estimado 
  )
ORDER BY ci.fecha DESC;
