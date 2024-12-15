class Connexio {
    constructor(url) {
        this.BASE_URL = url; // Especifica la URL del servidor
    }

    // Petición HTTP GET
    fetchData(path, params = {}, onSuccess, onError, onException) {
        const url = new URL(this.BASE_URL + path);

        // Asegurarse que todos los parámetros sean cadenas y sean agregados correctamente a la URL
        Object.keys(params).forEach(key => {
            // Convierte el valor del parámetro en cadena si no lo es
            let value = params[key];
            if (typeof value !== 'string') {
                value = String(value); // Convertir a cadena
            }
            url.searchParams.append(key, value);
        });

        // Verifica que la URL final es la correcta
        console.log("URL construida:", url.toString());  // Agregado para depurar

        // Realiza la petición HTTP
        fetch(url)
            .then(response => {
                if (response.ok) {
                    return response.json(); // Retorna el JSON si la respuesta es correcta
                } else {
                    throw new Error(`Error: ${response.status} - ${response.statusText}`);
                }
            })
            .then(data => {
                onSuccess(data);  // Si la respuesta es correcta, llama a onSuccess
            })
            .catch(error => {
                if (onException) {
                    onException("Error al conectar con el servidor: " + error.message);
                } else {
                    onError(error.message);
                }
            });
    }

    // Processar las datos y retornarlas en un formato adecuado
    processData(data, selectedColumns) {
        const result = selectedColumns.reduce((acc, column) => {
            acc[column] = [];
            return acc;
        }, {});

        data.forEach(row => {
            selectedColumns.forEach(column => {
                if (row.hasOwnProperty(column)) {
                    let value = row[column];
                    if (column === 'date') {
                        value = this.formatDate(value); // Formatear la fecha
                    }
                    result[column].push(value);
                }
            });
        });

        return result;
    }

    // Formato de la fecha (YY-MM-DD)
    formatDate(date) {
        return date.length >= 10 ? date.substring(0, 10) : date;
    }

    // Autentificar al usuario
    authenticateUser(uid, onSuccess, onError) {
        this.fetchData(
            "/authenticate",
            { uid: String(uid) }, // Asegúrate de convertir el uid en cadena
            data => {
                if (data && data.name) {
                    onSuccess(data.name); // Retorna el nombre del usuario
                } else {
                    onError("Error de autenticación. Vuelve a intentarlo.");
                }
            },
            onError,
            (exception) => {
                onError("Error al conectar con el servidor: " + exception);
            }
        );
    }

    // Consultar la tabla
    queryTable(nomTaula, onSuccess, onError) {
        let params = {};
        let table = null;

        if (!nomTaula.includes("?")) {
            table = nomTaula;
        } else {
            const parts = nomTaula.split("?", 2);
            table = parts[0];
            params = this.parseFilters(parts[1]);
        }

        if (!table) {
            onError("Error: tabla desconocida.");
            return;
        }

        params.table = table;

        this.fetchData(
            "/query",
            params,
            data => {
                if (Array.isArray(data)) {
                    let result;
                    switch (table) {
                        case "timetables":
                            result = this.processData(data, ["day", "hour", "Subject", "Room"]);
                            break;
                        case "tasks":
                            result = this.processData(data, ["date", "subject", "name"]);
                            break;
                        case "marks":
                            result = this.processData(data, ["Subject", "Name", "Marks"]);
                            break;
                        default:
                            onError("Error: tabla desconocida.");
                            return;
                    }

                    if (Object.keys(result).length > 0) {
                        onSuccess(result);
                    } else {
                        onError("No hay datos disponibles para la tabla " + table);
                    }
                } else {
                    onError("Respuesta inesperada del servidor.");
                }
            },
            onError
        );
    }

    // Parsear filtros
    parseFilters(filterString) {
        const filters = {};
        if (filterString) {
            const pairs = filterString.split("&");
            pairs.forEach(pair => {
                const [key, value] = pair.split("=");
                if (key && value) {
                    filters[key] = value;
                }
            });
        }
        return filters;
    }
}

// Ejemplos de funciones de callback (pueden ser usadas en la aplicación web)

function onSuccess(result) {
    console.log("Datos obtenidos:", result);
}

function onError(error) {
    console.log("Error:", error);
}

function onException(exception) {
    console.log("Excepción:", exception);
}

// Ejemplo de uso
const connexio = new Connexio("http://198.162.1.1:3001"); // URL de la API

// Autentificar usuario
connexio.authenticateUser("1234", 
    name => console.log("Usuario autenticado:", name),
    error => console.log(error)
);

// Consultar tabla
connexio.queryTable("timetables", 
    data => console.log("Tabla de horarios:", data),
    error => console.log(error)
);
