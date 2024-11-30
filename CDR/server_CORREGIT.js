//Versió corregida del servidor

const http = require('http');
const mysql = require('mysql2');
const url = require('url'); //necessari per tractar els paràmetres de consulta

// Configuración de la conexión con la base de datos
const connection = mysql.createConnection({
  host: '192.168.1.1', // Dirección IP de tu ordenador
  user: 'root',         // Usuario de MySQL
  password: '1234',     // Contraseña de MySQL
  database: 'pbe',      // Nombre de tu base de datos
  port: 3306            // Port de MySQL
});

// Verificar la conexión a la base de datos
connection.connect((err) => {
  if (err) {
    console.error('Error de conexión a la base de datos: ' + err.stack);
    return;
  }
  console.log('Conectado a la base de datos con el ID ' + connection.threadId);
});

//Gestionar sessions d'usuaris   
const userSessions = {};
//temps d'inactivitat en mil·lisegons (2 minut)
const SESSION_TIMEOUT = 2*60*1000;

// Crear el servidor HTTP
const server = http.createServer((req, res) => {
  res.setHeader('Content-Type', 'application/json'); 
  res.setHeader('Access-control-Allow-Origin', '*');

  const parsedUrl = url.parse(req.url, true); //parsear la URL
//    console.log(parsedUrl);

    if(req.method === 'GET' && parsedUrl.pathname === '/authenticate'){
        const {uid} = parsedUrl.query; //parsejar el cos de la solicitud per obtenir uid

        if(!uid){
            res.statusCode = 400;
            res.end(JSON.stringify({error: 'UID es necessari'}));
            return;
        }
        //consultar students per buscar uid
        connection.query(
            'SELECT name FROM students WHERE student_id = ?', //consulta MySQL
            [uid], // Parametre: UID rebut
            (err, results) => {
                if(err){ //control d'errors de consulta
                    console.error('Error al realitzar consulta:', err);
                    res.statusCode = 500; //codi d'error del servidor
                    res.end(JSON.stringify({error:'Error al realitzar la consulta'}));
                }else if(results.length===0){
                    //si no es troba a la taula
                    res.statusCode = 401; // Codi "no autoritzat"
                    res.end(JSON.stringify({error: 'UID no vàlid'}));
                }else{
                    //si uid vàlid, tornar el nom de l'estudiant
                    
                    userSessions[uid]={
                        name: results[0].name,
                        lastActivity: Date.now() //guarda hora de l'activitat
                    };
                    
                    res.statusCode = 200; // codi d'exit
                    res.end(JSON.stringify({name: results[0].name}));
                }
            }
        );
        //endpoint per realitzar consultes taules concretes
    }else if(req.method === 'GET' && parsedUrl.pathname === '/query'){
        const {table, limit, ...filters} = parsedUrl.query; //parsejar cos de la solicitud per obtenir la taula
        console.log("URL parseada final:", parsedUrl.href);

        //uid de la sessio
        const uid = Object.keys(userSessions).find((uid) => userSessions[uid]);

        if(!uid){
            res.statusCode = 600;
            res.end(JSON.stringify({error: 'Sessió no iniciada o caducada'}));
            return;
        }
        
        userSessions[uid].lastActivity=Date.now(); //actualitzar activitat

        
        //generar la consulta MySQL la taula solicitada filtrant per uid
        
        // --------- CONSTRAINTS --------- 
        let query = `SELECT * FROM ${table} WHERE student_id = ?`;
        const params = [uid];
        

        if(Object.keys(filters).length > 0){
            const conditions = [];
            const opMap = {
                gte: '>=',
                gt: '>',  
                lte: '<=',
                lt: '<',
                eq: '='
            };

            for( const [key, value] of Object.entries(filters)){
                if(key.includes('[') && key.includes(']')){
                    //treure el camp i l'operador
                    const field = key.split('[')[0];
                    const modifier = key.match(/\[(.+)\]/)[1];

                    const op = opMap[modifier];
                    if(op){
                        conditions.push(`${field} ${op} ?`);
                        params.push(value);
                    }else{
                        console.warn(`Modificador desconocido: ${modifier}`);
                    }
                } else if (value.toLowerCase()==='now'){
                    if(table === 'timetables'){
                        if(key === 'day'){
                            const currentDay = new Date().toLocaleDateString('en-US', {weekday: 'short'});
                            conditions.push(`${key} = ?`);
                            params.push(currentDay);
                        } else if (key === 'hour'){
                            // Convertir "now" a hora actual, pero solo con la hora (sin minutos y segundos)
                            const currentTime = new Date();
                            currentTime.setMinutes(0); // Poner los minutos a 0
                            currentTime.setSeconds(0); // Poner los segundos a 0
                            currentTime.setMilliseconds(0); // Poner los milisegundos a 0
                            const roundedHour = currentTime.toTimeString().split(' ')[0]; // Formato HH:00:00
                            conditions.push(`${key} = ?`);
                            params.push(roundedHour);
                        }
                    } else if (table === 'tasks'){
                        const currentDate = new Date().toISOString().split('T')[0];
                        conditions.push(`${key} = ?`);
                        params.push(currentDate);
                    
                    } else {
                        console.warn(`Campo "now" no soportado para la tabla ${table}`);
                    }
                    
                }else{
                    conditions.push(`${key} = ?`);
                    params.push(value);
                }   
            
            }
            query += ' AND '+conditions.join(' AND ');
        }

        if(limit){
            query += ' LIMIT ?';
            params.push(parseInt(limit, 10));
        }


        console.log("Consulta SQL generada:", query); // Verifica que la consulta sea correcta
        console.log("Parámetros:", params); // Verifica que los parámetros se pasen correctamente
        

        //consulta a la taula
        connection.query(query,params, (err, results) => {
            if (err){ //control d'errors de consulta
                console.error('Error al realitzar la consulta: ', err);
                res.statusCode = 500; // error del servidor
                res.end(JSON.stringify({error: 'Error al realitzar la consulta'}));
            }else{
                //tornar les dades de la consulta
                res.statusCode = 200; //codigo de exito
                    if(table === 'timetables'){
                        results = order(results);
                        console.log(results);
                    }
                res.end(JSON.stringify(results));
            }
        });
    }else if(req.method === 'GET' && parsedUrl.pathname === '/logout'){
        const uid = Object.keys(userSessions).find((uid) => userSessions[uid]);

        if(!uid){
            res.statusCode = 400;
            res.end(JSON.stringify({ error: 'Sessió no iniciada' }));
            return;
        }
        //esborrar la sessio de l'usuari
            delete userSessions[uid];
            res.statusCode = 200;
            res.end(JSON.stringify({ message: 'Sessió tancada correctament' }));
    
    
        // Ruta para obtener los estudiantes   
    } else {
        res.statusCode = 404;
        res.end(JSON.stringify({ error: 'Ruta no encontrada' }));
    }
    });

