Written by: Jonathan Ogland-Hand
Date: Jan. 21, 2021
Subject: This read me text file provides a brief description of the files that are included in this folder. 
This folder is posted to GitHub as supplemental information for Ogland-Hand et al. (2021)'s paper entitled "The Importance of Modeling Carbon Dioxide Transportation and Geologic Storage in Energy System Planning Tools" 

The four GAMS files are the primary four GAMS files that were modified for the study.
They are not intended to be able to "drag and drop" into a pre-existing ReEDS setup. For example, additional switches were implemented and these files will not run without also including those switches in the cases.csv file when a batch is kicked off.
Instead, they are intended to provide guidance to implementing CO2 transporation and geologic storage equations in ReEDS. These equations are provided in the supplemental information of Ogland-Hand et al. (2021).

The sco2t_supply_curve_data is the raw output data from SCO2T that was used by Ogland-Hand et al. (2021) to create geologic CO2 storage supply curves for implementation in ReEDS.
