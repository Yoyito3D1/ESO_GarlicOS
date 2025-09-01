# 🕹️🍄 GARLIC 2.0 Operating System for NDS 

## 📋 Project Description
This project is a basic implementation of the **GARLIC 2.0 operating system** for the Nintendo DS console, programmed entirely in C for ARM.  
It uses the **GARLIC API** to manage processes, interrupts, and system resources.

---

## 🚀 Main Features
- Initialization of graphics and file system.  
- Management of timers and interrupts (VBlank and TIMER0).  
- Monitoring and printing CPU usage per process.  
- Loading and execution of "HOLA" and "PONG" programs depending on key press (A or B).  
- Creation and management of up to 3 concurrent processes.  
- Controlled termination of processes after a specific time.  
- Waiting and synchronization with vertical refresh (VBlank).  
- Functions for graphical display and system status control.

---

## 🛠️ Code Structure and Functions
- **inicializarSistema()**: Initializes graphics, random seeds, file system, and interrupt configuration.  
- **porcentajeUso()**: Displays CPU usage per process on the console, synchronized with TIMER0.  
- **main()**:  
  - Initializes the system.  
  - Shows startup messages and user instructions.  
  - Detects key presses (A or B).  
  - Loads and creates processes for the corresponding programs.  
  - Manages process lifecycle (waiting, termination).  
  - Keeps the system running in an infinite loop.

---

## 📋 Usage
1. Compile the project for the NDS platform using the appropriate ARM compiler.  
2. Copy the binary files for the programs **HOLA** and **PONG** to the file system.  
3. Run the system on the NDS.  
4. Press a key:  
   - **A**: Load and run three instances of the "HOLA" program.  
   - **B**: Load and run three instances of the "PONG" program.  
5. The system displays CPU usage and automatically terminates processes after the defined time.  
6. The system remains in an indefinite wait state at the end.

---

## 🔧 Requirements and Dependencies
- Nintendo DS console or compatible emulator.  
- GARLIC API and GARLIC system (ARM-based).  
- Program files **HOLA** and **PONG** available in the file system.

---

## 📚 References
This system is an educational exercise for a simplified operating system for embedded environments with limited resources, using interrupts, multitasking, and basic process management.

---

## 🎯 Objective
Demonstrate basic process management, interrupt-based synchronization, and utilization of Nintendo DS console resources through a custom operating system.

---

## 📝 Notes
- Fully developed in ARM with GARLIC API support.  
- No other languages used.  
- Ideal for learning about embedded operating systems and low-level programming on portable consoles.

---

## 💡 Contact
For questions or inquiries, open an issue or contact the developer.

Enjoy programming! 🍄✨
