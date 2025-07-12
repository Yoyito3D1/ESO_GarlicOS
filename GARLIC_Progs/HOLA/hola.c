/*------------------------------------------------------------------------------
	"HOLA.c" : Programa de prova per a GARLIC OS;
	Imprimeix "Hello world!" gestionant sem�fors individuals.
------------------------------------------------------------------------------*/

#include <GARLIC_API.h>	/* Definici� de les funcions API de GARLIC */

int _start(int arg) /* Funci� d'inici : no es fa servir 'main' */
{
	unsigned int i, j, iter;
	int semafor_id = GARLIC_pid(); 	// Cada proc�s utilitza el seu propi sem�for

	if (arg < 0) arg = 0;
	else if (arg > 3) arg = 3;

	// C�lcul del nombre d'iteracions
	j = 1;
	for (i = 0; i < arg; i++)
		j *= 10;
	GARLIC_divmod(GARLIC_random(), j, &i, &iter);
	iter++; // Almenys una iteraci�

	// Missatges inicials
	GARLIC_printf("PID %d: Iniciant execuci� amb sem�for %d!\n", GARLIC_pid(), semafor_id);

	// Primera part de l'execuci� (abans del bloqueig voluntari)
	for (i = 0; i < 5; i++) {
		GARLIC_printf("(%d)\t%d: Hello world!\n", GARLIC_pid(), i);
	}

	// Alliberem i bloquegem de nou per fer una pausa en l'execuci�
	GARLIC_signal(semafor_id);
	GARLIC_printf("PID %d: Sem�for %d alliberat temporalment. Esperant...\n", GARLIC_pid(), semafor_id);
	GARLIC_wait(semafor_id); // Bloqueja el proc�s aqu� fins que es torni a desbloquejar

	// Un cop desbloquejat, continua l'execuci�
	GARLIC_printf("PID %d: Sem�for %d garantit, continuant execuci�!\n", GARLIC_pid(), semafor_id);
	for (; i < iter; i++) {
		GARLIC_printf("(%d)\t%d: Hello world!\n", GARLIC_pid(), i);
	}

	// Finalment, alliberem definitivament el sem�for
	GARLIC_signal(semafor_id);
	GARLIC_printf("PID %d: Finalitzant execuci� i alliberant sem�for %d!\n", GARLIC_pid(), semafor_id);

	return 0;
}
