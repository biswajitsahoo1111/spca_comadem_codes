This repository contains data and codes to reproduce results of the conference paper titled "Feature subset selection using sparse principal component analysis and multiclass classification using selected features". The paper has been accpted for the conference titled  "[32nd International Congress and Exhibition on Condition Monitoring and Diagnostic Engineering Management 2019](http://www.comadem2019.com/index.html) [(COMADEM 2019)](http://www.comadem.com/conferences/)". 

Codes are written in R and we have run it on R-3.5.3. The code will save some figures and tables in local directory. Some of those figures have been used in the paper. [IMS bearing](https://ti.arc.nasa.gov/tech/dash/groups/pcoe/prognostic-data-repository/#bearing) data has been used in this paper. We have extracted features from the original data. These feature matrices can be downloaded and used in the code.

## Package Requirements
Base R &nbsp; &nbsp; &nbsp; : 3.5.3 ([MRO 3.5.3](https://mran.microsoft.com/release-history) can also be used) <br/>
e1071 &nbsp; &nbsp; &nbsp;&nbsp; : 1.7-2 <br/>
ggplot2 &nbsp; &nbsp; : 3.0.0 <br/>
lars &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;&nbsp; : 1.2 <br/>
elasticnet &nbsp; : 1.1.1 <br/>
If these packages are not already installed, command `install.packages("package_name")` can be used to install new packages.

For other reproducible results on condition monitoring, readers can visit [my project page](https://biswajitsahoo1111.github.io/cbm_codes_open/) on my [personal website](https://biswajitsahoo1111.github.io/).
