PROJECT IS CAPABLE OF OUTPUTTING MULTIPLE RESOLUTIONS AT 60HZ including 1920x1080

I'm using vivado 2023.2

1. go here and download digilent IP repo: https://github.com/Digilent/vivado-library
2. Create new project and source the digilent IP repo
   ![image](https://github.com/user-attachments/assets/012bb671-8fa3-4915-bdef-41d72ec3a416)

3. make design

   a. try the TCL script
    - add constraints file "pynqz2_pinout.xdc" to project in vivado
    - copy "design_1.tcl" to project directory
    - go to tcl console
    - cd "/path/to/project"
    - source design_1.tcl

   b. If not then follow: https://digilent.com/reference/programmable-logic/zybo-z7/demos/hdmi?srsltid=AfmBOoq5cbN6XfLSWAgC-5jvk1q6CJUcMsgQIrxkhTzECcotQQ0c28Wr

4. Generate bitstream
5. File -> Export -> Export Hardware ; include bitstream
6. Open Vitis, create a workspace
7. Create platform component -> next -> browse for *.xsa you just generated
8. Create application design from example -> hello world example ; delete the helloworld.c default file
9. Under hello world project import all of the files inside of the "vitis" directory in this git


NOTE: if you run into the unknown ps7_init.tcl problem then in vitis -> find launch.json under your_project -> Settings; under "Initialization file" press Browse ; navigate to project -> _ide -> psinit ; select ps7_init.tcl

![image](https://github.com/user-attachments/assets/fe04cd98-214e-40ba-8d45-845de4b0de35)

expected output:

https://github.com/user-attachments/assets/661c4d98-d64c-44d5-8bb0-c8481b524f33

