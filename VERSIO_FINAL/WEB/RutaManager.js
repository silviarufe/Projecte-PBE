class RutaManager {
    constructor() {
        this.ipPort = localStorage.getItem("ipPort");
        this.username = localStorage.getItem("username");
        this.pasword = localStorage.getItem("pasword");
        this.connexio = this.ipPort ? new Connexio(this.ipPort) : null;
    }

    // Comprova si l'usuari està autenticat
    isAuthenticated() {
        return this.username !== null && this.pasword !== null;
    }

    // Recupera la connexió
    getConnexio() {
        if (!this.connexio) {
            throw new Error("Connexió no inicialitzada.");
        }
        return this.connexio;
    }

    // Autenticació de l'usuari
    authenticateUser(uid, onSuccess, onError) {
        const connexio = this.getConnexio();
        connexio.authenticateUser(uid, onSuccess, onError);
    }

    // Recuperar les dades de la taula
    queryTable(nomTaula, onSuccess, onError) {
        const connexio = this.getConnexio();
        connexio.queryTable(nomTaula, onSuccess, onError);
    }

    // Comprova si tenim la connexió disponible
    checkConnexio() {
        if (!this.isAuthenticated()) {
            throw new Error("Usuari no autenticat. Redirigint a la pàgina de login.");
        }
    }

    // Redirecció a la pàgina de login si no està autenticat
    redirectToLogin() {
        if (!this.isAuthenticated()) {
            window.location.href = "login.html"; // Redirigeix si no està autenticat
        }
    }
}
