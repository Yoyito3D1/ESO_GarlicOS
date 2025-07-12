/*------------------------------------------------------------------------------
	"HOLA.c" : Programa de prova per a GARLIC OS;
	Imprimeix "Hello world!" gestionant semàfors individuals.
------------------------------------------------------------------------------*/

#include <GARLIC_API.h>	/* Definició de les funcions API de GARLIC */

int _start(int arg) /* Funció d'inici : no es fa servir 'main' */
{
	unsigned int i, j, iter;
	int semafor_id = GARLIC_pid(); 	// Cada procés utilitza el seu propi semàfor

	if (arg < 0) arg = 0;
	else if (arg > 3) arg = 3;

	// Càlcul del nombre d'iteracions
	j = 1;
	for (i = 0; i < arg; i++)
		j *= 10;
	GARLIC_divmod(GARLIC_random(), j, &i, &iter);
	iter++; // Almenys una iteració

	// Missatges inicials
	GARLIC_printf("PID %d: Iniciant execució amb semàfor %d!\n", GARLIC_pid(), semafor_id);

	// Primera part de l'execució (abans del bloqueig voluntari)
	for (i = 0; i < 5; i++) {
		GARLIC_printf("(%d)\t%d: Hello world!\n", GARLIC_pid(), i);
	}

	// Alliberem i bloquegem de nou per fer una pausa en l'execució
	GARLIC_signal(semafor_id);
	GARLIC_printf("PID %d: Semàfor %d alliberat temporalment. Esperant...\n", GARLIC_pid(), semafor_id);
	GARLIC_wait(semafor_id); // Bloqueja el procés aquí fins que es torni a desbloquejar

	// Un cop desbloquejat, continua l'execució
	GARLIC_printf("PID %d: Semàfor %d garantit, continuant execució!\n", GARLIC_pid(), semafor_id);
	for (; i < iter; i++) {
		GARLIC_printf("(%d)\t%d: Hello world!\n", GARLIC_pid(), i);
	}

	// Finalment, alliberem definitivament el semàfor
	GARLIC_signal(semafor_id);
	GARLIC_printf("PID %d: Finalitzant execució i alliberant semàfor %d!\n", GARLIC_pid(), semafor_id);

	return 0;
}
