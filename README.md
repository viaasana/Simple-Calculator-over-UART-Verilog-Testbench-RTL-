# Simple Calculator over UART (Verilog Testbench + RTL)

This project implements a simple calculator module (`simple_caculator`) in Verilog that communicates via UART. A testbench (`tb_simple_caculator`) simulates the UART transmission of operands and operators, and verifies the response from the calculator module.

## 🧮 Features

- Performs basic arithmetic operations: addition, subtraction, multiplication, division.
- Input/output communication via UART.
- Finite State Machine (FSM) handles the data flow.
- Configurable clock and baud rate.
- Testbench includes automatic transmission of test data.

---

## 🗂️ Project Structure

```bash
.
├── uart
│   ├── uart.v             # UART transmitter/receiver module
│   └── tb_uart.v          # Testbench for UART module
├── alu
│   ├── ALU.v              # Arithmetic Logic Unit
│   └── tb_ALU.v           # Testbench for ALU
├── simple_caculator.v     # Calculator module with UART input/output
├── tb_simple_caculator.v  # Testbench for simulating calculator logic
└── README.md              # This documentation file
```

---

## ⚙️ Parameters

### `simple_caculator.v`
| Parameter     | Description                     | Default         |
|---------------|----------------------------------|-----------------|
| `WIDTH`       | Width of operands and result     | 8               |
| `CLK_FREQ`    | Clock frequency (Hz)             | 50000000        |
| `BAUD`        | Baud rate for UART               | 9600            |

### `tb_simple_caculator.v`
| Constant         | Description                            |
|------------------|----------------------------------------|
| `CLK_PERIOD`     | Clock period in ns (50MHz → 20ns)     |
| `BIT_DURATION`   | Duration of a UART bit (approx 104ns)  |

---

## 🔧 How It Works

### States in FSM (`simple_caculator`)
1. **READ_OP1**: Waits for first operand via UART.
2. **READ_OPCODE**: Receives operator (`+`, `-`, `x`, `/`).
3. **READ_OP2**: Waits for second operand.
4. **SEND_RESULT**: Computes the result and transmits it back over UART.

### Supported Operations
| Operator | Meaning         |
|----------|------------------|
| `+`      | Addition         |
| `-`      | Subtraction      |
| `x`      | Multiplication   |
| `/`      | Division         |

---

## 🧪 Simulation

To simulate the module:

1. Use any Verilog simulator (e.g., ModelSim, Vivado, Icarus Verilog).
2. Run the testbench `tb_simple_caculator.v`.
3. Observe UART input/output and FSM state transitions via `$monitor` and `$display`.

Example simulation sequence:

```verilog
send(8'd5);          // Operand 1
send("+");           // Operator
send(8'd10);         // Operand 2
// Expected output: 15
```

---

## 📌 Notes

- UART module is assumed to be present and connected correctly. Ensure `uart.v` supports `TX_START`, `RX_DATA`, `TX_DATA`, and `value_intr`.
- The calculator handles one full operation at a time.
- Division by zero is flagged through the `error` output from the ALU (optional use).
- ASCII characters for operators must be used when sending.

---

## 🛠️ To-Do

- [ ] Add error handling and reporting (e.g., divide by zero).
- [ ] Extend to handle negative numbers and signed operations.
- [ ] Support for floating point (future work).
- [ ] **Add pipelining to improve performance.**

---

## 🧑‍💻 Author

**Thach ViaSaNa**

---
