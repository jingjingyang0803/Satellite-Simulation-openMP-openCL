# Satellite Gravity Simulation – Parallel Computing

This project was completed as part of the Parallel Computing coursework at Tampere University.

The goal is to explore different approaches to parallelizing the simulation:

- CPU only (sequential)
- OpenMP on CPU
- OpenCL on GPU
- Hybrid OpenMP + OpenCL

## 🛰 Program Description

This program simulates **64 satellites orbiting a black hole in a 2D plane**, updating both their motion and visual appearance in real time. The system is composed of two main components:

- **Physics Engine** – computes satellite motion using simplified gravitational formulas and repeated Euler integration over 100,000 iterations per frame.
- **Graphics Engine** – renders every pixel in the window based on satellite positions, blending their colors using distance-weighted contributions and drawing a black hole at the mouse position.

Together, these components produce a dynamic visualization of orbital motion and gravitational fields.

## 📂 Repository Structure

```
├── SatellitesOriginal/   # Original sequential implementation (baseline)
├── Satellites2omp/       # Pure OpenMP implementation (physics + graphics)
├── Satellites2kernel/    # Pure OpenCL implementation (physics + graphics)
└── Satellites1kernel/    # OpenMP physics + OpenCL graphics
```

## 📚 What We Learned

- How to transform a real application step-by-step from sequential CPU code to:
  - optimized CPU
  - OpenMP (multi-threading)
  - OpenCL (GPU acceleration)
  - a hybrid CPU–GPU solution
- When GPU acceleration is beneficial: large workloads with enough parallelism to amortize kernel launch and data-transfer overhead.
- How platform differences (macOS vs Windows, Clang vs MSVC, OpenCL 1.2 vs 3.0) affect:
  - compiler flags and build system
  - available language features (e.g., `double` support in kernels)
  - performance scaling
