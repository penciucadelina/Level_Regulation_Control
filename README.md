# Level Control using PI, Feedforward, Cascade, and C#-Based TCP/IP Discrete Control

## Overview
This project presents the modeling, identification, and control of a liquid level process built on the Festo Process Control System and implemented in MATLAB/Simulink.

The main objective was to regulate the water level in the main tank despite disturbances affecting the inlet and outlet flow. The project starts from a nonlinear process model, derives simplified linear models around a chosen operating point, and compares several control strategies based on PI regulation, feedforward compensation, and cascade control.

As a highly practical and modern extension, the project also includes a **C#-based discrete controller** that implements the outer control loop directly in a standalone application, communicating with Simulink in real-time via the TCP/IP protocol. This demonstrates Industrial IoT / SCADA integration concepts and practical software deployability.

## Control Objective
The goal was to maintain the level of the main tank at the desired reference while rejecting disturbances as quickly as possible.
The main disturbance sources considered were:
* Outlet flow disturbances caused by changes in valve V112
* Inlet flow disturbances caused by changes in valve V101

## Main Contributions
* Developed and implemented a nonlinear Simulink model of the Festo level control plant.
* Modeled the main physical subsystems: amplifier, DC motor, centrifugal pump, pump efficiency, rotor current, tank dynamics, level sensors, and filter blocks.
* Identified simplified first-order process models around the nominal operating point.
* Designed PI controllers for the classical feedback structure (both analytically and using the FRTool).
* Studied disturbance rejection for both inlet and outlet flow perturbations.
* Implemented and compared:
  * Classical PI feedback control
  * Feedforward compensation
  * Cascade control
  * Combined cascade + feedforward control
* Implemented a discrete outer-loop controller in **C# (.NET)**.
* Integrated bidirectional real-time communication between the C# application and Simulink via **TCP/IP Sockets** for closed-loop testing.

## Process Description
The setup consists of two vertically stacked water tanks with equal cross-sectional area. The controlled variable is the level in Tank 1, while Tank 2 acts as a buffer tank.
The manipulated variable is the command voltage applied to the pump amplifier (0-24V), which drives a DC motor and centrifugal pump. The pump supplies inlet flow to the main tank, while the outlet flow is affected by valve settings and gravity.
The process includes:
* An analog ultrasonic level sensor
* Flow sensors
* A pump driven by a DC motor
* Amplifier saturation and nonlinearities
* Nonlinear tank and outlet-flow dynamics

## Modeling
A nonlinear model of the plant was developed in Simulink based on the physical behavior of the laboratory setup.
The model includes:
* Amplifier nonlinearity and saturation (at 22V)
* Motor static equations
* Pump characteristic approximation ($P_p = k_1 n^2 + k_2 n q_i + k_3 q_i^2$)
* Pump efficiency approximation
* Rotor current calculation
* Tank mass balance and gravitational outlet flow
* Level sensor scaling (gain of 1/3)
* First-order filtering to avoid algebraic-loop issues

This produced a process-oriented simulation model suitable for controller design and disturbance analysis.

## System Identification
To design linear controllers, the nonlinear process was approximated around a nominal operating point ($u_c = 5V$, $h_0 = 10.5cm$, $q_0 = 29.2 cm^3/s$).
In this personal implementation, the identified main process model resulted in:
* Process gain: K = 1.67
* Time constant: T = 160 s

For the cascade structure, the process was split and identified as:
* Inner loop (flow dynamics): K = 10.2, T = 0.7325 s
* Outer loop (level dynamics): K = 0.26, T = 260 s

## Classical PI Control
A PI controller was designed for the level loop to eliminate steady-state error and achieve acceptable reference tracking.
In this implementation, the controller was computed to achieve a closed-loop time constant $T_0 = 40s$. The resulting analytical PI controller is:
* $H_r(s) = 2.395 (1 + \frac{1}{159s})$

Additionally, the MATLAB Frequency Response Tool (FRTool) was utilized to fine-tune the PI parameters graphically using the Nichols chart to meet strict settling time requirements (160s) and minimal overshoot.

## Disturbance Rejection Problem
The classical PI controller removes steady-state error, but disturbance rejection remains relatively slow.
Simulations showed that for a step disturbance applied at the process input, the classical PI structure leads to a disturbance rejection time of approximately 800 seconds. This highly motivates the use of more advanced control structures.

## Feedforward Compensation
To improve the rejection of outlet-flow disturbances, a feedforward compensation structure was introduced.
The main idea is to use measured disturbance information to compensate for its effect before it propagates through the plant. Based on the steady-state gain relationships, the calculated feedforward compensation factor was:
* $k_{comp} = 0.1$

## Cascade Control
A cascade control structure was introduced to improve the dynamic response by separating the control task into:
* An inner fast loop acting on flow-related dynamics
* An outer slow loop regulating the tank level

This is a natural choice because the process contains fast actuator/flow dynamics ($T \approx 0.73s$) and much slower level dynamics ($T = 260s$).
The inner PI controller was tuned for a very fast closed-loop response ($T_0 = 1s$), yielding $H_{R2}(s) = 0.07(1 + \frac{1}{0.07s})$.
The outer PI controller was tuned for a closed-loop response of $T_0 = 40s$, yielding $H_{R1}(s) = 40(1 + \frac{1}{250s})$.
This structure drastically improves disturbance rejection time compared to the single-loop classical PI.

## Combined Cascade + Feedforward Structure
The most advanced Simulink structure in the project combines cascade control with feedforward compensation.
Because the internal controller regulates flow and the outer controller regulates level, the disturbance on the outlet flow can be compensated by adding the measured flow difference directly to the internal reference. In this way, the inlet flow is corrected to match the outlet-flow variation directly.
* Cascade improves the dynamic response.
* Feedforward compensates measurable disturbances directly.

## C#-Based Discrete Controller via TCP/IP
The main unique contribution of this project is the practical implementation of the discrete controller in a standalone **C# application**.
Instead of running everything inside Simulink, the control logic is externalized:
* The PI control algorithm runs in a separate C# executable.
* Simulink acts strictly as the physical plant (Digital Twin).
* Data exchange is handled in real-time over **TCP/IP** (localhost, port 5000) using the `TCP/IP Client Send` and `TCP/IP Client Receive` blocks.

This architecture is highly relevant for modern industrial setups, perfectly simulating a SCADA/PLC environment where the processing unit communicates with the physical plant actuators and sensors over an industrial network.

## Results
The project shows a clear progression from basic to advanced control structures:
* The classical PI controller achieves zero steady-state error but relatively slow disturbance rejection (~800s).
* Feedforward compensation significantly improves the rejection of measurable outlet disturbances.
* Cascade control isolates and neutralizes fast flow dynamics, highly improving overall stability.
* Combined cascade + feedforward provides the most advanced disturbance-handling structure.
* The C# TCP/IP implementation demonstrates the practical, real-time execution of the control algorithm over a network socket, bridging the gap between control theory and software engineering.

## Engineering Concepts
This project demonstrates a complete control-engineering workflow:
* Nonlinear physical modeling
* Simulink implementation
* Local linear identification around an operating point
* PI controller design (Analytical & FRTool)
* Disturbance analysis
* Advanced control structures (Cascade, Feedforward)
* Networked control systems (TCP/IP Sockets, C#)

## Tools and Technologies
* MATLAB & Simulink
* Control System Toolbox
* C# / .NET
* TCP/IP Socket Programming
* Festo Process Control System
