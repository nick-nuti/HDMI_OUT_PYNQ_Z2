I'm using vivado 2023.2

1. go here and download digilent IP repo: https://github.com/Digilent/vivado-library
2. Create new project and source the digilent IP repo
   ![image](https://github.com/user-attachments/assets/012bb671-8fa3-4915-bdef-41d72ec3a416)

3. make design
  a. IF USING 2023.2 then try the TCL script
    - add constraints file "pynqz2_pinout.xdc" to project in vivado
    - copy "project_1.tcl" to project directory
    - go to tcl console
    - cd "/path/to/project"
    - source project_1.tcl
