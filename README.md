# Text Display on Video Using FPGA

This repository holds the project for an entirely FPGA-based system which takes inputs from a PS/2 keyboard and displays outputs on a VGA monitor. The system supports all keyboard commands (alphanumerics, backspace, carriage return, etc.) and follows the AXI protocol for communication between system components.

## System Design

### Hardware Components

- **FPGA Board**: Digilent's Cora Z7
- **PS/2 Keyboard**: Input device for entering text and commands.
- **VGA Monitor**: Output device for displaying text.

### Functional Overview

#### PS/2 Keyboard Input

- The `ps2_keyboard` component detects keypresses on the PS/2 keyboard.
- It decodes the scancode of the keypress.
- Upon decoding, it sends an interrupt signal to the `vga_manager` component.

#### VGA Manager

- The `vga_manager` component receives the interrupt signal.
- It saves an 8x12 character map corresponding to the keypress into the correct location in the video memory (BRAM).

#### VGA Display

- The `vga_display` component continually updates the connected VGA monitor.
- It displays the detected keypresses in random colors onto a solid white background.

### Communication Protocol

- The AXI protocol is used for communication between the system components, ensuring efficient data transfer and synchronization.

### System Features

- **Keyboard Commands**: Supports all standard keyboard commands, including alphanumerics, backspace, and carriage return.
- **Display**: Text is displayed in random colors on a solid white background, providing a visually engaging output.

## Note

Please take a look at the project concept diagram included in the repository for an idea of how each component connects and interacts.



