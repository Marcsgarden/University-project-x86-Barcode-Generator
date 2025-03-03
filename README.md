# Barcode Generator (Dec 2024 - Jan 2025) 🏷️



## 📌 Project Description

This project is a **barcode generator implemented in x86 Assembly and C**. It encodes a given string into a barcode format and saves it as a `.bmp` image file. 

The project is an alternative implementation of my earlier **RISC-V barcode generator**, adapted for x86.

## 📅 Work Period

This project was developed between **December 2024 - January 2025** as part of my coursework at [Warsaw University of Technology](https://www.pw.edu.pl/).

## 🚀 Features

- Accepts user input as a string.
- Generates **Code 128 barcodes**.
- Saves the barcode as a **bitmap (.bmp) file**.
- Implements **bitmap manipulation** in **x86 assembly** and **C**.

## 🛠 Technologies Used

- **x86 Assembly**
- **C Programming**
- **BMP Image Format**
- **Memory Manipulation & Bitwise Operations**

## 🖥️ How to Run

1. **Compile the program:**
   ```sh
   make
This uses the make.file script to build the executable.

Run the program:
./barcode_generator <bar_width> "<text_to_encode>"

Example:
./barcode_generator 2 "HELLO123"
The generated barcode will be saved as output.bmp in the current directory.

📂 Project Structure
📦 x86-Barcode-Generator
 ┣ 📜 encode128.asm     # x86 Assembly file
 ┣ 📜 program.c         # C source code
 ┣ 📜 make.file         # Makefile for compiling
 ┣ 📜 README.md         # Project documentation
 ┗ 📜 output.bmp        # Generated barcode image (after execution)
⚡ Example Output
Input: "HELLO123"
Output: A barcode representation of "HELLO123" saved as output.bmp
