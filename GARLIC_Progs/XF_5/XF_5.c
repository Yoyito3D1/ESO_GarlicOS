#include <GARLIC_API.h>            /* definició de les funcions API de GARLIC */

void vigenereEncrypt(char* mensaje, char* clave, char* cifrado) {
    int i, j = 0, clave_len = 0;
    while (clave[clave_len] != '\0') clave_len++;
    
    for (i = 0; mensaje[i] != '\0'; i++) {
        cifrado[i] = ((mensaje[i] - 'a') + (clave[j] - 'a'));
        if (cifrado[i] >= 26) cifrado[i] -= 26;
        cifrado[i] += 'a';
        j++;
        if (j == clave_len) j = 0;
    }
    cifrado[i] = '\0';
}

void vigenereDecrypt(char* cifrado, char* clave, char* descifrado) {
    int i, j = 0, clave_len = 0;
    while (clave[clave_len] != '\0') clave_len++;
    
    for (i = 0; cifrado[i] != '\0'; i++) {
        descifrado[i] = ((cifrado[i] - 'a') - (clave[j] - 'a') + 26);
        if (descifrado[i] >= 26) descifrado[i] -= 26;
        descifrado[i] += 'a';
        j++;
        if (j == clave_len) j = 0;
    }
    descifrado[i] = '\0';
}

int _start(int arg) {
    if (arg < 0) arg = 0;
    else if (arg > 3) arg = 3;

    GARLIC_clear();
    GARLIC_printf("-- Programa XIFRAR - PID (%d) --\n", GARLIC_pid());

    char *mensajes[] = {"holaholahola", "missatgesecret", "vigeneretest", "garlicsystem", "seguretatextra"};
    char *claves[] = {"clave", "segura", "vigenere", "criptografia"};
    char *mensaje = mensajes[arg % 5];
    char *clave = claves[arg % 4];
    char cifrado[100];
    char descifrado[100];

    GARLIC_printf("Missatge a xifrar: %s\n", mensaje);
    GARLIC_printf("Fent servir clau: %s\n", clave);

    vigenereEncrypt(mensaje, clave, cifrado);
    GARLIC_printf("Missatge xifrat: %s\n", cifrado);

    vigenereDecrypt(cifrado, clave, descifrado);
    GARLIC_printf("Missatge desxifrat: %s\n", descifrado);

    return 0;
}
