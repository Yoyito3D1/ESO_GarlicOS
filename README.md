# Sistema Operativo GARLIC 2.0 para NDS 🕹️🍄

Aquest projecte és una implementació bàsica del sistema operatiu **GARLIC 2.0** per la consola Nintendo DS, programat en C i totalment desenvolupat per ARM. Utilitza la biblioteca GARLIC API per gestionar processos, interrupcions i recursos de la consola.

---

## 🚀 Característiques principals

- Inicialització del sistema gràfic i sistema de fitxers.
- Gestió de timers i interrupcions (VBlank i TIMER0).
- Monitorització i impressió de l'ús de la CPU per diferents processos.
- Càrrega i execució de programes "HOLA" i "PONG" segons la tecla que es premi (A o B).
- Creació i gestió de fins a 3 processos simultanis.
- Eliminació controlada de processos després d'un temps específic.
- Espera i sincronització amb el refresc vertical (VBlank).
- Funcions específiques per a visualització i control gràfic de l'estat del sistema.

---

## 🛠️ Estructura i funcionalitats del codi

- **`inicializarSistema()`**: Inicialitza gràfics, llavors aleatòries, sistema de fitxers i configuració d’interrupcions.
- **`porcentajeUso()`**: Mostra per consola l’ús de CPU de cada procés, sincronitzant amb TIMER0.
- **`main()`**:
  - Inicialitza el sistema.
  - Mostra missatges d'inici i instruccions per l'usuari.
  - Detecta si es prem la tecla A o B.
  - Carrega i crea processos dels programes corresponents.
  - Gestiona el cicle de vida dels processos (espera, eliminació).
  - Manté el sistema en execució en un bucle infinit.

---

## 📋 Com utilitzar

1. Compilar el projecte per la plataforma NDS amb el compilador ARM adequat.
2. Copiar els fitxers binaris dels programes `HOLA` i `PONG` al sistema de fitxers.
3. Executar el sistema a la NDS.
4. Prem la tecla:
   - **A** per carregar i executar tres instàncies del programa "HOLA".
   - **B** per carregar i executar tres instàncies del programa "PONG".
5. El sistema mostra l’ús de CPU i elimina processos automàticament després del temps definit.
6. El sistema queda en un estat d'espera indefinida al final.

---

## 🔧 Requisits i dependències

- Nintendo DS o emulador compatible.
- GARLIC API i sistema Garlic (basat en ARM).
- Fitxers de programa `HOLA` i `PONG` disponibles en el sistema de fitxers.

---

## 📚 Referències

Aquest sistema és una pràctica educativa d’un sistema operatiu simplificat per entorns embeguts amb recursos limitats, utilitzant interrupcions, multitarea i gestió bàsica de processos.

---

## 🎯 Objectiu

Demostrar gestió bàsica de processos, sincronització per interrupcions i utilització dels recursos de la consola Nintendo DS mitjançant un sistema operatiu propi.

---

## 📝 Notes

Aquest projecte està totalment desenvolupat en ARM amb suport per GARLIC API, i no inclou codi en altres llenguatges. Ideal per qui vulgui aprendre sobre sistemes operatius embeguts i programació a baix nivell en consoles portàtils.

---

## 💡 Contacte

Per dubtes o consultes, obre un issue o contacta amb el desenvolupador.

---

**Gaudeix programant! 🍄✨**
