# PredictingGroundReactionForces

Toolbox to train, validate, and test using a reservoir computer to predict vertical ground reaction forces based on shank accelerometer data. The code and data is related to the publication: “Predicting vertical ground reaction forces from 3D accelerometery using reservoir computers leads to accurate gait event detection” Margit M. Bach, Nadia Dominici, and Andreas Daffertshofer. Department of Human Movement Sciences, Faculty of Behavioural and Movement Sciences, Vrije Universiteit Amsterdam, The Netherlands. 

Please cite our paper when using the code: https://doi.org/10.1101/2022.02.14.480318.

The reservoir computer is able to predict vertical ground reaction forces from shank accelerometer data. The only input needed is a data set containing accelerations and ground reaction forces [also provided]. The trained reservoir can be applied on own data.

The code runs in Matlab and is written and tested in version 2020b. It builds on M. Lukoševičius' ESNToolbox - see https://www.ai.rug.nl/minds/research/esnresearch/ and uses Bastian Bechtold's Violin Plots for Matlab, Github Project https://github.com/bastibe/Violinplot-Matlab, DOI: 10.5281/zenodo.4559847.

## Usage

There is one main script [main.m] that calls the three main parts of the analysis. The main script runs the following scripts:

- mainTrainValidateTest.m: Train, validate, and test using either stride segmented data based on true events or continuous data.
- mainTrainSizeTest.m: Train, validate, test using reduced training set between 4 and 50% of total data set.
- mainLMO.m: Leave-M-out. M = 1,2 … 10.

Each of these can be run separately. Data is located in the walk+run.mat file.

```matlab
addpath(genpath('external'));
addpath('network','analysis','preprocessing','misc');

% generate Figure 2 -----------------------
testDataType='continuous';
mainTrainValidateTest
makeFigure2

% generate Figure 3 -----------------------
mainTrainSizeTest
makeFigure3

% generate supplementary Figures S1-S3 ----
testDataType='strides';
mainTrainValidateTest
makeFigureS123

% generate supplementary Figure S3 --------
testDataType='continuous';
makeLMO
makeFigureS4
```

![Illustration](https://github.com/marlow17/PredictingGroundReactionForces/blob/main/images/Illustration.png)

## Content

- main: Main script that can be used to re-produce all results and figures from publication above. 
- mainLMO: Leave-M-out function
- mainTrainSizeTest: Train, validate, test using reduced training set between 4 and 50% of total data set.
- mainTrainValidateTest: Train, validate, and test using either stride segmented data based on true events or continuous data.
- makeFigure2: Wrapper for Figure2
- makeFigure3:Wrapper for Figure3
- makeFigureS4: Wrapper for FigureS4
- makeFigureS123: Wrapper for Figure2S
- network
  - checkESNtoolbox: Check for and acquire the ESNToolbox by M. Lukoševičius.
  - evalESN: wrapper for evaluateESN
  - evaluateESN: wrapper for test_esn from the ESNToolbox
  - initESN: Fixing parameters for the reservoir computer. Change any parameters here
  - initializeESN: wrapper for generate_esn from the ESNToolbox
  - removeTransient: Remove transient samples from target/prediction data
  - trainESN: wrapper for train_esn from the ESNToolbox
  - TrainValidateTest: Function to train, validate, and test the reservoir computer based on input data
- preprocessing
  - extractEpochs: Segment data based on epochs
  - prepareData: Pre-process input and target data according to specified in publication
  - processData: Pre-process the acceleration data
- analysis
  - descriptiveStats: Compute mean value and standard deviation of estimated errors
  - estimateEvents: Function to estimate events based on vertical ground reaction forces
  - eventError: Function to estimate event detection errors across trials
  - GRFerror: Function to estimate R2 and epsilon between predicted and target vertical GRF
  - MAE: Calculates the mean absolute error between events [predicted and target]
  - splitData: Function to split data into train, validate, and test-sets using either continuous or segmented data
- graphics
  - Figure2: Produce Fig. 2 from above-mentioned publication
  - Figure2S: Produce Fig. S2 from above-mentioned publication
  - Figure3: Produce Fig. 3 from above-mentioned publication
  - plotPrediction: Plot of segmented strides of vertical GRF [predicted and target]
  - storeFigures: Save figures in respective formats
- misc
  - eventInspection: Can be used to visually inspect event detection algorithms
  - eventSanityCheck: Check for agreement between number of events detected in predicted and target data
  - reportLMO: Report output of LMO cross-validation
  - reportStats: Report output of statistical analyses

- external (we did not include the folder but its content can be found at the listed URLs)
  - ESNToolbox -> https://www.ai.rug.nl/minds/uploads/ESNToolbox.zip
  - Violinplot-Matlab -> https://github.com/bastibe/Violinplot-Matlab

## Dataset

Dataset [walk+run.mat] contains 18 trials each with 3D shank accelerometer data, vertical ground reaction data, condition, and sampling rate.
Accelerometer data is organised in x, y, z coordinates with x being vertical direction, y being medio-lateral direction, and z being the forwards direction.

