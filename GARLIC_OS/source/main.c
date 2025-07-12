#include <nds.h>
#include <stdlib.h>
#include <garlic_system.h>
#include <GARLIC_API.h>


extern int * punixTime;		// puntero a zona de memoria amb el temps real

const short divFreq0 = -33513982/1024;		// freqüència del TIMER0 = 1 Hz

/* Funció per escriure els percentatges d'ús de la CPU */
void porcentajeUso()
{
	if (_gd_sincMain & 1)			// verificar sincronismo de timer0
	{
		_gd_sincMain &= 0xFFFE;			// poner bit de sincronismo a cero
		_gg_escribir("***\t%d%%  %d%%", _gd_pcbs[0].workTicks >> 24,
										_gd_pcbs[1].workTicks >> 24, 0);
		_gg_escribir("  %d%%  %d%%\n", _gd_pcbs[2].workTicks >> 24,
										_gd_pcbs[3].workTicks >> 24, 0);
	}
}


/* Inicialitzacions generals del sistema Garlic */
//------------------------------------------------------------------------------
void inicializarSistema() {
//------------------------------------------------------------------------------
	_gg_iniGrafA();			// inicialitzar processadors gràfics
	_gs_iniGrafB();
	_gs_dibujarTabla();

	_gd_seed = *punixTime;	// inicialitzar llavor per números aleatoris amb
	_gd_seed <<= 16;		// el valor de temps real UNIX, desplaçat 16 bits
	
	_gd_pcbs[0].keyName = 0x4C524147;		// "GARL"
	
	if (!_gm_initFS()) {
		_gg_escribir("ERROR: ¡no se puede inicializar el sistema de ficheros!", 0, 0, 0);
		exit(0);
	}

	irqInitHandler(_gp_IntrMain);	// instal·lar rutina principal interrupcions
	irqSet(IRQ_VBLANK, _gp_rsiVBL);	// instal·lar RSI de vertical Blank
	irqEnable(IRQ_VBLANK);			// activar interrupcions de vertical Blank

	irqSet(IRQ_TIMER0, _gp_rsiTIMER0);
	irqEnable(IRQ_TIMER0);				// instal·lar la RSI per al TIMER0
	TIMER0_DATA = divFreq0; 
	TIMER0_CR = 0xC3;  	// Timer Start | IRQ Enabled | Prescaler 3 (F/1024)
	
	REG_IME = IME_ENABLE;			// activar les interrupcions en general
}


//------------------------------------------------------------------------------
int main(int argc, char **argv) {
//------------------------------------------------------------------------------
	intFunc start;
	int tipus = 0;
	int mtics, v;

	inicializarSistema();
	
	_gg_escribir("********************************", 0, 0, 0);
	_gg_escribir("*                              *", 0, 0, 0);
	_gg_escribir("* Sistema Operativo GARLIC 2.0 *", 0, 0, 0);
	_gg_escribir("*                              *", 0, 0, 0);
	_gg_escribir("********************************", 0, 0, 0);
	_gg_escribir("*** Inici fase 2_P\n", 0, 0, 0);
	
	// Informar a l'usuari sobre les tecles
    _gg_escribir("Prem la tecla A o B:\n", 0, 0, 0);
    _gg_escribir("A: Carregar HOLA.\n", 0, 0, 0);
    _gg_escribir("B: Carregar PONG.\n", 0, 0, 0);
	
    while (1) {
        scanKeys();  // Llegeix l'estat actual de les tecles
        int keys = keysDown();  // Retorna les tecles premudes

        if (keys & KEY_A) {  // Si es prem A
            _gg_escribir("Has premut la tecla A\n", 0, 0, 0);
            _gg_escribir("HOLA\n", 0, 0, 0);
            start = _gm_cargarPrograma("HOLA");  // Carrega el programa HOLA
            break;
        } 
        else if (keys & KEY_B) {  // Si es prem B
            _gg_escribir("Has premut la tecla B\n", 0, 0, 0);
            _gg_escribir("PONG\n", 0, 0, 0);
            start = _gm_cargarPrograma("PONG");  // Carrega el programa XF_%
			tipus = 1;
            break;
        }
    }
	
	
	if (start && (tipus == 0))
	{	
		_gp_crearProc(start, 1, "HOLA", 3);
		_gp_crearProc(start, 2, "HOLA", 3);
		_gp_crearProc(start, 3, "HOLA", 3);
		
		while (_gd_tickCount < 2400)			// esperar 4 segons
		{
			_gp_WaitForVBlank();
			porcentajeUso();
		}
		_gp_matarProc(1);					// matar procés 1
		_gg_escribir("Procés 1 eliminat\n", 0, 0, 0);
		_gs_dibujarTabla();
		
		while (_gd_tickCount < 480)			// esperar 4 segons més
		{
			_gp_WaitForVBlank();
			porcentajeUso();
		}
		_gp_matarProc(3);					// matar procés 3
		_gg_escribir("Procés 3 eliminat\n", 0, 0, 0);
		_gs_dibujarTabla();
		
		while (_gp_numProc() > 1)			// esperar que el procés 2 acabi
		{
			_gp_WaitForVBlank();
			porcentajeUso();
		}
		_gg_escribir("Procés 2 acabat\n", 0, 0, 0);
		
		
	} 
	
	else if(start && (tipus == 1))
	{
		for (v = 1; v < 4; v++)	// inicializar buffers de ventanas 1, 2 y 3
			_gd_wbfs[v].pControl = 0;
		
		_gp_crearProc(start, 1, "PONG", 1);
		_gp_crearProc(start, 2, "PONG", 2);
		_gp_crearProc(start, 3, "PONG", 3);
		
		mtics = _gd_tickCount + 960;
		while (_gd_tickCount < mtics)		// esperar 16 segundos mÃ¡s
		{
			_gp_WaitForVBlank();
			porcentajeUso();
		}
		
		_gp_matarProc(1);					// matar los 3 procesos a la vez
		_gp_matarProc(2);
		_gp_matarProc(3);
		_gg_escribir("Procesos 1, 2 y 3 eliminados\n", 0, 0, 0);
		
		while (_gp_numProc() > 1)	// esperar a que todos los procesos acaben
		{
			_gp_WaitForVBlank();
			porcentajeUso();
		}
	}
	
	else
		_gg_escribir("*** Programa NO carregat\n", 0, 0, 0);

	_gg_escribir("*** Final fase 2_P\n", 0, 0, 0);
	_gs_dibujarTabla();

	while(1) {
		_gp_WaitForVBlank();
	}							// parar el processador en un bucle infinit
	return 0;
}
