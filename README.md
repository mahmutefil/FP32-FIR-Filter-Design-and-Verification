# FP32-FIR-Filter-Design-and-Verification
In the repository, the design and verification of a parallel Floating-Point Single Precision (32-bits) FIR Filter realization can be found. The design is created using VHDL and verification part is realized using VHDL. The design is applicable for INTEL ALTERA FPGAs. The Software used to implement the FIR Filter is Quartus Prime Lite 18.0 and QuestaSim Software 2021.1.

In this project, the Floating-point operation in ALTERA is performed by configuring IPs which are ALTFP_MUL and ALTFP_ADD_SUB found in ALTERA library. Since the interfacing of the IP is register based, the design is arranged to operate with desired interfacing. 
Basically, there is a design architecture that fetches the filter order and the number of FP IPs to be able to parallelize the architecture to be able to select the most suitable numbers in terms of resource usage, timing and latency. The user can determine these generic values according to the design needs.  As seen in Figure below, the number of FP IPs is used to perform Fused Multiply-Add operation that includes one ALTFP_MULT IP and one ALTFP_ADD IP. At the end, single FP Addition IP is used to add the accumulated results coming from the FMA part. 

![image](https://user-images.githubusercontent.com/85510863/235475936-ce88ea50-92e6-40d8-8715-8b0513161b04.png)

The design is tested based on the given specifics below:
•	51 tap Low-Pass FIR filter coefficients with fsampling = 10kHz, fpass = 500hz, and fstop = 1khz
•	A noisy sinus signal 

The filter coefficients and the noisy sinus signal are generated using MATLAB Filter Designer according to the above specifications. The verification of the designs is made using VHDL and the results show that the filter works as expected. The filtered result is compared with the original noisy sinus signal as seen in figure below using MATLAB and no trouble observed for different # of FP IPs. 

![image](https://user-images.githubusercontent.com/85510863/235478983-d37c3f3e-ff82-4739-9a82-38b6d6b73e70.png)

In addition, the post implementation results in terms of resource usage and timing summary for different number of IPs are shown in Table below.

![image](https://user-images.githubusercontent.com/85510863/235479994-70a341ec-a9c9-412d-ad7e-97b70a4d82a6.png)