//Timer per gestionar les sessions
setInterval(() => {
    const now = Date.now();

    for(const uid in userSessions){
        if(now - userSessions[uid].lastActivity > SESSION_TIMEOUT){
            console.log(`Sessió de l'usuari ${uid} ha caducat`);
            delete userSessions[uid];
        }
    }
}, 60 * 1000);

// Escuchar en el puerto 3000
const PORT = 3000;
server.listen(PORT, '192.168.1.1', () => {
  console.log(`Servidor escuchando en http://192.168.1.1:${PORT}`);
});


function order(data){
    const now = new Date();
    const currentDay = now.toLocaleDateString('en-US', { weekday: 'short'}); // Dia de la setmana actual
    const currentHour = `${now.getHours().toString().padStart(2, '0')}:00:00`; //hora actual

    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const todayIndex = weekDays.indexOf(currentDay);

    return data.sort((a,b) => {
        const aDayIndex = weekDays.indexOf(a.day);
        const bDayIndex = weekDays.indexOf(b.day);

        const aDayPriority = (aDayIndex - todayIndex + weekDays.length)%weekDays.length;
        const bDayPriority = (bDayIndex - todayIndex + weekDays.length)%weekDays.length;

        if (aDayPriority !== bDayPriority){
            return aDayPriority - bDayPriority;
        }

        const aTime = new Date(`1970-01-01T${a.hour}Z`);
        const bTime = new Date(`1970-01-01T${b.hour}Z`);

        if(aDayPriority === 0){
            const currentHourTime = new Date(`1970-01-01T${currentHour}Z`).getTime();
            if(aTime < currentHourTime && bTime >= currentHourTime){
                return 1;
            }
            if(bTime < currentHourTime && aTime >= currentHourTime){
                return -1;
            }
        }
        return aTime - bTime;
    });

}

