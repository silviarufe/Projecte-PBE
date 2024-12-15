document.addEventListener("DOMContentLoaded", function () {
    const welcomeMessage = document.getElementById("welcomeMessage");
    const filterInput = document.getElementById("filterInput");
    const sendButton = document.getElementById("sendButton");
    const dataTable = document.getElementById("dataTable");
    const logoutButton = document.getElementById("logoutButton");

    // Inicialitzem el RutaManager
    const rutaManager = new RutaManager();

    // Verifiquem si l'usuari està autenticat
    rutaManager.redirectToLogin();  // Si no està autenticat, redirigeix a login

    const userName = rutaManager.username;
    
    // Comprova si tenim el nom d'usuari a localStorage
    if (userName) {
        welcomeMessage.textContent = `Welcome ${userName.split(" ")[0]}!`;
    } else {
        welcomeMessage.textContent = "Welcome, guest!";
    }

    // Funció per crear una fila a la taula
    function createTableRow(cells, isHeader = false) {
        const row = document.createElement("tr");
        cells.forEach(cellText => {
            const cell = isHeader ? document.createElement("th") : document.createElement("td");
            cell.textContent = cellText;
            row.appendChild(cell);
        });
        return row;
    }

    // Funció per mostrar dades a la taula
    function displayDataInTable(data) {
        // Netejar la taula
        dataTable.innerHTML = "";

        // Obtenim les claus i el número màxim de files
        const keys = Object.keys(data);
        if (keys.length === 0) {
            dataTable.innerHTML = "<tr><td>No data available</td></tr>";
            return;
        }
        const maxRows = Math.max(...keys.map(key => data[key].length));

        // Afegim la capçalera
        const headerRow = createTableRow(keys, true);
        dataTable.appendChild(headerRow);

        // Afegim les files
        for (let i = 0; i < maxRows; i++) {
            const rowCells = keys.map(key => data[key][i] || ""); // Evitar valors nulls
            const row = createTableRow(rowCells);
            dataTable.appendChild(row);
        }
    }

    // Funció per fer una consulta a la taula
    async function queryTable(filter) {
        try {

            // Realitzem la consulta passant el nom de la taula i el filtre
            rutaManager.queryTable(filter, displayDataInTable, (error) => {
                console.error("Error querying table:", error);
                alert("Error al realitzar la consulta. Torna-ho a provar.");
            });
        } catch (error) {
            console.error("Error en la connexió:", error.message);
            alert("Error en la connexió. Torna-ho a provar.");
        }
    }

    // Assignem l'esdeveniment al botó de "Send"
    sendButton.addEventListener("click", () => {
        const filterText = filterInput.value.trim();
        if (filterText) {
            queryTable(filterText); // Passant el filtre correcte
        } else {
            alert("Please enter a valid filter.");
        }
    });

    // Assignem l'esdeveniment al botó de "Logout"
    logoutButton.addEventListener("click", () => {
        alert("You have logged out.");
        window.location.href = "login.html"; // Exemple de redirecció
    });
});
