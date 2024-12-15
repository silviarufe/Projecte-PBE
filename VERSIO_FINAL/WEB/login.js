document.addEventListener("DOMContentLoaded", function () {
    const loginForm = document.getElementById("loginForm");

    loginForm.addEventListener("submit", function (event) {
        event.preventDefault(); // Evita el comportament per defecte (canvi de URL i recàrrega de la pàgina)

        // Obtenim les dades del formulari (recorda que els camps estan invertits)
        const ipPort = document.getElementById("ip-port").value.trim();
        const password = document.getElementById("password").value.trim(); // El "password" conté el rfid
        const username = document.getElementById("username").value.trim(); // El "username" conté el user

        if (!ipPort || !username || !password) {
            alert("Tots els camps són obligatoris!");
            return;
        }

        // Inicialitzem el RutaManager
        const rutaManager = new RutaManager();

        // Intentem autenticar l'usuari
        rutaManager.authenticateUser(
            password,
            // Callback d'èxit
            (serverUsername) => {
                console.log("Nom d'usuari retornat pel servidor:", serverUsername);

                // Comprova si el nom d'usuari retornat pel servidor coincideix amb el del formulari
                if (serverUsername === username) {
                    alert("Usuari autenticat amb èxit!");

                    // Desa informació necessària al localStorage
                    localStorage.setItem("ipPort", ipPort);
                    localStorage.setItem("password", password);
                    localStorage.setItem("username", username);

                    // Redirigeix a la pàgina de taula
                    window.location.href = "taula.html";
                } else {
                    alert("Error: el nom d'usuari retornat pel servidor no coincideix amb el nom introduït.");
                }
            },
            // Callback d'error
            (error) => {
                console.error("Error d'autenticació:", error);
                alert("Error en l'autenticació. Torna-ho a provar.");
            }
        );
    });
});
